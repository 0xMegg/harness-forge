# Epic Guide (v5)

The reference document for creating and executing Epics.
Covers when to use Epics, how to decompose them, and what changed in v5.

---

## What is an Epic

An Epic is a feature-level unit of work that cannot be completed as a single Task.
It involves modifications across multiple files, entangles multiple concerns (data/logic/UI),
and requires multiple Plan -> Develop -> Review cycles to complete.

## When to Use an Epic

| Situation | Choice |
|------|------|
| 1-2 files modified, single concern | A single Task is sufficient |
| 3-5 files modified, one feature | A single Task, but Planner writes a plan first |
| 6-9 files modified, single concern | **Epic Lite** (single Task without Stages) |
| 6-9 files modified, multiple concerns | **Decompose into Epic** |
| 10+ files modified | **Decompose into Epic** (Stages required) |
| DB schema + API + UI all change together | **Decompose into Epic** |
| "Just this one thing" but the description exceeds 3 lines | Likely an Epic |

When in doubt, start with an Epic. An Epic with only 1 Slice automatically behaves like a single Task.

### Epic Lite
Opus 4.6 can maintain consistent builds for 2+ hours.
For fewer than 10 files + single concern, handle it as a single Task without Stage decomposition.

**Epic Lite conditions:**
- 6-9 files modified
- Single concern (data + logic + UI all belong to one feature)
- No external dependency changes

**Not Epic Lite (Full Epic required):**
- 10+ files
- 2+ concerns (e.g., auth + payment change simultaneously)
- DB migration + API + UI can fail independently

This judgment is made by the Planner. If scope grows mid-way through an Epic Lite, convert to a Full Epic.

## Epic Decomposition Principles

### 1. Slice by Layer Order

The safest decomposition direction is bottom-up:

```
Stage 1: Data layer (schema, migrations, models)
Stage 2: Logic layer (services, repositories, APIs)
Stage 3: UI layer (components, routes, screens)
Stage 4: Integration tests + wrap-up
```

This order is strong because upper layers depend on lower layers.
You can't write APIs without data, and you can't write UI without APIs.

### 2. Files Must Not Overlap Within the Same Stage

This is the sole, absolute rule for parallel execution.

```
Stage 2 (parallelizable):
  Slice A: src/api/auth.ts, src/services/auth.ts
  Slice B: src/api/profile.ts, src/services/profile.ts
  -> No file overlap, so parallel is OK
```

```
Stage 2 (not parallelizable):
  Slice A: src/api/auth.ts, src/utils/validation.ts
  Slice B: src/api/profile.ts, src/utils/validation.ts
  -> validation.ts overlaps, so they cannot be in the same Stage
```

When files overlap, choose one of two options:
- Extract the shared file into a separate Slice and execute it first (Stage separation)
- Place the two Slices in different Stages for sequential execution

### 3. Slice Size Guidelines

| Criterion | Recommendation |
|------|------|
| Number of files modified | ~5 or fewer |
| Estimated implementation time | Completable within 1 session |
| Testing | Independently verifiable |
| Review | Small enough to read the diff at a glance |

If a Slice is too large, the Review becomes superficial.
If a Slice is too small, session switching costs outweigh the benefits.

### 4. Make Dependencies Explicit

Always fill in the `Depends on:` field for each Slice.
Being specific like "auth.ts from Slice 2" rather than "entire previous Stage"
helps identify the blast radius quickly when failures occur.

---

## What Changed in v5

### Parallel Stage Integrated Commits

In v4, the Reviewer attempted `git commit + push` for each parallel Slice.
The first Slice would push successfully, but the rest would fail because the remote was ahead.

In v5:
- Parallel Slices run with `--no-commit` -> Reviewer does not touch git
- When all Slices in a Stage are complete, `commit_stage()` creates an integrated commit
- Commit message: `feat: Stage N — slice1 summary + slice2 summary + ...`
- Sequential execution (single Slice) works as before — Reviewer commits directly

```
Stage 1 (parallel):
  Slice A -> Plan -> Develop -> Review (no commit) ✓
  Slice B -> Plan -> Develop -> Review (no commit) ✓
  -> commit_stage(): git add -A -> commit -> push ✓ (all Slices included)
```

