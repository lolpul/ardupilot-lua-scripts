local runtime = require("portfolio_runtime")
local M = {}

function M.new(config)
    assert(runtime.finite(config.high) and runtime.finite(config.low)
        and config.high > config.low and config.low >= 0, "invalid hysteresis")
    assert(runtime.duration(config.confirm_ms) and runtime.duration(config.clear_ms)
        and runtime.duration(config.max_gap_ms) and runtime.finite(config.max_magnitude)
        and config.max_magnitude >= config.high,
        "invalid durations")
    local self = { state = "UNAVAILABLE", events = 0 }
    local previous, qualifying_since, clearing_since

    function self:invalidate()
        self.state = "UNAVAILABLE"
        previous, qualifying_since, clearing_since = nil, nil, nil
    end

    function self:step(now, magnitude)
        if not runtime.finite(now) or not runtime.finite(magnitude)
            or magnitude < 0 or magnitude > config.max_magnitude then
            self:invalidate()
            return self.state, false
        end
        if previous and runtime.elapsed(now, previous) > config.max_gap_ms then
            self:invalidate()
            previous = now
            return self.state, false
        end
        previous = now
        if self.state == "UNAVAILABLE" then self.state = "BELOW" end
        local fired = false
        if self.state == "ACTIVE" then
            if magnitude <= config.low then
                clearing_since = clearing_since or now
                if runtime.elapsed(now, clearing_since) >= config.clear_ms then
                    self.state, clearing_since = "BELOW", nil
                end
            else
                clearing_since = nil
            end
        elseif magnitude >= config.high then
            qualifying_since = qualifying_since or now
            self.state = "QUALIFYING"
            if runtime.elapsed(now, qualifying_since) >= config.confirm_ms then
                self.state, qualifying_since = "ACTIVE", nil
                self.events, fired = self.events + 1, true
            end
        else
            self.state, qualifying_since = "BELOW", nil
        end
        return self.state, fired
    end

    return self
end

return M
