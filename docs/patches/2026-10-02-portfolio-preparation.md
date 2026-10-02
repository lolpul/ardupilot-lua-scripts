# ArduPilot portfolio preparation

## Intent and changes

Record the owner's publication scope, constraints and acceptance criteria before implementation. Added a specification draft, source-discovery status, compact project memory and ignores for local backups, sensitive configuration and operational artifacts. Added a matching Obsidian project note.

## Decisions

Example selection and implementation depend on an actual source audit. No unavailable source behavior is assumed. Public repository creation and profile integration wait for reviewed examples. Website preparation will need accurate source-example labeling and updates to its existing link expectations.

## Verification

Read-only local file inventories found no owner-authored Lua files in the inspected locations. `gh api user` confirmed the requested account; `gh repo view` found neither proposed new name. Existing profile and portfolio status/remotes/history/memory were inspected; both working trees were clean. `lua -v` reported 5.4.6. No code tests, SITL, bench or flight tests were performed.

## Rollback and external effects

All preparation files are new. A timestamped target manifest is in ignored `.backups/`; no existing user artifact was overwritten. No GitHub writes, commits, pushes, source-repository changes, hardware actions or production changes occurred.

## Unresolved

Need a local Lua source path or accessible repository URL. No file-specific audit, publication rights assessment or 3–6-example selection is possible yet.
