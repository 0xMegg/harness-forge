# P0 Sync Fix 결과 보고서 — 2026-04-29

- 위치: `/Users/mero/Dev/13.claude/templates/harness-forge`
- 범위: `outputs/reports/session-report-2026-04-29.md` 의 권장 옵션 1
- 목표: 다운스트림 sync 차단 P0 2건만 수정하고 META scope 확장을 중단
- 상태: 구현 완료, 검증 완료, Claude second review 승인, git 정리 대기

---

## 1. 작업 범위

이번 작업은 다음 2건으로 제한했다.

1. `upgrade-harness.sh` 의 `{{PROJECT_NAME}}` 과잉 치환 문제 수정
2. round 3 신규 파일 4개의 `.harness-manifest [managed]` 누락 수정

명시적으로 하지 않은 일:

- Round 4 후보 14건 전체 처리
- kody / honbab / divebase 다운스트림 실무 진행
- `OPERATING-MODE` / IMPL-META track 정책 흡수
- commit / push / template repo commit

---

## 2. 변경 내용

### 2.1 Manifest 누락 수정

파일: `src/.harness-manifest`

`[managed]` 섹션에 다음 4개 파일을 추가했다.

- `scripts/check-harness-regression.sh`
- `scripts/run-develop.sh`
- `scripts/run-plan.sh`
- `scripts/run-review.sh`

효과:

- round 3에서 추가된 phase wrapper와 regression gate가 downstream `upgrade-harness.sh --apply` 시 정상 설치된다.
- 기존에는 template에 파일이 있어도 manifest coverage gap으로 남아 downstream install이 빠질 수 있었다.

### 2.2 PROJECT_NAME substitution 범위 축소

파일: `src/scripts/upgrade-harness.sh`

기존 동작:

- managed `.md` / `.sh` 전체에서 `{{PROJECT_NAME}}`를 치환
- `docs/updates/**`의 historical example literal까지 치환될 수 있음
- `upgrade-harness.sh` 자기 자신의 설명/패턴 문자열도 치환 대상이 될 수 있음

수정 후 동작:

