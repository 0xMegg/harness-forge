# Handoff — 2026-04-29 (round 4 P0 sync blockers)

## 현재 task
`outputs/reports/session-report-2026-04-29.md` 의 권장 옵션 1 수행: 다운스트림 sync 차단 P0 2건만 닫고 META 세션을 확장하지 않는다.

### 완료
- **P0 #1 — `upgrade-harness.sh` placeholder 치환 범위 축소**: 모든 managed `.md/.sh` 에 blanket `{{PROJECT_NAME}}` substitution 하던 로직을 runtime allowlist 로 제한. `docs/updates/**` 의 historical literal 보존. sed replacement escape 추가로 `/` / `&` 포함 project name 도 안전 처리.
- **P0 #2 — round 3 신규 파일 manifest 등록**: `src/.harness-manifest [managed]` 에 `scripts/run-plan.sh`, `scripts/run-develop.sh`, `scripts/run-review.sh`, `scripts/check-harness-regression.sh` 추가.
- **검증**: `bash -n src/scripts/upgrade-harness.sh`, `bash -n src/scripts/check-harness-regression.sh`, `bash src/scripts/check-harness-regression.sh` 통과. 임시 downstream smoke 에서 4개 파일 설치 + docs literal 보존 + slash/ampersand project name substitution 확인.
- **build-template**: `bash scripts/build-template.sh` 통과. target template `../claude-code-harness-template/` 에 manifest/update/upgrade-harness 변경 전파.
- **Claude second review**: 계획 단계에서 manifest/upgrade 지점 확인 조언 반영. 구현 리뷰 결과 blocker 없음, 승인.
- **문서**: `src/docs/updates/cee3b30.md` update doc + INDEX row 추가.

### 남은
- **push/전파**: 사용자 승인 후 forge push → template hook 확인.

## 다음 task 후보
1. **IMPL 트랙 복귀**: honbabseoul Slice 1 review / divebase Task 52.1 review 등 downstream 실무 마무리.
2. **Round 4 본체는 별도 META 박스**: kody G1/G2/G3, honbab #2/#3, A 후보 평가는 이번 scope 밖.
3. **A4 OPERATING-MODE**: IMPL/META 트랙 분리와 error budget 정책은 별도 세션에서 평가.

## Open Issues
- forge-deploy hook 이 src/ 변경 없는 commit 에도 target repo 에 `.harness-version` timestamp-only commit 생성 (noise).
- 병렬 spawn 자식 silent 0 종료 root cause (honbabseoul `/tmp/honbabseoul-run/1-20260425-133941/task-slice-3/` 로그 보존).
- multi-repo workspace 의 develop-noop guard 확장.

## 참조
- `outputs/reports/session-report-2026-04-29.md`
- `src/docs/updates/e2ee114.md`
- `src/docs/updates/cee3b30.md`
