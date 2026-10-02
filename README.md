# ArduPilot Lua Engineering Examples

A collection of independently prepared Lua examples for ArduPilot demonstrating sensor-event handling, guarded state transitions and temporary control-ownership logic.

[![Lua checks](https://github.com/lolpul/ardupilot-lua-scripts/actions/workflows/checks.yml/badge.svg)](https://github.com/lolpul/ardupilot-lua-scripts/actions/workflows/checks.yml)

## About

This project explains engineering approaches to ArduPilot scripting and UAV integration through small, testable examples. The flight-controller adapters read state and send status text. The control-lease example uses an in-memory backend: **none of the examples commands motors, servos, flight modes, arming or RC overrides**.

Three demonstrations isolate mechanisms observed in one reviewed source example. They are independent implementations, not three separate historical projects. Filtering, modular tests and acknowledged-release handling are additions made for this public demonstration. The second supplied source snapshot contained only a template README. See the [sanitized source assessment](docs/source-audit.md).

Author: [Elisey Kochura](https://elisey.kochura.com), R&D / Software Engineer. [UAV portfolio overview](https://elisey.kochura.com/work/uav-flight-systems).

## Engineering areas

- ArduPilot Lua scheduling and read-only API integration
- Acceleration sampling, validation, hysteresis and event qualification
- Explicit state machines and bounded observation windows
- Fault handling, cancellation and confirmed ownership release
- Unsigned time differences and float32 precision constraints
- Best-effort, transition-based telemetry
- Host tests with mocked firmware boundaries

UART, GPIO, relay, direct MAVLink messaging and flight-performance claims are outside the inspected evidence and this collection.

## Projects / Examples

| Example | Problem and approach | APIs | Failure handling | Validation and limits |
| --- | --- | --- | --- | --- |
| [Inertial event observer](scripts/inertial-event/README.md) | Reject short acceleration spikes; qualify sustained events and clear them with hysteresis. | `ahrs:get_accel()`, Vector3f components, `millis()`, `gcs:send_text()` | Invalid samples and scheduling gaps discard accumulated dwell. | Host scenarios pass; acceleration magnitude includes gravity and is not a validated launch detector. |
| [Guarded sequence observer](scripts/guarded-sequence/README.md) | Observe a bounded sequence only while arming, mode and sensor conditions remain valid. | Above plus `arming:is_armed()`, `vehicle:get_mode()` | Mode change, unknown input or timeout cancels; confirmed disarm resets the latch. | Synthetic full-cycle and fault tests pass; no takeoff, throttle or flight-mode action. |
| [Virtual control lease](scripts/control-lease/README.md) | Model temporary ownership, partial-acquisition rollback and failed-release retries. | Arming/mode reads, `rc:get_channel(1)` capability probe, clock and status text | Retain pending ownership until release is acknowledged. | Fault-injected virtual backend passes; no real RC override binding is called. |

Each example README covers its goal, architecture, state transitions, API use, failures, validation procedure and possible improvements.

## Run the reproducible host checks

From the repository root with Lua 5.3 or 5.4 installed:

```sh
lua tests/run.lua
```

The 36 behavioral and mocked-binding scenarios passed locally with Lua 5.4.6 and checksum-verified stock Lua 5.3.5 built with `LUA_32BITS` (32-bit integers and floats). These are host results. **SITL, HIL, physical bench and flight validation have not been performed for this repository.** [Testing details and proposed procedures](docs/testing.md).

## Hardware / environment

- ArduPilot-compatible flight controller with scripting support, or a suitable SITL build
- AHRS acceleration, arming/mode bindings and GCS status-text support
- Generic RC channel capability for the virtual-lease wrapper; no physical mapping is assigned

API references were checked against [upstream revision `cafe674`](docs/api-reference.md), not a confirmed deployment firmware. Verify the bindings in the exact firmware you intend to test.

For a controlled SITL evaluation, copy `modules/portfolio_*.lua` into `APM/scripts/modules/`. Copy one example's `main.lua` into `APM/scripts/` under a unique name such as `portfolio_inertial_demo.lua`. Do not put three files named `main.lua` into the same destination. All settings are illustrative Lua configuration tables; see [configuration examples](examples/parameters.example.md). Hardware installation is not part of the recorded validation.

## Safety

These examples are for educational, portfolio and controlled testing purposes. Validate in SITL, then appropriate HIL/bench conditions before considering real-aircraft use. Parameters, firmware behavior and hardware mappings must be checked for the specific aircraft. Host tests do not establish flight safety or real-time scheduling guarantees.

The virtual lease does not provide a hardware watchdog or a flight-controller failsafe. Adding actuator commands requires a separate design and validation effort; it is not a configuration switch in this project. The guarded observer captures the first observed armed mode for comparison; it does not approve that mode for any flight action.

## Confidentiality

This repository contains independently prepared and sanitized engineering examples. It does not contain employer source code, production configurations, private infrastructure details or operational flight data.

The original file, archive names, internal repository locations, tuning values, control mappings and original comments are excluded. A fresh Git history contains only reviewed demonstration files. No source-repository history is imported.

## Repository map

- `scripts/`: three firmware-facing read-only wrappers and their explanations
- `modules/`: shared boundary, event filter, sequence and virtual-lease models
- `tests/run.lua`: reproducible behavioral and fault-injection suite
- `docs/architecture.md`: boundaries, timing and design decisions
- `docs/testing.md`: actual results and unperformed validation procedures
- `docs/source-audit.md`: sanitized audit and inclusion decisions
- `docs/patches/`: compact change records

## License

[MIT](LICENSE) applies to the independently written demonstration code and documentation in this repository. No license is granted for the excluded original material.
