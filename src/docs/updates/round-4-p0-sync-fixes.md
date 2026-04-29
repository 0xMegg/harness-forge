---
hash: round-4-p0-sync-fixes
date: 2026-04-29
severity: P0
type: fix
breaking: false
---

# [P0] fix: round 4 P0 sync blockers

## Summary
Fixes two downstream sync blockers found after forge round 3: newly added phase wrapper/regression scripts were not classified in `.harness-manifest`, and `upgrade-harness.sh` applied `{{PROJECT_NAME}}` substitution too broadly across managed markdown/script files.

## Commits
- `<pending>` round 4 P0 sync blockers (rename this file to the final forge short hash after commit)

## Changes
- `src/.harness-manifest` — adds `scripts/run-plan.sh`, `scripts/run-develop.sh`, `scripts/run-review.sh`, and `scripts/check-harness-regression.sh` to `[managed]`.
- `src/scripts/upgrade-harness.sh` — limits `{{PROJECT_NAME}}` post-copy substitution to runtime files that actually need project-specific names and escapes replacement text for sed.
- `src/docs/updates/INDEX.md` — records this downstream-facing P0 fix.

## Manifest classification
- `scripts/run-plan.sh`, `scripts/run-develop.sh`, `scripts/run-review.sh`, `scripts/check-harness-regression.sh` → `[managed]`
- `scripts/upgrade-harness.sh` → `[managed]`

## Why
Round 3 introduced the phase wrappers and regression gate, but the manifest did not list four new files, so downstream projects would not install them during `upgrade-harness.sh --apply`. Separately, the placeholder substitution added for `/task` monitoring applied to every managed `.md`/`.sh`, including historical `docs/updates/**` examples and upgrade metadata. That made sync output noisy and could corrupt documentation literals.

## Downstream impact
- Projects receiving round 3 now install the phase wrappers and regression gate during normal harness upgrade.
- `{{PROJECT_NAME}}` remains substituted in runtime files such as `.claude/commands/task.md`, `scripts/run-task.sh`, `scripts/run-epic.sh`, and role templates.
- `docs/updates/**` keeps literal placeholder examples intact.

## Verification
- `bash -n src/scripts/upgrade-harness.sh` — pass
- `bash -n src/scripts/check-harness-regression.sh` — pass
- `bash src/scripts/check-harness-regression.sh` — pass
- Temporary downstream smoke: `upgrade-harness.sh --apply` installs the four missing managed scripts, preserves `{{PROJECT_NAME}}` in `docs/updates/24070b5.md`, and substitutes a slash/ampersand project name in `.claude/commands/task.md`.

## Related
- `outputs/reports/session-report-2026-04-29.md`
- `src/docs/updates/e2ee114.md`
