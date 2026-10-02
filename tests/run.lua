package.path = "modules/?.lua;" .. package.path
local runtime = require("portfolio_runtime")
local inertial = require("portfolio_inertial")
local sequence = require("portfolio_sequence")
local lease = require("portfolio_lease")
local tests = {}

local function test(name, body) tests[#tests + 1] = { name, body } end
local function equal(actual, expected)
    assert(actual == expected, "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function sensor_config()
    return { high = 15, low = 12, confirm_ms = 160, clear_ms = 400,
        max_gap_ms = 250, max_magnitude = 200 }
end
local function sequence_config()
    return { settle_ms = 800, wait_ms = 4000, observe_ms = 1200,
        max_gap_ms = 250, sensor = sensor_config() }
end
local function sample(magnitude, mode, armed)
    return { armed = armed == nil and true or armed,
        mode = mode or 7, magnitude = magnitude or 9.8 }
end
local function backend()
    local object = { held = {}, calls = {}, fail_acquire = {}, fail_release = {} }
    function object:acquire(name)
        self.held[name] = true
        self.calls[#self.calls + 1] = "acquire:" .. name
        return not self.fail_acquire[name]
    end
    function object:release(name)
        self.calls[#self.calls + 1] = "release:" .. name
        if self.fail_release[name] then return false end
        self.held[name] = nil
        return true
    end
    return object
end
local function new_lease(object)
    return lease.new({ { name = "a", duration_ms = 600 },
        { name = "b", duration_ms = 1400 } }, object, 250)
end

test("isolated acceleration spike never qualifies", function()
    local f = inertial.new(sensor_config())
    f:step(0, 10); f:step(40, 20); f:step(80, 10)
    equal(f.state, "BELOW"); equal(f.events, 0)
end)
test("continuous high samples produce exactly one event", function()
    local f = inertial.new(sensor_config())
    for now = 0, 400, 40 do f:step(now, 20) end
    equal(f.state, "ACTIVE"); equal(f.events, 1)
end)
test("hysteresis and low dwell prevent event chatter", function()
    local f = inertial.new(sensor_config())
    for now = 0, 200, 40 do f:step(now, 20) end
    f:step(240, 11); f:step(280, 13); f:step(320, 11)
    for now = 360, 720, 40 do f:step(now, 11) end
    equal(f.state, "BELOW")
    for now = 760, 920, 40 do f:step(now, 20) end
    equal(f.events, 2)
end)
test("nil NaN infinity and out-of-range acceleration invalidate", function()
    for _, value in ipairs({ false, 0/0, math.huge, -1, 201 }) do
        local f = inertial.new(sensor_config())
        f:step(0, 20); f:step(40, value)
        equal(f.state, "UNAVAILABLE"); equal(f.events, 0)
    end
    equal(inertial.new(sensor_config()):step(0, nil), "UNAVAILABLE")
end)
test("missing sample and scheduler gap discard accumulated dwell", function()
    local f = inertial.new(sensor_config())
    f:step(0, 20); f:step(40, 20); f:step(400, 20)
    equal(f.state, "UNAVAILABLE")
    f:step(440, 20); f:step(480, nil); f:step(520, 20)
    equal(f.state, "QUALIFYING"); equal(f.events, 0)
end)
test("sensor event duration survives bounded-epoch rollover", function()
    local f = inertial.new(sensor_config())
    local start = runtime.CLOCK_PERIOD_MS - 80
    for elapsed = 0, 160, 40 do f:step((start + elapsed) % runtime.CLOCK_PERIOD_MS, 20) end
    equal(f.events, 1)
end)
test("inverted hysteresis configuration is rejected", function()
    local c = sensor_config(); c.low = c.high
    equal(pcall(inertial.new, c), false)
end)

test("confirmed disarm blocks a sequence", function()
    local s = sequence.new(sequence_config())
    equal(s:step(0, sample(20, 7, false)), "BLOCKED")
end)
test("qualified sequence completes once and resets only after disarm", function()
    local s = sequence.new(sequence_config())
    for now = 0, 800, 40 do s:step(now, sample()) end
    equal(s.state, "WATCHING")
    for now = 840, 1000, 40 do s:step(now, sample(20)) end
    equal(s.state, "OBSERVING")
    for now = 1040, 2200, 40 do s:step(now, sample()) end
    equal(s.state, "COMPLETE")
    equal(s:step(2240, sample(20)), "COMPLETE")
    equal(s:step(2280, sample(20, 7, false)), "BLOCKED")
    equal(s:step(2320, sample()), "SETTLING")
end)
test("mode change cancels and cannot restart while armed", function()
    local s = sequence.new(sequence_config())
    s:step(0, sample()); s:step(40, sample(10, 8))
    equal(s.state, "CANCELLED")
    equal(s:step(80, sample()), "CANCELLED")
end)
test("unknown arm mode or acceleration cancels active observation", function()
    for _, missing in ipairs({ "armed", "mode", "magnitude" }) do
        local s = sequence.new(sequence_config())
        s:step(0, sample())
        local inputs = sample(); inputs[missing] = nil
        equal(s:step(40, inputs), "CANCELLED")
    end
end)
test("missed scheduler deadline cancels the sequence", function()
    local s = sequence.new(sequence_config())
    s:step(0, sample())
    equal(s:step(251, sample()), "CANCELLED")
    equal(s.reason, "scheduler gap")
end)
test("a late event loses to the event-window deadline", function()
    local c = sequence_config(); c.wait_ms = 200
    local s = sequence.new(c)
    for now = 0, 800, 40 do s:step(now, sample()) end
    for now = 840, 1000, 40 do s:step(now, sample(20)) end
    equal(s.state, "CANCELLED"); equal(s.reason, "event window expired")
end)
test("callback invalidation latches cancellation", function()
    local s = sequence.new(sequence_config())
    s:step(0, sample()); s:invalidate()
    equal(s:step(40, sample()), "CANCELLED")
end)
test("sequence timing survives rollover", function()
    local s = sequence.new(sequence_config())
    local start = runtime.CLOCK_PERIOD_MS - 400
    for dt = 0, 800, 40 do s:step((start + dt) % runtime.CLOCK_PERIOD_MS, sample()) end
    equal(s.state, "WATCHING")
end)

test("virtual resources expire independently without reacquisition", function()
    local b = backend(); local l = new_lease(b)
    l:step(0, true)
    for now = 40, 600, 40 do l:step(now, true) end
    equal(b.held.a, nil); equal(b.held.b, true); equal(l.pending, 1)
    for now = 640, 1400, 40 do l:step(now, true) end
    equal(l.state, "CLOSED"); equal(l.pending, 0)
    local calls = #b.calls; l:step(1440, true); equal(#b.calls, calls)
    l:step(1480, false); equal(l.state, "FREE")
end)
test("partial acquisition rolls back even unacknowledged side effects", function()
    local b = backend(); b.fail_acquire.b = true
    local l = new_lease(b); l:step(0, true)
    equal(l.state, "CLOSED"); equal(l.pending, 0)
    equal(next(b.held), nil)
end)
test("release failure retains pending ownership until acknowledged", function()
    local b = backend(); local l = new_lease(b)
    l:step(0, true); b.fail_release.b = true; l:cancel()
    equal(l.state, "RELEASING"); equal(l.pending, 1)
    l:step(40, true); equal(l.pending, 1)
    b.fail_release.b = nil; l:step(80, true)
    equal(l.state, "CLOSED"); equal(l.pending, 0)
end)
test("backend exception is retained as an unresolved release", function()
    local b = backend(); local l = new_lease(b)
    l:step(0, true); b.release = function() error("simulated failure") end
    l:cancel(); equal(l.state, "RELEASING"); equal(l.pending, 2)
end)
test("deadline release failure is retried on the next tick", function()
    local b = backend(); local l = new_lease(b)
    l:step(0, true); b.fail_release.a = true
    for now = 40, 600, 40 do l:step(now, true) end
    equal(l.pending, 2)
    b.fail_release.a = nil; l:step(640, true)
    equal(l.pending, 1); equal(b.held.a, nil)
end)
test("unknown request and clock gap revoke virtual ownership", function()
    local b = backend(); local l = new_lease(b)
    l:step(0, true); l:step(40, nil); equal(next(b.held), nil)
    l:step(80, false); l:step(120, true); l:step(400, true)
    equal(l.state, "CLOSED"); equal(next(b.held), nil)
end)
test("duplicate resource names are rejected", function()
    equal(pcall(lease.new, { { name = "a", duration_ms = 1 },
        { name = "a", duration_ms = 2 } }, backend(), 250), false)
end)
test("virtual lease deadlines survive rollover", function()
    local b = backend(); local l = new_lease(b)
    local start = runtime.CLOCK_PERIOD_MS - 400
    for dt = 0, 600, 40 do l:step((start + dt) % runtime.CLOCK_PERIOD_MS, true) end
    equal(l.pending, 1)
end)

local function with_firmware(body)
    local saved = {}
    local names = { "millis", "ahrs", "arming", "vehicle", "rc", "gcs", "param", "SRV_Channels" }
    for _, name in ipairs(names) do saved[name] = _G[name] end
    local mock = { now = 0, armed = false, mode = 7, magnitude = 9.8,
        messages = {}, output_calls = 0 }
    local function forbidden()
        mock.output_calls = mock.output_calls + 1
        error("firmware write attempted")
    end
    _G.millis = function() return mock.now end
    _G.ahrs = { get_accel = function()
        return { x = function() return 0 end, y = function() return 0 end,
            z = function() return mock.magnitude end }
    end }
    _G.arming = { is_armed = function() return mock.armed end,
        arm = forbidden, disarm = forbidden }
    _G.vehicle = { get_mode = function() return mock.mode end, set_mode = forbidden }
    _G.rc = { get_channel = function(_, index)
        equal(index, 1); return { set_override = forbidden }
    end }
    _G.gcs = { send_text = function(_, _, message)
        mock.messages[#mock.messages + 1] = message
    end }
    _G.param = { set = forbidden, set_and_save = forbidden }
    _G.SRV_Channels = { set_output_pwm = forbidden }
    local ok, err = pcall(body, mock)
    for _, name in ipairs(names) do _G[name] = saved[name] end
    assert(ok, err)
    equal(mock.output_calls, 0)
end

test("binding failures remain unknown rather than false disarm", function()
    with_firmware(function()
        arming.is_armed = function() error("binding unavailable") end
        local armed = runtime.vehicle_sample(); equal(armed, nil)
        ahrs.get_accel = function() return nil end
        equal(runtime.acceleration(), nil)
    end)
end)
test("invalid vector components are rejected", function()
    with_firmware(function(mock)
        mock.magnitude = 0/0; equal(runtime.acceleration(), nil)
        mock.magnitude = math.huge; equal(runtime.acceleration(), nil)
    end)
end)
test("unsigned clock converts the difference, never full uptime", function()
    with_firmware(function()
        -- Signed integer bits stand in for uint32 storage, avoiding a mock
        -- which itself rounds full uptime to float32 before subtraction.
        local raw = -20
        local metatable = { __sub = function(a, b)
            return { tofloat = function() return (a.value - b.value) % 4294967296.0 end }
        end }
        millis = function() return setmetatable({ value = raw }, metatable) end
        local clock = runtime.new_clock(); equal(clock(), 0)
        raw = 20; equal(clock(), 40)
        raw = 60; equal(clock(), 80)
    end)
end)
test("long uptime keeps model time within the exact float32 epoch", function()
    with_firmware(function()
        local raw = 1000000000
        millis = function()
            return setmetatable({ value = raw }, { __sub = function(a, b)
                return { tofloat = function() return a.value - b.value end }
            end })
        end
        local clock = runtime.new_clock(); equal(clock(), 0)
        for step = 1, 5000 do
            raw = raw + 40
            equal(clock(), (step * 40) % runtime.CLOCK_PERIOD_MS)
        end
    end)
end)
test("a whole skipped model epoch is a clock fault", function()
    with_firmware(function(mock)
        local clock = runtime.new_clock(); equal(clock(), 0)
        mock.now = runtime.CLOCK_PERIOD_MS; equal(clock(), nil)
    end)
end)
test("ambiguous half-epoch durations are rejected", function()
    local c = sensor_config(); c.confirm_ms = runtime.CLOCK_PERIOD_MS / 2
    equal(pcall(inertial.new, c), false)
end)
test("missing clock invalidates one tick and recovers explicitly", function()
    with_firmware(function(mock)
        local clock = runtime.new_clock(); equal(clock(), 0)
        millis = function() return nil end; equal(clock(), nil)
        millis = function() return mock.now end; mock.now = 80
        equal(clock(), 0)
    end)
end)
test("scheduler catches callback errors and invokes invalidation", function()
    with_firmware(function(mock)
        local invalidated = 0
        local update, period = runtime.schedule(40, function() error("fault") end,
            function() invalidated = invalidated + 1 end)
        equal(period, 40)
        equal(select(2, update()), 40); mock.now = 40; update()
        equal(invalidated, 2); equal(#mock.messages, 1)
    end)
end)
test("telemetry exception cannot stop the callback", function()
    with_firmware(function()
        gcs.send_text = function() error("telemetry unavailable") end
        equal(pcall(runtime.reporter("test"), "state", true), true)
    end)
end)
test("inertial firmware wrapper qualifies events without writes", function()
    with_firmware(function(mock)
        local update = assert(loadfile("scripts/inertial-event/main.lua"))()
        mock.magnitude = 20
        for now = 0, 200, 40 do mock.now = now; update() end
        assert(table.concat(mock.messages, " "):find("ACTIVE", 1, true))
    end)
end)
test("sequence firmware wrapper observes a complete synthetic cycle", function()
    with_firmware(function(mock)
        local update = assert(loadfile("scripts/guarded-sequence/main.lua"))()
        update(); mock.armed = true
        for now = 40, 840, 40 do mock.now = now; update() end
        mock.magnitude = 20
        for now = 880, 1040, 40 do mock.now = now; update() end
        mock.magnitude = 9.8
        for now = 1080, 2240, 40 do mock.now = now; update() end
        assert(table.concat(mock.messages, " "):find("COMPLETE", 1, true))
    end)
end)
test("lease firmware wrapper releases virtual resources on mode change", function()
    with_firmware(function(mock)
        local update = assert(loadfile("scripts/control-lease/main.lua"))()
        mock.armed = true; update(); mock.now = 40; mock.mode = 8; update()
        local output = table.concat(mock.messages, " ")
        assert(output:find("HELD", 1, true)); assert(output:find("CLOSED", 1, true))
    end)
end)
test("missing RC capability does not grant a virtual lease", function()
    with_firmware(function(mock)
        local update = assert(loadfile("scripts/control-lease/main.lua"))()
        mock.armed = true; rc.get_channel = function() return nil end; update()
        assert(table.concat(mock.messages, " "):find("CLOSED", 1, true))
    end)
end)

local failed = 0
for _, entry in ipairs(tests) do
    local ok, error_message = pcall(entry[2])
    if ok then io.write("PASS ", entry[1], "\n")
    else failed = failed + 1; io.write("FAIL ", entry[1], ": ", tostring(error_message), "\n") end
end
io.write(string.format("%d tests, %d failures (%s, integer max=%s, float bytes=%d)\n",
    #tests, failed, _VERSION, tostring(math.maxinteger), string.packsize("n")))
if failed > 0 then os.exit(1) end