- `should_substitute_project_name()` allowlist 추가
- runtime에서 project name이 실제로 필요한 파일만 치환
- `docs/updates/**`와 `upgrade-harness.sh` 자기 자신은 치환 대상에서 제외
- sed replacement escape 추가로 `PROJECT_NAME`에 `\`, `&`, `|`가 있어도 안전하게 치환

allowlist 대상:

- `.claude/commands/task.md`
- `.claude/scripts/*.sh`
- `scripts/run-task.sh`
- `scripts/run-epic.sh`
- `templates/role-planner.md`
- `templates/role-developer.md`
- `templates/role-reviewer.md`

### 2.3 문서 갱신

추가/수정:

- `src/docs/updates/round-4-p0-sync-fixes.md`
- `src/docs/updates/INDEX.md`
- `handoff/latest.md`

주의:

- `round-4-p0-sync-fixes.md`는 provisional update doc이다.
- commit 시 최종 short hash가 확정되면 파일명을 `<short-hash>.md`로 rename하고 INDEX row도 같은 hash로 교체해야 한다.

---

## 3. Codex-Claude 협업 흐름

### 3.1 계획 단계

Codex가 먼저 session report와 관련 코드를 읽고 다음 구현 방향을 잡았다.

- blanket substitution 제거
- runtime allowlist 기반 substitution
- manifest에 누락 4개 파일 추가
- P0 2건 외 scope 확장 금지

Claude에게 계획 검토를 요청했다.

Claude 의견:

- `upgrade-harness.sh`의 self-substitution 지점 확인
- manifest `[managed]` 섹션의 기존 경로 규칙 유지
- 수정 전후 재현/검증 시나리오 확보
- `src/` 변경이므로 update doc + INDEX 동반 필요

반영 결과:

- allowlist 방식으로 self-substitution을 차단
- manifest는 기존 explicit script list에 같은 형식으로 삽입
- 임시 downstream smoke test를 추가로 수행
- provisional update doc과 INDEX row 작성

### 3.2 구현 리뷰 단계

구현 후 Claude에게 변경 범위와 검증 결과를 보고했다.

Claude 검토 결론:

> 최종 승인: git 정리 단계로 진행

Claude가 확인한 사항:

- 신규 4개 script가 `[managed]`에 정확히 등록됨
- wrapper 3개는 `{{PROJECT_NAME}}` 참조가 없으므로 allowlist 제외가 맞음
- runtime placeholder 필요 파일은 allowlist에 포함됨
- `upgrade-harness.sh` 자기 자신은 allowlist에서 제외되어 self-substitution 안전
- sed escape가 delimiter, backslash, ampersand를 커버
- `docs/updates/**` historical literal 보존
- update doc / INDEX / handoff 정합

Claude의 non-blocker note:

- `setup.sh`의 `FILES_TO_REPLACE`와 `upgrade-harness.sh` allowlist가 별도 표현이라 장기적으로 drift 가능성 있음
- 단, 현재 P0 scope 밖이므로 이번 작업에서는 손대지 않는 것이 맞음

---

## 4. 검증 결과

### 4.1 Syntax / regression

통과:

- `bash -n src/scripts/upgrade-harness.sh`
- `bash -n src/scripts/check-harness-regression.sh`
- `bash src/scripts/check-harness-regression.sh`

`check-harness-regression.sh` 결과:

- `bash -n` on `src/scripts/*.sh`: OK
- `shellcheck -S warning`: clean
- dry-run smoke for `Task` / `Slice`: pass

### 4.2 Temporary downstream smoke

임시 downstream project를 만들어 다음을 확인했다.

- `upgrade-harness.sh --apply` 실행 성공
- 신규 4개 managed script 설치됨
- `docs/updates/24070b5.md`의 `{{PROJECT_NAME}}` literal 보존됨
- `.claude/commands/task.md`의 runtime placeholder는 치환됨
- `tmp/project&name`처럼 `/`와 `&`가 포함된 project name도 안전하게 치환됨

### 4.3 Build template

`bash scripts/build-template.sh` 실행 결과:

- regression gate 통과
- `../claude-code-harness-template/`에 변경 전파 완료

target template 변경 상태:

- `.claude/.harness-version`
- `.harness-manifest`
- `docs/updates/INDEX.md`
- `scripts/upgrade-harness.sh`
- `docs/updates/round-4-p0-sync-fixes.md`

---

## 5. 현재 git 상태

Forge repo 변경:

- `handoff/latest.md`
- `src/.harness-manifest`
- `src/docs/updates/INDEX.md`
- `src/scripts/upgrade-harness.sh`
- `src/docs/updates/round-4-p0-sync-fixes.md`
- `outputs/reports/p0-sync-fix-result-2026-04-29.md`

기존 untracked로 보존:

- `.agents/`
- `AGENTS.md`
- `outputs/reports/session-report-2026-04-29.md`

아직 하지 않은 작업:

- stage
- commit
- provisional update doc rename
- push
- template repo commit / push

---

## 6. 판단

이번 작업은 원래 session report가 권장한 옵션 1을 충족한다.

- 다운스트림 sync를 막는 P0 2건은 닫혔다.
- Round 4 전체로 scope가 확장되지 않았다.
- Claude second review에서도 blocker/P1 추가 대응은 없었다.
- 다음 단계는 git 정리 후 IMPL 트랙으로 복귀하는 것이다.

권장 다음 단계:

1. forge 변경을 commit 단위로 정리
2. commit hash 확정 후 update doc rename + INDEX hash 교체
3. forge push 및 template repo 전파 확인
4. honbabseoul / divebase / kody는 별도 downstream session에서 sync 후 IMPL 진행
