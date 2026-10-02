# Confirmed portfolio scope — 2026-10-02

## Goal, evidence and constraints

Create a public engineering project grounded in the owner's supplied Lua work without publishing employer material. Two downloaded snapshots contain one substantive ArduPilot Lua file and one template-only repository. Direct publication rights and historical test outcomes are not established. Therefore independently implement three focused demonstrations of the single file's generic mechanisms; do not represent them as separate historical projects.

Keep all source URLs, source names, original comments, identifiers, operating constants, control mappings, archive evidence and original history outside publication. Do not modify or execute source files. Use read-only firmware wrappers and a virtual backend. No hardware, flight, network-configuration or production action is included.

## Verifiable stages

| Stage | Files / notes | Completion check |
| --- | --- | --- |
| Audit | `docs/source-audit.md`; local-only hashed inventory | Both ZIP containers checked; one Lua file individually assessed, template excluded. |
| Implementation | Three wrappers and four modules | Sensor qualification, guarded phases and confirmed virtual release; no firmware control writes. |
| Validation | `tests/run.lua`, CI, API references | Syntax plus behavioral/fault suite on Lua 5.4 and stock 5.3.5 float32; actual firmware tests explicitly unperformed. |
| Review and publish | Full staged tree and fresh history | Check secrets/private data, original-text reuse, local link targets and noreply metadata; normal push to main; make reviewed repository public. |
| Profile | `lolpul/lolpul` README and record/memory | Add truthful UAV repository link, commit/push and verify remote content. |
| Website preparation | Existing project/link components and link expectations | Accurate repository label, local checks, documented diff and backup; no deployment. |

## Acceptance

An interviewer can inspect error/state/ownership reasoning without knowing the source project. Public claims distinguish source-observed mechanisms, demo additions, host results and proposed physical validation. Final receipts include URLs, commits, exclusions, independent rewrites, confidentiality categories and recommended interview examples.
