# Verification — 2026-10-10

WSL Ubuntu 24.04; checksum-verified stock Lua 5.3.5 host build: **36 tests passed** with int64/float64. The retained Lua 5.3.5 `LUA_32BITS` build also passed **36 tests**, printing int32/float32 configuration. Syntax checks passed for scripts and tests.

Reproduce with `lua tests/run.lua`; [Actions](https://github.com/lolpul/ardupilot-lua-scripts/actions/workflows/checks.yml) contains normal and 32-bit Lua checks. Earlier Lua 5.4.6 results remain historical evidence in [testing](testing.md).

These are host/mock results. No firmware build, SITL, HIL, hardware bench, arming, actuator output or flight validation was performed. The virtual backend cannot establish physical control release or a real watchdog/failsafe.
