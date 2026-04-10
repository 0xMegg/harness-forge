# Handoff — 2026-04-10

## What Changed
- 2차 harvest pipeline E2E 테스트 + 5개 검증 시나리오 전체 PASS
- `run-harvest.sh` 버그 수정: Phase 3/5에서 config.json의 measurement.command 사용하도록 변경
- gotchas.md에 2개 규칙 추가:
  - "lint/test before LLM review" (auto-applied, score 10)
  - "context reset at 70%" (manually approved, score 6)
- 3개 pending 전부 승인 처리 (context reset, coherence audit, failure mode tuning)
- 첫 evaluation 기록 생성 → internal feedback source 활성화

## Current State
- Baseline: 65/100
- `src/.claude/rules/gotchas.md` — 7개 규칙
- `harvest/.seen.json` — 18 items
- `harvest/reports/20260410-105521.md` — full report
- `outputs/evaluations/20260410-harvest-e2e.md` — 첫 evaluation

## Bugs Fixed
- `run-harvest.sh` Line 347, 434: config.json의 measurement.command를 사용하도록 수정 (이전: --target 없이 호출 → 32점 측정 오류)

## What's Next
- [ ] 변경사항 커밋
- [ ] `scripts/audit-coherence.sh` 작성 (승인된 Pending #2)
- [ ] fitness-filter examples에 counterexample 추가 (승인된 Pending #3)
- [ ] `build-template.sh` 실행하여 target repo 반영
- [ ] harness-report 점수 체계 개선 검토 — 규칙 내용 추가 시 점수 변동 없는 문제
