local runtime = require("portfolio_runtime")
local virtual = { held = {} }
function virtual:acquire(name) self.held[name] = true; return true end
function virtual:release(name) self.held[name] = nil; return true end

local lease = require("portfolio_lease").new({
    { name = "resource_a", duration_ms = 600 },
    { name = "resource_b", duration_ms = 1400 },
}, virtual, 250)
local report = runtime.reporter("lease demo")
local baseline_mode, stopped = nil, false

return runtime.schedule(40, function(now)
    local armed, mode = runtime.vehicle_sample()
    -- Probe only the generic first channel; it is not assigned to a control.
    local channel_available = runtime.call(rc, "get_channel", 1) ~= nil
    local request
    if armed == false then
        baseline_mode, stopped, request = nil, false, false
    elseif armed == true and mode ~= nil and channel_available and not stopped then
        baseline_mode = baseline_mode or mode
        if mode == baseline_mode then request = true else stopped = true end
    else
        stopped = true
    end
    local state = lease:step(now, request)
    report(state .. "; virtual resources=" .. tostring(lease.pending),
        state == "RELEASING")
end, function() stopped = true; lease:cancel() end)
