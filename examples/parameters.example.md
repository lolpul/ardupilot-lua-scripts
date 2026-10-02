# Demonstration configuration

This repository does not read or change persistent ArduPilot parameters. Models use Lua configuration tables in the three wrappers. The values below are synthetic teaching defaults, not aircraft tuning or operating instructions.

| Setting | Illustrative value | Meaning |
| --- | --- | --- |
| Callback request | 40 ms | Requested wrapper interval, not a guaranteed deadline |
| Maximum sample gap | 250 ms | Invalidate/cancel after a missed observed interval |
| High / low magnitude | 15 / 12 m/s² | Hysteresis boundaries for the generic magnitude observer |
| Qualifying / clearing dwell | 160 / 400 ms | Continuous observed time, reset by invalid input |
| Sequence settle / wait / observe | 800 / 4000 / 1200 ms | Generic observation phases |
| Virtual resource lifetimes | 600 / 1400 ms | Independent in-memory expiry examples |

There are no PWM targets, servo mappings, relay numbers, UART endpoints, navigation coordinates or mission files. Channel 1 is only a generic capability probe in the lease wrapper, not a designated aircraft control input. The sequence captures the observed mode rather than hardcoding a vehicle mode number.

To try different host scenarios, create a model with a different table in a local test. Keep every model duration positive and below half the runtime epoch. ArduPilot scripting enablement/memory prerequisites belong to the exact target build; follow [official setup documentation](https://ardupilot.org/copter/docs/common-lua-scripts.html) in an isolated test environment. No complete parameter file is supplied.
