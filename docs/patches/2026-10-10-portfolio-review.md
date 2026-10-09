# Engineering portfolio review — 2026-10-10

## Intent and scope

Make the existing public engineering evidence quick to assess and reproduce, with accurate scope and maturity. Existing implementation stays reviewable. Independent read-only observers and virtual ownership; MIT only for demonstration source.

## Changes and decisions

README review navigation, dated verification and compact project memory. Existing diagrams and screenshots are retained. No private original code, new implementation, license or visibility change is part of this patch.

## Verification

36 host tests in both int64/float64 and int32/float32 Lua5.3.5; syntax passed; no SITL/HIL/bench/flight. Changed Markdown targets/whitespace and redacted publication diff were reviewed. Hosted run results are attached to the review PR; projects without workflows do not claim Actions success. No production, external messaging or hardware actions occurred.

## Rollback and follow-up

Timestamped original files and manifest remain in the private ignored career-materials backup directory. Reverse this focused documentation commit with an ordinary revert if required; restore any separately changed metadata from its saved snapshot. Do not rewrite Git history. Limits listed in README/verification remain open; new code/IP/access decisions require owner approval.
