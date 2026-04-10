# Git Rules

## Commits:
- Message format: `type: Task N — short summary` (feat, fix, refactor, test, docs, chore)
  - Example: `fix: Task 3 — add error handling`
  - Example: `refactor: Task 5 — extract inline logic`
- One commit per Task (logical unit)
- Never commit secrets, .env files, or build outputs
- Lint/analyze must pass before committing
- Only the Reviewer commits (after APPROVE)

## Multi-Repo:
- If no `.git/` in workspace root, commit+push individually in each sub-repo
- Commit message: `type: Task N [repo-name] — short summary`
- Push each repo independently
- Record commit hashes from all repos in handoff
- Do not run `git` commands from workspace root

## Branches:
- Solo development: work directly on main — commit + push allowed
- Team collaboration: feature branch (`feat/short-description`) → PR → merge
- For large changes, use a branch even in solo mode

## Pull Requests (team mode):
- PR title follows commit message convention
- Include what changed and why in the description
- Self-review the diff before requesting review
