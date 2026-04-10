# Harvest Policy

Policy for applying trends collected by the harvest pipeline to the project.

## Claude 1차 판단 기준 (추천 등급)

### RECOMMEND (Claude가 적용 추천)
- change_type: `rule` or `scaffold-rule`
- fitness score >= 7
- risk = low
- harness-report score does not decline (Gate 2 passed)

추천 대상:
- Adding Known Pitfalls to `.claude/rules/gotchas.md`
- Adding entries to existing rule files (api.md, frontend.md, testing.md, git.md)

### REVIEW (Claude가 검토 요청)
- change_type: `new-skill`, `hook`, `config`
- risk: `medium`
- fitness score 6 (borderline)

### REJECT (Claude가 거절 추천)
- change_type: `delete`
- risk: `high`
- harness-report score decline
- modifications/deletions to existing behavior

모든 등급은 사용자 2차 판단에서 최종 결정

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

## Execution Mode
- **항상 Claude 대화 내에서 직접 실행** — subprocess (`claude -p`) 사용하지 않음
- `scripts/run-harvest.sh`는 구조 참조용으로만 유지
- `/harvest` 스킬이 Phase 0-5를 대화 내에서 직접 수행

## 2단계 판단
- **1차 (Claude)**: 수집 → concreteness gate → 5-axis 채점 → Gate 2 측정 → 적용 판단 초안
- **2차 (사용자 + Claude)**: Claude가 판단 결과를 요약 제시 → 사용자와 함께 최종 승인/거절/수정 결정
- 모든 적용은 2차 판단을 거친 후에만 실행 (auto-apply 포함)

## Concreteness Pre-Filter
- proposals must specify target file, triggering condition, and exact action
- abstract proposals are rejected before scoring

## Rollback
- Phase 3.5 sandbox: `git stash` → temp apply → measure → `git checkout -- .` → `git stash pop`
- Post-apply regression: create `revert: harvest — [description]` commit
- `git reset --hard` is prohibited (settings.json deny list)
