-- Shared read-only ArduPilot boundary; models never receive firmware userdata.
local M = {}
local WRAP_MS = 4294967296.0
-- A bounded epoch stays exactly representable with firmware float32 numbers.
-- All model deadlines must be shorter than half this period.
M.CLOCK_PERIOD_MS = 65536.0

function M.duration(value)
    return M.finite(value) and value > 0 and value < M.CLOCK_PERIOD_MS / 2
end

function M.finite(value)
    return type(value) == "number" and value == value
        and value > -math.huge and value < math.huge
end

function M.elapsed(now, previous)
    return (now - previous) % M.CLOCK_PERIOD_MS
end

function M.call(object, method, ...)
    if object == nil then return nil end
    local arguments = { ... }
    local ok, value = pcall(function()
        if type(object[method]) ~= "function" then return nil end
        return object[method](object, table.unpack(arguments))
    end)
    if ok then return value end
    return nil
end

function M.acceleration()
    local vector = M.call(ahrs, "get_accel")
    local x, y, z = M.call(vector, "x"), M.call(vector, "y"), M.call(vector, "z")
    if not M.finite(x) or not M.finite(y) or not M.finite(z) then return nil end
    local magnitude = math.sqrt(x * x + y * y + z * z)
    if M.finite(magnitude) then return magnitude end
    return nil
end

function M.vehicle_sample()
    local armed = M.call(arming, "is_armed")
    local mode = M.call(vehicle, "get_mode")
    if type(armed) ~= "boolean" then armed = nil end
    if not M.finite(mode) or mode < 0 or mode % 1 ~= 0 then mode = nil end
    return armed, mode
end

function M.new_clock()
    local previous, logical_ms = nil, 0
    return function()
        local ok, raw = pcall(function() return millis() end)
        if not ok or raw == nil then previous = nil; return nil end
        if previous == nil then previous = raw; return logical_ms end
        local subtract_ok, delta = pcall(function()
            -- Unsigned firmware subtraction precedes conversion: full uptime
            -- conversion to float would lose millisecond precision.
            local difference = raw - previous
            if type(difference) == "number" then return difference % WRAP_MS end
            return difference:tofloat()
        end)
        previous = raw
        if not subtract_ok or not M.finite(delta) or delta < 0 then return nil end
        if delta >= M.CLOCK_PERIOD_MS / 2 then return nil end
        logical_ms = (logical_ms + delta) % M.CLOCK_PERIOD_MS
        return logical_ms
    end
end

function M.reporter(name)
    local last_message
    return function(message, warning)
        if message == last_message then return end
        last_message = message
        M.call(gcs, "send_text", warning and 4 or 6, name .. ": " .. message)
    end
end

function M.schedule(period_ms, tick, on_error)
    local clock = M.new_clock()
    local report = M.reporter("portfolio runtime")
    local function update()
        local ok = pcall(tick, clock())
        if not ok then
            -- Do not print exception text: a binding error can include private data.
            if on_error then pcall(on_error) end
            report("callback fault; model invalidated", true)
        end
        return update, period_ms
    end
    return update, period_ms
end

return M