### More Specific Verification Plans

The following have been added to each Slice's verify.md:
- **Completion Criteria**: Coordinates that ensure both the model and humans see the same endpoint
- **Constraints**: Modification restrictions like "do not modify tests"
- **Confidence level**: HIGH / MEDIUM / LOW

At the Epic plan stage, completion criteria for each Slice must be clearly stated.
Not "Done when: it works" but "Done when: error message shown on empty form submit + tests pass".

### Evaluation Loop

After each Slice (Task) is completed, 5 key metrics are recorded using `templates/evaluation.md`:
Success rate, human edit volume, time, tokens/cost, failure types.

At the Epic level, per-Slice evaluations are aggregated to analyze recurring failure patterns.
If the same type of failure occurs 2+ times, it gets reflected in `rules/gotchas.md` or Skill Gotchas.

### Policy Document References

When writing an Epic plan, check the following:
- `context/access-policy.md` — Does this Epic include any work requiring human approval?
- `context/mcp-policy.md` — Is external service integration needed? Is it on the allowlist?

---

## Multi-Repo Workspaces

When the workspace root has no `.git/` and subdirectories (e.g., `backend/`, `frontend/`) are each independent git repos.

### commit_stage() Behavior
- First checks if the workspace root is a git repo
- If not a git repo, scans immediate subdirectories for those with `.git/`
- Commits and pushes independently in each repo that has changes
- Adds `[repo-name]` prefix to commit messages: `feat: Stage 1 [backend] — auth API`

### Planner Considerations
- Prefix repo names in Slice Files fields: `backend/src/api/auth.ts`
- Specify the target repo with a `**Repo:**` field in each Slice
- The file overlap rule within the same Stage applies across the entire workspace (not per repo)
- Slices that modify only different repos are safe for parallel execution
- Cross-repo dependencies (e.g., API change -> UI update) should be separated into different Stages

### Reviewer Considerations
- Independently run git status -> add -> commit -> push in each repo
- Record commit hashes from each repo in the handoff
- Do not run `git` commands from the workspace root

### Deploy Hook
- If `scripts/deploy-hook.sh` exists and is executable, it runs automatically after each Stage commit
- Argument: stage number (`$1`)
- Failures do not block the Epic (non-blocking)

### Single Repo Workspace
- Works exactly the same as before. No changes.

---

## How to Write an Epic Plan

### Pre-Start Checklist

- [ ] Have you read `handoff/latest.md`? (Understand current state)
- [ ] Have you checked `context/decision-log.md`? (Avoid re-discussing past decisions)
- [ ] Have you checked `context/access-policy.md`? (Identify tasks requiring human approval)
- [ ] Have you read enough of the relevant code?

### Epic Plan Structure

Follow `templates/epic-plan.md`, but the 4 essentials are:

1. **Goal**: What state will this feature be in when complete (2-3 sentences)
2. **Stages & Slices**: Decomposed by layer order, no file overlap
3. **Done when**: Specific completion criteria for each Slice (detailed enough to write in verify.md)
4. **Rollback Strategy**: How far to roll back if you need to abandon mid-way

### Traits of a Good Epic Plan

- Reading just the Slice descriptions gives the Developer a clear sense of what to build
- Files listed in each Slice do not overlap (within the same Stage)
- Completion criteria are measurable (tests, visual confirmation, lint passing)
- If Open Questions remain, the affected Slice is deferred to a later Stage

### Signs of a Bad Epic Plan

- Only says "implement it" with no completion criteria
- A single Slice touches 10+ files
- Slices in the same Stage modify shared files
- There is a "everything else" Slice (scope is unclear)
- Open Questions exist but are placed in the first Stage

---

## How to Execute

### Automatic Execution (Recommended)

```bash
# Epic decomposition + automatic per-Stage execution
./scripts/run-epic.sh "Epic 1 — User Authentication System"

# Automatically detects and reuses existing Epic plan
./scripts/run-epic.sh 1
```

