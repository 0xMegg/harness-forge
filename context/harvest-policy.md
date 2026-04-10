# Harvest Policy

Policy for applying trends collected by the harvest pipeline to the project.

## Auto-Apply (no human approval needed)
Auto-apply when **all** of the following conditions are met:
- change_type: `rule` or `scaffold-rule`
- fitness score >= 7
- risk = low
- harness-report score does not decline (Gate 2 passed)

Auto-apply targets:
- Adding Known Pitfalls to `.claude/rules/gotchas.md`
- Adding entries to existing rule files (api.md, frontend.md, testing.md, git.md)

## Requires Approval (human confirmation needed)
- change_type: `new-skill` (creating a new skill directory)
- change_type: `hook` (.claude/hooks/ or settings.json changes)
- change_type: `config` (CLAUDE.md or config file changes)
- risk: `medium`
- fitness score 6 (borderline)

Approval process:
1. Save proposal to `harvest/applied/pending-*.json`
2. Show pending items in `/harvest status`
3. User applies via `/harvest apply` or manual confirmation

## Blocked (never auto-applied)
- change_type: `delete` (deleting rules, skills, or hooks)
- risk: `high`
- Changes that cause harness-report score decline
- Changes that modify existing behavior (modifications/deletions, not additions)

## Source Trust Levels
| Source | Trust | Notes |
|--------|-------|-------|
| Internal feedback (evaluation.md) | High | Project's own learning |
| Manual input (/harvest validate) | High | User's judgment |
| WebFetch (GitHub trending) | Medium | Popular but unverified |
| WebSearch | Medium | Search result quality varies |

## Human Review Gate
- **validate mode**: pauses after Phase 2 (fitness filter) for human review
  - Shows fitness score, proposal details, target file
  - User runs `/harvest judge` to continue to Phase 3-5
  - `--auto` flag skips the review (for future automation when criteria are established)
- **full mode**: no pause (external collection runs unattended through all phases)
- **Concreteness pre-filter**: proposals must specify target file, triggering condition, and exact action — abstract proposals are rejected before scoring

## Rollback
- Phase 3.5 sandbox: `git stash` → temp apply → measure → `git checkout -- .` → `git stash pop`
- Post-apply regression: create `revert: harvest — [description]` commit
- `git reset --hard` is prohibited (settings.json deny list)
