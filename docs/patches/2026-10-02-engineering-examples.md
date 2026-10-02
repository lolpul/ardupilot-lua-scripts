# Independent ArduPilot engineering demonstrations

## Intent and affected components

Show evidence-backed UAV scripting mechanisms without republishing the supplied original. Added three read-only wrappers, four plain-data/runtime modules, per-example explanations, architecture/API/testing/configuration documentation, MIT license and a behavioral CI suite. Replaced the source-access blocker and specification draft with the actual sanitized assessment and confirmed scope.

## Design and behavior

The supplied snapshots contain one substantial Lua file and a second template-only repository. Direct publication rights are unconfirmed, so all original files are excluded. Three demonstrations isolate inertial event handling, guarded phases and temporary ownership. Hysteresis, acknowledged virtual release, modular tests and bounded clock design are additions to the demonstrations rather than historical project claims.

The firmware boundary only reads AHRS/arming/mode/channel capability and sends text. No RC override, servo, motor, mode-change, arming or parameter-write command exists in production demo code. Lease resources live in a Lua table. Unknown data invalidates/cancels; failed cleanup retains ownership until acknowledgement.

## Verification

- Both source ZIP containers passed integrity checks; archives read in place and hashed locally, not extracted into the publication tree or executed.
- Eight Lua files parsed. Thirty-six tests pass with Windows Lua 5.4.6 and stock Lua 5.3.5 built with int32/float32.
- Float32 testing exposed numeric rollover/precision problems in an earlier draft. The final bounded-epoch clock plus unsigned subtraction resolves these; long-uptime/skipped-epoch/rollover tests pass.
- Official pinned upstream API review confirmed Lua one-based channel indexing, primary acceleration access and module search path. This is not firmware execution evidence.
- Source configuration/history and physical testing are excluded; SITL/HIL/bench/flight procedures are documented as unperformed.

## Rollback, publication and limits

Timestamped original document and later code snapshots are in ignored `.backups/`; private archive receipts and build tooling are in ignored `.local/`. Source repositories and downloaded archives remain unchanged. Git uses a new history and GitHub noreply identity. Reviewed code can be reverted with a normal follow-up commit; no force push is needed.

Public visibility, exact remote commits, CI results and profile integration are recorded in the later publication receipt. The website change is local preparation only. No hardware, credentials, network configuration or production service was changed.
