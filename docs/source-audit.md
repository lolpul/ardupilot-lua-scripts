# Sanitized source assessment — 2026-10-02

## Inventory and provenance

The owner supplied two downloaded source snapshots. Both ZIP containers passed their integrity checks; one retained a browser temporary-download extension. Files were read directly from the archives without executing them, modifying them or importing source history. A local-only inventory records archive/file hashes. Neither archive contains a license granting republication rights or project-local agent/memory instructions.

| Source item | Purpose / APIs | Portfolio value | Confidentiality / decision |
| --- | --- | --- | --- |
| Source A: one Lua file | ArduPilot fixed-wing launch assistance: scheduled states, armed/mode checks, AHRS acceleration magnitude, temporary RC ownership and release. Uses millis(), arming:is_armed(), vehicle:get_mode(), rc:get_channel(), RC_Channel:set_override(), ahrs:get_accel(), vector components, gcs:send_text(), pcall and basic Lua math. | Strong evidence of embedded/UAV state coordination and output-lifecycle reasoning. | Rights unconfirmed. Contains vehicle/control assumptions and operational tuning; direct publication rejected. Generic observation/ownership demonstrations are feasible. |
| Source A: README | Describes launch workflow and operator conditions. | Useful as intent, but must be checked against code. | Original naming and aircraft-specific description excluded. Not used as evidence that every described condition was implemented. |
| Source B: README only | Standard GitLab getting-started template, with an internal repository reference. No Lua files. | No implementation evidence. | Entire snapshot excluded from examples; internal reference is not copied. |

Only one Lua file was available to audit. No UART/GPIO/relay/direct MAVLink/parameter API implementation or flight-test evidence was present in these snapshots. The archive contents do not establish authorship, historical deployment or permission to publish employer files; the owner's experience is not independently certified by this review.

## Observed concerns in the original Lua behavior

- Some cleanup calls do not check whether release succeeded before advancing to a completed/released state. This can make the reported state disagree with the ownership outcome.
- Time is converted before signed numeric subtraction, with no wrap-safe elapsed-time policy. Long uptime and interpreter number representation need explicit treatment.
- Missing acceleration prevents detection but can leave the waiting control state in place until its timeout. This is a policy concern, not proof of a real incident.
- A README-described RC consent condition is not read by the inspected Lua implementation. Documentation alone is insufficient evidence for that feature.
- Direct RC ownership is safety-sensitive. Its behavior depends on the actual firmware timeout, mappings and receiver configuration, none of which was independently verified here.

The source was not fixed or tested on hardware. These observations inform demonstration design and do not establish flight readiness or a complete safety review of the original system.

## Independent demonstrations selected

1. **Inertial event observer:** sensor-read validation and event qualification. Hysteresis/dwell are new demonstration improvements.
2. **Guarded sequence observer:** arming/mode gating, timed phases, timeout and cancellation. Output actions are replaced by observation.
3. **Virtual control lease:** temporary ownership and cleanup lifecycle. Generic resources and a boolean-acknowledged virtual backend are new demo choices; no RC write is included.

These are three focused demonstrations derived from one generic behavioral assessment, not three separate source projects. Layout, names, comments, constants and models were written independently. No original code block, README, configuration or history was copied into the public tree.

## Publication exclusions

The original Lua file and both original READMEs remain unpublished. Omitted categories include internal source location/name, original comments and identifiers, fixed mode/control mappings, PWM targets and operating timing/threshold values. Source B's internal link is excluded. No credential, operational mission, coordinates, device serial or private test log was found in the supplied file contents; none was invented or added to the demonstrations. Absence in these snapshots does not assert absence in the original repository history, which was not supplied.
