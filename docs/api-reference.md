# API reference checked for the demo

Reference revision: [`cafe67457776027a1bad6e165c409828c1a851e5`](https://github.com/ArduPilot/ardupilot/tree/cafe67457776027a1bad6e165c409828c1a851e5), checked 2026-10-02. This is an upstream API reference, not a tested aircraft firmware release.

| Binding / behavior | Official reference | Use here |
| --- | --- | --- |
| `millis()` and unsigned userdata arithmetic | [Generated Lua documentation](https://github.com/ArduPilot/ardupilot/blob/cafe67457776027a1bad6e165c409828c1a851e5/libraries/AP_Scripting/docs/docs.lua) | Subtract raw times, convert only the difference. |
| AHRS, Vector3f, arming/mode reads, GCS text | [Generated Lua documentation](https://github.com/ArduPilot/ardupilot/blob/cafe67457776027a1bad6e165c409828c1a851e5/libraries/AP_Scripting/docs/docs.lua) | Guarded reads and status messages. |
| `get_accel()` uses primary accelerometer data | [AHRS header](https://github.com/ArduPilot/ardupilot/blob/cafe67457776027a1bad6e165c409828c1a851e5/libraries/AP_AHRS/AP_AHRS.h) | Magnitude observation; no gravity subtraction or freshness claim. |
| Lua `rc:get_channel()` one-based wrapper | [RC channel header](https://github.com/ArduPilot/ardupilot/blob/cafe67457776027a1bad6e165c409828c1a851e5/libraries/RC_Channel/RC_Channel.h), [binding description](https://github.com/ArduPilot/ardupilot/blob/cafe67457776027a1bad6e165c409828c1a851e5/libraries/AP_Scripting/generator/description/bindings.desc) | Probe channel 1, with no control assignment or override call. |
| Scripting module search path | [Lua configuration](https://github.com/ArduPilot/ardupilot/blob/cafe67457776027a1bad6e165c409828c1a851e5/libraries/AP_Scripting/lua/src/luaconf.h), [module-path binding](https://github.com/ArduPilot/ardupilot/blob/cafe67457776027a1bad6e165c409828c1a851e5/libraries/AP_Scripting/lua_bindings.cpp) | Install modules below the scripting directory's `modules/`. |

[ArduPilot scripting setup and limitations](https://ardupilot.org/copter/docs/common-lua-scripts.html) describe scheduling, memory and the Lua runtime. Firmware features and bindings can differ by build. Check the exact vehicle/firmware before SITL or bench evaluation. Documentation review and mocked calls do not prove target compatibility.
