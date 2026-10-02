# Testing and validation

## Performed on 2026-10-02

| Check | Environment | Result |
| --- | --- | --- |
| Behavioral and mocked-binding suite | Windows Lua 5.4.6, 64-bit integers / 64-bit floating numbers | 36 tests passed |
| Same suite with constrained number representation | Stock Lua 5.3.5 built locally with `LUA_32BITS` in an existing Linux development environment | 36 tests passed; integer maximum and 4-byte number size confirmed by the runner |
| Syntax parsing | Local `luac` | All eight Lua files parsed |
| Firmware API review | Pinned official upstream sources | Signatures, one-based Lua channel indexing and module search path inspected |

The original source was read from ZIP snapshots and was not executed. No source repository history was available. The demonstrated Lua 5.3.5 build is a stock host interpreter, not ArduPilot's complete modified runtime or real userdata implementation. The suite uses explicit firmware mocks.

## Run locally

```sh
lua tests/run.lua
```

The suite checks event qualification and hysteresis; nil/nonfinite values; mode/arming uncertainty; timeout priority and reset latches; partial resource acquisition; failed/throwing cleanup; lease deadlines; unsigned and bounded-epoch rollover; long uptime; skipped epochs; callback errors; best-effort telemetry; and all three wrappers. Firmware-write traps check that tested wrapper paths do not call arming, mode, parameter or output commands.

CI runs the same suite with Ubuntu Lua 5.3 and a stock float32 Lua 5.3.5 build. Its source archive is verified against the [official Lua checksum listing](https://www.lua.org/ftp/) before compilation. Workflow status records remote execution separately from local results.

## Proposed SITL validation — not performed

1. Select a scripting-capable vehicle build and record its exact revision and enabled bindings. Start an isolated session without importing real mission/configuration files.
2. Install the four modules in `APM/scripts/modules/` and one uniquely named wrapper in `APM/scripts/`. Follow the firmware's official scripting setup requirements.
3. For the inertial observer, compare acceleration availability and qualitative magnitude changes with reported states. A real simulator signal may not cross the synthetic threshold; this is not evidence of an error or of a launch detector.
4. For the sequence, use simulator-only arming and mode changes to observe blocked/settling/cancelled/reset behavior. A qualified-event scenario needs a controlled reproducible simulated signal; record the stimulus and expected transition.
5. For the virtual lease, confirm the generic channel object can be read. Observe independent virtual release and closure; confirm no RC overrides or physical output commands are issued.
6. Inject missing bindings and scheduler delays in a dedicated instrumented test harness; compare cancellation and pending-release outcomes with the host tests.

These steps are a validation procedure, not a report of completed SITL tests.

## Proposed HIL / bench validation — not performed

If target-binding verification is needed, use a clearly identified controller on a physically safe isolated bench, with propulsion and actuator loads disconnected. Confirm firmware, power and mapping first. Observe only status messages and read-only bindings. The virtual backend requires no actuator tests. No physical safety confirmation or hardware action occurred in this task.

## Limits

No HIL, bench, flight, timing-jitter measurement, hardware watchdog verification or real RC override test has been performed. No flight-safety, performance or production-readiness claim follows from the host suite. GCS text delivery is best effort, and unchanged sensor values cannot establish data freshness.
