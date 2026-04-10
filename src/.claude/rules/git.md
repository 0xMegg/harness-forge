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
- 모든 task 작업은 `task/{id}` 브랜치에서 실행 — `run-task.sh`가 자동 생성·체크아웃
- Epic 실행은 `epic/{timestamp}` 브랜치에서 실행 — `run-epic.sh`가 자동 생성, parallel slice들은 epic 브랜치 상속
- main/master는 병합 전용 — 직접 커밋 금지 (`.claude/hooks/pre-commit-branch-check.sh`가 차단)
- APPROVE 후 스크립트가 main으로 fast-forward merge + 원격 push + task/epic 브랜치 삭제 (auto-merge)
- 긴급 우회: `HARVEST_ALLOW_MAIN=1` 환경변수 (인프라 정비 등 예외 상황)
- 멀티 레포 모드: 각 sub-repo에서 동일 규칙 적용 (scripts가 각 repo별로 branch 생성)

## Pull Requests (team mode):
- PR title follows commit message convention
- Include what changed and why in the description
- Self-review the diff before requesting review
