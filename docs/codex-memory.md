# Project memory ? v3 ? 2026-10-02

- Purpose: public ArduPilot Lua engineering portfolio. Intended URL: https://github.com/lolpul/ardupilot-lua-scripts.
- Git: fresh main, new origin, no imported source history. Account lolpul verified; owner authorizes public visibility, focused commits/pushes and profile update. Repository created private during preparation; public release follows review.
- Evidence: two supplied ZIP snapshots passed integrity checks. One substantive Lua file; second snapshot contains only template README. No licenses, project agent files or source history supplied. Source files/repositories unchanged and never executed.
- Provenance boundary: original files, internal URLs/names, comments, mapping and operational constants excluded. Three newly written demonstrations explain mechanisms from one source example, not three historical projects. Do not add invented experience or UART/GPIO/MAVLink/parameter claims.
- Architecture: modules/portfolio_runtime.lua guards optional bindings and time; inertial/sequence/lease modules are plain-data models. Three scripts/*/main.lua wrappers read firmware state and report text. Lease backend is in-memory; no hardware output/arming/mode/parameter writes.
- Clock: unsigned userdata subtraction before conversion; logical epoch 65,536 ms for float32 precision; all durations < half epoch; long gaps invalidate. Lua channel capability reference is one-based in pinned upstream.
- Commands: lua tests/run.lua; luac -p <file>. CI checks Ubuntu Lua 5.3 and checksum-verified stock Lua 5.3.5 with LUA_32BITS.
- Verified locally: 36 behavioral/mocked-binding tests pass on Windows Lua 5.4.6 and stock Lua 5.3.5 with int32/float32 in local Linux development environment. Eight Lua files parse. Initial float32 rollover failures resolved with bounded epoch and checked by regression scenarios.
- Unperformed: actual modified ArduPilot runtime, SITL, HIL, bench, flight and real RC output/watchdog validation. API reference only: official upstream revision cafe67457776027a1bad6e165c409828c1a851e5, not deployed firmware.
- Documents: [confirmed spec](spec.md), [source assessment](source-audit.md), [architecture](architecture.md), [API references](api-reference.md), [testing](testing.md), [demo patch](patches/2026-10-02-engineering-examples.md).
- Integration: profile lolpul/lolpul gets a truthful repository link. Private website source lolpul/elisey-portfolio gets a local prepared link/label patch; no deployment or network changes.
- Backups: ignored .backups/ contains timestamped manifests and pre-change documents/code/note copies; .local/ contains private archive hash inventory and official reference/test tooling. Never stage either directory.
- Next: review complete staged manifest/diff and original-text/private-data exclusions; publish reviewed main, verify remote tree/CI/visibility, update profile, finish website checks and Obsidian receipt. No physical action is in scope.
