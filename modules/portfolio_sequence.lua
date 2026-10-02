local runtime = require("portfolio_runtime")
local inertial = require("portfolio_inertial")
local M = {}

function M.new(config)
    assert(runtime.duration(config.settle_ms) and runtime.duration(config.wait_ms)
        and runtime.duration(config.observe_ms) and runtime.duration(config.max_gap_ms),
        "invalid sequence durations")
    local filter = inertial.new(config.sensor)
    local self = { state = "BLOCKED", reason = "not started" }
    local entered, previous, entry_mode

    local function transition(state, now, reason)
        self.state, self.reason, entered = state, reason, now
    end

    function self:invalidate()
        filter:invalidate()
        transition("CANCELLED", nil, "callback fault")
    end

    function self:step(now, sample)
        -- A confirmed disarm is the only reset; unknown arming is not disarm.
        if sample.armed == false then
            filter:invalidate()
            previous, entry_mode = nil, nil
            transition("BLOCKED", now, "confirmed disarm")
            return self.state
        end
        if self.state == "COMPLETE" or self.state == "CANCELLED" then return self.state end
        local sensor_valid = runtime.finite(sample.magnitude)
            and sample.magnitude >= 0 and sample.magnitude <= config.sensor.max_magnitude
        if not runtime.finite(now) or sample.armed ~= true
            or not runtime.finite(sample.mode) or not sensor_valid then
            transition("CANCELLED", now, "unavailable input")
            return self.state
        end
        if previous and runtime.elapsed(now, previous) > config.max_gap_ms then
            transition("CANCELLED", now, "scheduler gap")
            return self.state
        end
        previous = now
        if self.state == "BLOCKED" then
            entry_mode = sample.mode
            transition("SETTLING", now, "conditions observed")
        elseif sample.mode ~= entry_mode then
            transition("CANCELLED", now, "mode changed")
        elseif self.state == "SETTLING" then
            if runtime.elapsed(now, entered) >= config.settle_ms then
                filter:invalidate()
                transition("WATCHING", now, "settle complete")
            end
        elseif self.state == "WATCHING" then
            -- An expired observation window takes priority over a late event.
            if runtime.elapsed(now, entered) >= config.wait_ms then
                transition("CANCELLED", now, "event window expired")
            else
                local _, fired = filter:step(now, sample.magnitude)
                if fired then transition("OBSERVING", now, "qualified event") end
            end
        elseif self.state == "OBSERVING" then
            if runtime.elapsed(now, entered) >= config.observe_ms then
                transition("COMPLETE", now, "observation complete")
            end
        end
        return self.state
    end

    return self
end

return M