Execution order:
1. `/plan Epic N` -> generates epic plan (`outputs/plans/epic-N-plan.md`)
2. Stage & Slice parsing
3. Per-Stage execution:
   - Single Slice -> sequential (Reviewer commits)
   - Multiple Slices -> parallel (`--no-commit` + Stage integrated commit)
4. All Stages complete -> EPIC COMPLETE

### Manual Execution

```bash
# 1. Create Epic plan
/plan Epic 1 — User Authentication System

# 2. Execute each Slice in order
/plan Task 1 — Signup DB Schema
/develop Task 1 — Signup DB Schema
/review Task 1 — Signup DB Schema

/plan Task 2 — Signup API
/develop Task 2 — Signup API
/review Task 2 — Signup API
```

Manual execution is for when fine-grained control is needed.
When you want to change direction mid-way, re-do a specific Slice, or run sequentially instead of in parallel.

### Failure Recovery

```
If Slice B fails in Stage 2:

1. Check logs: /tmp/project-name-run/task-slice-1/stdout.log
2. If REQUEST_CHANGES:
   /develop "Slice B — fix REQUEST_CHANGES"
   /review "Slice B — re-inspect"
3. After fixing, continue with remaining Stages:
   ./scripts/run-epic.sh 1  (reuses already completed plan)
```

---

## Epic Plan Example

```markdown
# Epic Plan

## Epic
Epic 1 — Signup Feature

## Goal
Users sign up with email/password, and upon signup are immediately logged in and navigated to the main screen.

## Context
- User need: Currently only guest mode is available, data cannot be saved
- Related docs: Feature 1 in docs/project-plan.md
- Dependencies: Supabase Auth setup complete

## Stages & Slices

### Stage 1
#### Slice 1: DB Schema + RLS
- **What:** users table, profiles table, RLS policies
- **Files:** supabase/migrations/001_auth.sql
- **Depends on:** (none)
- **Done when:** Migration succeeds + RLS tests pass

### Stage 2
#### Slice 2: Auth Service
- **What:** Signup + Login + Logout API
- **Files:** src/services/auth_service.dart, src/models/user.dart
- **Depends on:** Stage 1 (users table)
- **Done when:** Unit tests pass (signup/login/logout)

#### Slice 3: Auth State Management
- **What:** AuthProvider + login state detection
- **Files:** src/providers/auth_provider.dart
- **Depends on:** Stage 1 (users table)
- **Done when:** Provider tests pass

### Stage 3
#### Slice 4: Signup Screen
- **What:** Email/password input form + validation + error display
- **Files:** src/screens/signup_screen.dart, src/widgets/auth_form.dart
- **Depends on:** Slice 2 (auth_service), Slice 3 (auth_provider)
- **Done when:** Error on empty form submit + successful signup on valid input + navigation to main screen

## Epic Acceptance Criteria
- [ ] Can sign up with email/password
- [ ] Auto-login after signup + navigate to main
- [ ] Empty value/duplicate email error handling
- [ ] lint + test pass

## Open Questions
- Social login is not included in this Epic (separate Epic)

## Rollback Strategy
- If only Stage 1 is complete: Keep migrations, revert everything else
- If Stage 2 is complete: Keep APIs, UI-only revert is possible
```

In this example, Slice 2 and Slice 3 in Stage 2 have no file overlap, so they run in parallel.
Slice 4 in Stage 3 depends on both, so it must run after Stage 2 is complete.

### Multi-Repo Example

In multi-repo workspaces, add the `**Repo:**` field and prefix file paths with the repo name:

```markdown
### Stage 2
#### Slice 2: Auth API
- **What:** Signup + Login API
- **Repo:** backend
- **Files:** backend/src/services/auth.ts, backend/src/routes/auth.ts
- **Depends on:** Stage 1
- **Done when:** API tests pass

#### Slice 3: Auth UI
- **What:** Login screen
- **Repo:** frontend
- **Files:** frontend/src/pages/login.tsx, frontend/src/hooks/useAuth.ts
- **Depends on:** Stage 1
- **Done when:** Login form displays + API integration works
```

Slices 2 and 3 modify only different repos, so they can run in parallel within the same Stage.
