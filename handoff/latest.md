# Handoff — 2026-04-10 (Harvest Batch: 영상 분석 + user 3)

## What Changed
- 영상 분석 RTF + 사용자 추가 3건을 기반으로 5개 항목을 trend-harvester 파이프라인에 순차 투입.
- SDK 최적화 항목은 user 결정으로 **이번 배치에서 제외** → 5항목으로 축소.
- 파이프라인 규칙대로 각 항목마다 1차 판단(5축 채점) → 2차 사용자 승인을 거침.
- Item 1(MCP 예시)은 사용자 거절, 나머지 4개는 적용.
- 세션 시작 시 워킹트리에 남아 있던 미커밋 작업(run-task/run-epic dry-run/argparse refactor, commands/epic·task, harvest-policy)은 Item 5 적용 전에 별도 정리 커밋으로 분리.

### 적용 결과
| Item | 주제 | 결과 | 커밋 |
|------|------|------|------|
| 1 | MCP 실전 설정 예시 (1차) | 거절 (fitness 6/10, user 거절) | — |
| 2 | Context 예산·세션 분할 체크리스트 + `post-edit-size-check.sh` | 적용 (9/10) | `e47eb67` |
| 3 | Troubleshooting 가이드 + `scripts/diagnose.sh` | 적용 (9/10) | `a0a8e31` |
| 5 | 브랜치 격리 (run-task/run-epic + pre-commit-branch-check 훅 + git.md 재작성) | 적용 (9/10, PENDING 승인) | `3ebd5bf` |
| 4 | 병렬 overlap gate (상시) + worktree 격리 (opt-in) | 적용 (9/10, PENDING 승인) | `2539e38` |
| 1* | MCP 실전 설정 (재시도): `.mcp.json.example` + `mcp-check.sh` + mcp-policy 부록 | 적용 (9/10, schema 교정 후 재투입) | `96761ef` |

### 추가 커밋
- `3fce0fb` — 세션 전 미커밋 작업 정리 (dry-run + argparse refactor, commands 문구, harvest-policy)
- `bb79220` — README 1차 갱신 (Hardening Highlights)
- `faf54ed` (soft-reset됨) — Item 5 초기 혼합 커밋. 세션 전 미커밋 작업이 섞여 있어 2개로 분리 후 폐기.

## Current State
- Baseline: 65/100 (모든 항목 Gate 2 pass — harness-report 점수 체계상 `rules` 5/5, `hooks` 6/6 등 이미 포화 상태라 항목 추가로 점수 변동 없음. 이 문제는 handoff/latest 이전 판에서 이미 지적됨.)
- `src/.claude/rules/gotchas.md` — 7개 규칙 (변경 없음)
- `src/.claude/hooks/` — 6개 (기존 4개 + `post-edit-size-check.sh`, `pre-commit-branch-check.sh`)
- `src/docs/` — 기존 4개 + `troubleshooting.md` 신규
- `src/scripts/` — 기존 + `diagnose.sh`, `mcp-check.sh` 신규
- `src/.mcp.json.example` — 신규 스캐폴드 (filesystem, github)
- `src/context/mcp-policy.md` — New MCP Pre-Connection Checklist 부록 추가
- `.gitignore` — `.mcp.json` 제외 추가
- `harvest/applied/` — Item 1(재시도)/2/3/4/5의 applied JSON 기록
- `harvest/raw/` — 6개 raw entry (1차 MCP rejected 포함)
- Template 전파: `bash scripts/build-template.sh` → `../claude-code-harness-template/`

## What's Next
- [ ] `../claude-code-harness-template/`에서 template 업데이트 커밋 (build-template.sh는 sync만 하고 커밋은 target repo에서 별도 수행)
- [ ] 병렬 안정성 실전 검증: `HARVEST_PARALLEL_WORKTREE=1`로 Epic dry-run 실행해 worktree 경로 자체 테스트
- [ ] `scripts/audit-coherence.sh` 작성 (이전 handoff의 미완료 항목)
- [ ] fitness-filter examples에 counterexample 추가 (이전 handoff의 미완료 항목)
- [ ] harness-report 점수 체계 개선 — 규칙/스킬/훅 포화 상태에서도 개선이 반영되도록 가중치 재설계
- [x] Item 1(MCP 예시) 재투입 — `mcp-check.sh` 검증기 + `.mcp.json.example` 로 9/10 달성 (`96761ef`)
- [ ] SDK 최적화는 프로젝트별 별도 처리 (이번 배치 분리됨)

## Notes
- 이번 배치는 `harvest-policy.md` L45-47에 따라 subprocess (`claude -p`) 없이 Claude 대화 내 직접 수행.
- Item 4, 5는 "modifies existing behavior"라 auto-apply 차단 대상 → PENDING 경로 + 사용자 명시 승인 후 적용.
- pre-commit-branch-check 훅은 Claude PreToolUse Bash 레이어에서 동작 — shell에서 직접 실행한 `git commit`은 차단하지 않음. 필요 시 `.git/hooks/pre-commit`로 확장 가능.
- worktree 격리는 opt-in이라 기본 동작에 영향 없음. 활성화 시 `.harvest-wt/` 디렉토리가 잠시 생성됐다가 정리됨.
