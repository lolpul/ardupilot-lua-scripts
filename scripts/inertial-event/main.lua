local runtime = require("portfolio_runtime")
local filter = require("portfolio_inertial").new({
    high = 15.0, low = 12.0, confirm_ms = 160, clear_ms = 400,
    max_gap_ms = 250, max_magnitude = 200.0,
})
local report = runtime.reporter("inertial demo")

return runtime.schedule(40, function(now)
    local state = filter:step(now, runtime.acceleration())
    report(state, state == "UNAVAILABLE")
end, function() filter:invalidate() end)
