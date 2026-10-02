local runtime = require("portfolio_runtime")
local sequence = require("portfolio_sequence").new({
    settle_ms = 800, wait_ms = 4000, observe_ms = 1200, max_gap_ms = 250,
    sensor = { high = 15.0, low = 12.0, confirm_ms = 160,
        clear_ms = 400, max_gap_ms = 250, max_magnitude = 200.0 },
})
local report = runtime.reporter("sequence demo")

return runtime.schedule(40, function(now)
    local armed, mode = runtime.vehicle_sample()
    local state = sequence:step(now, {
        armed = armed, mode = mode, magnitude = runtime.acceleration(),
    })
    report(state .. " (" .. sequence.reason .. ")", state == "CANCELLED")
end, function() sequence:invalidate() end)
