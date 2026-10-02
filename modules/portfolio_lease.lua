-- A virtual backend contract. This module contains no firmware output calls.
local runtime = require("portfolio_runtime")
local M = {}

function M.new(resources, backend, max_gap_ms)
    assert(#resources > 0 and #resources <= 8 and runtime.duration(max_gap_ms),
        "invalid lease bounds")
    local seen = {}
    for _, resource in ipairs(resources) do
        assert(type(resource.name) == "string" and not seen[resource.name]
            and runtime.duration(resource.duration_ms),
            "invalid resource")
        seen[resource.name] = true
    end
    local self = { state = "FREE", pending = 0 }
    local held, acquired_at, previous = {}, nil, nil

    local function invoke(method, name)
        local ok, acknowledged = pcall(backend[method], backend, name)
        return ok and acknowledged == true
    end

    local function release_due(now, all)
        for index = #resources, 1, -1 do
            local resource = resources[index]
            if held[resource.name] and (all
                or runtime.elapsed(now, acquired_at) >= resource.duration_ms) then
                if invoke("release", resource.name) then held[resource.name] = nil end
            end
        end
        self.pending = 0
        for _ in pairs(held) do self.pending = self.pending + 1 end
    end

    function self:cancel()
        self.state = "RELEASING"
        release_due(nil, true)
        if self.pending == 0 then self.state = "CLOSED" end
    end

    function self:step(now, request)
        if self.state == "RELEASING" then
            self:cancel()
            return self.state
        end
        if request == false then
            if self.state == "HELD" then self:cancel() end
            if self.pending == 0 then self.state, previous = "FREE", nil end
            return self.state
        end
        if self.state == "CLOSED" then return self.state end
        if request ~= true or not runtime.finite(now)
            or (previous and runtime.elapsed(now, previous) > max_gap_ms) then
            self:cancel()
            return self.state
        end
        previous = now
        if self.state == "FREE" then
            acquired_at = now
            for _, resource in ipairs(resources) do
                -- Include even a failed acquisition in rollback: a backend may
                -- have applied the request before losing its acknowledgement.
                held[resource.name] = true
                if not invoke("acquire", resource.name) then
                    self:cancel()
                    return self.state
                end
            end
            self.state, self.pending = "HELD", #resources
        else
            release_due(now, false)
            -- Failed deadline releases retain ownership and are retried;
            -- a failed release must not be advertised as a clean handoff.
            if self.pending == 0 then self.state = "CLOSED" end
        end
        return self.state
    end

    return self
end

return M
