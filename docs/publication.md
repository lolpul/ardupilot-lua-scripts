# Publication receipt — 2026-10-02

## Published artifacts

- Public repository: [lolpul/ardupilot-lua-scripts](https://github.com/lolpul/ardupilot-lua-scripts), default branch `main`.
- Implementation commit: [`a2458f45a2e137e62035089da9b54b47d822d51d`](https://github.com/lolpul/ardupilot-lua-scripts/commit/a2458f45a2e137e62035089da9b54b47d822d51d).
- Profile update: [`869856eb69251a57c419edee49903c8eba316804`](https://github.com/lolpul/lolpul/commit/869856eb69251a57c419edee49903c8eba316804).
- [Implementation CI](https://github.com/lolpul/ardupilot-lua-scripts/actions/runs/36990047503): both Ubuntu Lua 5.3 and stock Lua 5.3.5 int32/float32 jobs passed.

Three independently written demonstrations are published: inertial event observer, guarded sequence observer and virtual control lease. They explain mechanisms from one reviewed source file rather than claiming three historical projects. Host tests and additions to demonstration behavior are explicitly distinguished from unperformed firmware/physical validation.

## Review and remote checks

The initial 26-file staged tree was reviewed for private source names/locations, IP addresses, UUIDs, key/token patterns, sensitive artifacts, unknown hosts, original comment reuse and firmware control writes. No scan findings remained. Twenty local document links resolved. Scans complement the manual scope and content review; they are not a guarantee against every possible confidential detail.

Both original archive hashes remained unchanged. The original Lua and both original READMEs are excluded, along with their operational values, control mapping, naming and internal location. No source history was imported. Original repository history was not supplied and is not claimed to have been audited.

GitHub's remote tree matched every initial local blob. Anonymous GitHub metadata confirmed public visibility/main, and anonymous raw README bytes matched local committed README for both the examples and profile. Profile remote tree matched all five local blobs. Commits use GitHub noreply identity and normal pushes, with no force push.

This subsequent documentation receipt updates status only. Its final head and tree are verified after pushing; that exact SHA is provided in the task handoff and local project note rather than embedded recursively in its own commit.

## Website preparation

A local patch over portfolio source commit `eb271b88875fbece1b3ef41c63629e83a76b6be5` adds the UAV repository and an accurate `GitHub examples` label to home/case links, with a short independent-demo/validation explanation. Existing three showcase labels remain unchanged.

Website lint, production build, TypeScript and two relevant existing Playwright tests passed. The patch includes source, existing test updates, memory and a change record. It is **uncommitted and not pushed or deployed**. Production state was not inspected or altered in this task.

## Backups and next work

Timestamped affected-file copies/manifests are under each local project's ignored `.backups/`; private archive receipts and test tooling stay in ignored `.local/`. Obsidian project notes link the repository, technical memory and change records without private source details. Normal follow-up commits can revert published demo/profile changes. Restoring affected website files from its backup can abandon local preparation after checking for later user edits.

SITL/HIL/bench/flight, real output ownership, hardware watchdog validation and aircraft-specific deployment remain unperformed. No credential, network configuration, source-repository or physical-device change occurred.
