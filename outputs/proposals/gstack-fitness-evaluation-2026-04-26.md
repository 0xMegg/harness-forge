# gstack 흡수 후보 — 5축 fitness 평가 보고서

- 일자: 2026-04-26
- 입력: `~/.claude/plans/https-github-com-garrytan-gstack-breezy-wilkes.md` (1000줄, Phase 1 + Phase 2 검증, 섹션 28 에 흡수 후보 10개 정리됨)
- 평가자: 본 세션 (forge round 3 작업 직후)
- 산출물 형식: (B) outputs/ 평가 보고서 + 사용자 결정 대기 — 28.1/28.4 의 scope 모호점 때문

## Context

사용자가 gstack(garrytan/gstack) 분석 문서의 섹션 28 (10개 패턴) 을 harness-forge 의 5축 fitness filter (`automation / friction removal / HARD conversion / token efficiency / measurability`, `context/harvest-policy.md` 정의) 로 평가하고 상위 후보를 제안하도록 요청. 본 평가는 28.1~28.10 + 본문 (섹션 17, 21) 에서 발견한 패턴까지 포함.

## 5축 정의 (재확인, harvest-policy.md + harness-report.sh 기준)

| 축 | 의미 | harness-report 매핑 |
|---|------|--------------------|
| automation | 사람 손 줄이기 / 자동화 | Hooks (HARD enforce), Scripts |
| friction removal | 반복 실수 / drift / 의사결정 cascade 감소 | Rules / Guidance lines |
| HARD conversion | soft 룰을 `exit 1` 게이트로 전환 | Hooks / Scripts (count_hard_enforced, set -euo pipefail) |
| token efficiency | always-resident 줄이기, 컨텍스트 절약 | Rules count + 길이 (200 라인 가이드) |
| measurability | harness-report 또는 별도 metric 으로 score 변동 측정 | Score 카테고리 자체에 반영 가능한가 |

각 축 0-10 점수. 합계 50 만점.

## 1. 후보 평가 (28.1 ~ 28.10 전체)

### 28.1 — 단일 source of truth (SNAPSHOT_FLAGS 변형)
**한 줄**: 5축 axes / 임계값 / harness-report band / harvest config 를 단일 yml 로 export, 모든 스크립트가 거기서 로드.
**5축**: automation 8 · friction 9 · HARD 8 · token 6 · measurability 7 → **38/50**
- automation 8: docs/code 동기화 자동화 가능. forge 는 bash + md 기반이라 yml + helper 로 변형.
- friction 9: 사용자가 직접 호소하지 않았어도 harvest-policy.md / harness-report.sh / harvest config 가 따로 노는 drift 위험 큼. gstack 도 이 drift 를 docs 에서 발견 (섹션 17).
- HARD 8: drift checker 를 `exit 1` 게이트로 만들면 hard 전환. `check-harness-regression.sh` 에 통합 가능.
- token 6: 단일 소스라 docs 중복 줄지만 파일 수는 비슷.
- measurability 7: drift count metric 을 harness-report 의 신규 카테고리(또는 Scripts 가산)로 측정.

**비용**: medium. `src/config/harness-thresholds.yml` (신규) + `src/scripts/load-thresholds.sh` (신규) + `harness-report.sh` / `run-harvest.sh` 마이그레이션 + drift checker.
**난이도**: medium.
**HARD measurable**: 가능 — Scripts 카테고리에 +2 (drift checker hard exit), 또는 신규 "Config" 카테고리 (0-5).

### 28.2 — Tier-based preamble (T1~T4)
**한 줄**: 작업 강도별 preamble 차등 (bug fix=T2, plan-eng-review=T4 풀 가드레일).
**5축**: automation 4 · friction 5 · HARD 3 · token 9 · measurability 5 → **26/50**
- token 9: 작은 task 에 무거운 preamble 안 띄우면 토큰 절약 큼.
- HARD 3: preamble 자체가 prompt-level — hard 화 어려움.
- automation 4: tier 자동 분류 휴리스틱이 약함. 사람이 결정해야.

**비용**: high. forge 에 preamble 시스템 자체가 없음. role-*.md / templates/ 분기 + compose 메커니즘 신설.
**난이도**: high.
**HARD measurable**: 약함 — task 별 평균 token 측정 가능하나 baseline 변동 노이즈 큼.

### 28.3 — Diff-based 테스트 선택 with touchfiles
**한 줄**: 각 테스트가 의존 글로브 선언, git diff 로 자동 선택. EVALS_ALL=1 강제.
**5축**: automation 6 · friction 5 · HARD 2 · token 3 · measurability 4 → **20/50**
- HARD 2: 게이트라기보다 최적화.
- token 3: 스크립트 실행 비용은 토큰과 무관.

**비용**: medium. `harness-report.sh` 에 `--target` 이미 있음. touchfile 매핑 추가.
**난이도**: medium.
**HARD measurable**: 약함 — 측정 시간 단축이 곧 score 의미를 변화 (부분 vs 풀).
**참고**: harness-report 측정 자체가 이미 빠름 (몇 초). 우선순위 낮음.

### 28.4 — Calibration data 코드 주석
**한 줄**: 임계값 옆에 측정 근거(N-case bench, FP/TP) 를 명시 → 회귀 추적.
**5축**: automation 2 · friction 8 · HARD 2 · token 5 · measurability 6 → **23/50**
- friction 8: 임계값 변경 시 근거 명시 → 회귀 cascade 추적 쉬움. **본 round (Round 2 → Round 3) 가 정확히 그 cascade**.
- automation 2: 사람이 calibration 돌리고 주석 갱신.

**비용**: low. 기존 임계값 5~7개에 주석 추가.
**난이도**: low.
**HARD measurable**: 약함 (주석은 hard 게이트 아님, Guidance lines 에 자동 반영).
**참고**: 기존 update doc 들(`8a8f0d5.md`, `24070b5.md`) 이 사실상 같은 정신. 정형화하면 가치.

### 28.5 — Confusion Protocol (high-stakes ambiguity 가드)
**한 줄**: 4 시나리오 + STOP / 2-3 options / Ask 패턴, scope 제한 (routine 코딩 제외).
**5축**: automation 5 · friction 9 · HARD 4 · token 7 · measurability 5 → **30/50**
- friction 9: **본 round 의 직접 처방**. honbab/divebase 의 patch/resume/manual 3택이 정확히 ambiguity. STOP + 2-3 options 패턴이 그 자체. 사용자 호소 "10+ 단계 폭증" = 의사결정 cascade.
- token 7: 짧은 prompt, 영향 큰 가드.
- HARD 4: prompt-level 이지만 Reviewer 가 "ambiguity 발견했는데 STOP 안 함" 을 REQUEST_CHANGES 처리 가능.

**비용**: low. 신규 룰 1~2 파일 + working-rules 통합.
**난이도**: low.
**HARD measurable**: Rules count + lines 자동 (harness-report Rules 카테고리에 +1 file +30 lines).

### 28.6 — Eureka 로깅
**한 줄**: insight 발견 시 `~/.gstack/analytics/eureka.jsonl` 에 자동 JSONL append.
**5축**: automation 8 · friction 4 · HARD 1 · token 3 · measurability 9 → **25/50**
- measurability 9: JSONL 자체가 metric. harvest pipeline 의 unexpected wins 추적.
- HARD 1: 순수 관찰.

**비용**: low. hooks/post-task 또는 harvest 안에 jq append.
**난이도**: low.
**HARD measurable**: 가능 — eureka entry count 를 harness-report 신규 metric (Evaluations 옆) 로.
**참고**: 본 round 직접 문제 해결과는 거리. 회고 가치는 있음.

### 28.7 — Force flags 패턴
**한 줄**: 게이트 over-block 시 사용자 escape hatch (`--security`, `HARVEST_ALLOW_MAIN` 류).
**5축**: automation 3 · friction 6 · HARD 5 · token 4 · measurability 3 → **21/50**
- HARD 5: fail-closed 게이트의 짝.
- friction 6: escape hatch 가 명시되면 우회 코스트 감소.

**비용**: low. 기존 settings.json + 룰 텍스트만 수정.
**난이도**: low.
**참고**: 이미 부분 적용 (`HARVEST_ALLOW_MAIN`, `HARVEST_SKIP_UPDATE_CHECK`, `SKIP_REGRESSION_CHECK`, `HARNESS_STRICT_SHELLCHECK`). 패턴 일관화는 가치 있지만 fresh 흡수는 아님.

### 28.8 — Adaptive gating
**한 줄**: 10회 연속 0 finding → 해당 source 자동 skip.
**5축**: automation 7 · friction 5 · HARD 2 · token 6 · measurability 5 → **25/50**
- token 6: 무가치 호출 줄임.

**비용**: medium. trend source 별 통계 저장 + skip 로직.
**난이도**: medium.
**참고**: forge 의 trend source 가 그렇게 많지 않아 skip 효용 보통.

### 28.9 — Migration script for stale state
**한 줄**: 1회 자동 healing marker (`.codex-desc-healed`).
**5축**: automation 8 · friction 6 · HARD 3 · token 2 · measurability 4 → **23/50**
- automation 8: 1회 자동.
- friction 6: 다운스트림 stale state 정리.

**비용**: medium. `upgrade-harness.sh` 에 healing 로직 + marker.
**난이도**: medium.
**참고**: `manifest [deprecated]` 섹션 (24070b5.md) 이 부분 동일 패턴. 신선한 추가 흡수는 작음.

### 28.10 — 4-component versioning + claim queue
**한 줄**: 멀티 worktree VERSION 스캔해 슬롯 reserve.
**5축**: automation 7 · friction 5 · HARD 4 · token 1 · measurability 4 → **21/50**
- token 1: 영향 작음.

**비용**: medium. `upgrade-harness.sh` manifest 확장.
**난이도**: medium.
**참고**: 사용자 메모리 "Harness propagation safety: 1 project at a time with dry-run review" → 동시 propagation 케이스 빈번하지 않아 claim queue 필요성 낮음.

## 2. 본문 추가 패턴 (섹션 17 / 21)

### Pattern A — 임계값 코드 export (섹션 17, 28.1 의 동기 보강)
gstack 도 docs/code drift (WARN 0.60 vs 실제 0.75) 발견. forge 도 동일 위험 → 28.1 합산.

### Pattern B — Preamble compose order (섹션 21, load-bearing)
Opus 4.7 prompt order regression (v1.6.4.0 bug). forge 에 preamble 시스템 부재 → 28.2 와 묶어서 high cost.

### Pattern C — Completeness Principle (fabrication 금지)
"옵션이 coverage 다르면 점수, kind 다르면 점수 금지". 5축 채점에 fabrication 금지 가드 가치. 28.4 와 묶음.

## 3. Top-3 선정

합계(50점) + 비용/효용 가중. 본 round 가 식별한 단계 폭증의 직접 / 간접 원인을 얼마나 닫는가:

| 순위 | 패턴 | 합계 | 비용 | 본 round 와의 관계 |
|------|------|------|------|------------------|
| **1** | **28.1 단일 source of truth** | 38 | medium | drift 차단 = 회귀 cascade 의 메타 솔루션 |
| **2** | **28.5 Confusion Protocol** | 30 | low | 의사결정 cascade 의 직접 처방 |
| **3** | **28.4 Calibration data 주석** | 23 | low | Round N → Round N+1 회귀 추적 강화 |

선정 근거:
- 28.1 은 단일 score 가 가장 높고, drift 가 forge 의 만성 위험 (gstack 도 동일하게 학습). 본 round 의 회귀 가드 (`check-harness-regression.sh`) 와 짝.
- 28.5 는 score 30 으로 2위지만 **본 round 사용자 호소의 직접 처방**. 비용 낮고 즉시 효용. 단 28.5 의 해결 범위는 "의사결정 cascade 발생 시 사람-루프" 까지로, "cascade 자체를 줄이는" round 3 회귀 픽스와 보완 관계.
- 28.4 는 score 23 으로 낮지만 비용도 가장 낮고, 28.1 의 yml 안에 자연스럽게 통합 가능 (yml 주석 형식). 28.1 이 이루어지면 거의 무료.

### 떨어뜨린 7개 — 회고용 1줄

- 28.2 Tier preamble — forge 에 preamble 시스템이 없어 도입 비용 high (가치는 있지만 별도 skill 신설 수준)
- 28.3 Diff-based 테스트 — harness-report 측정이 이미 빠름 (몇 초), 최적화 수익 작음
- 28.6 Eureka 로깅 — 가치 있지만 본 round 의 직접 문제와 거리, 별도 round 후보
- 28.7 Force flags — 이미 4개 환경변수로 부분 적용, 일관화는 정리 작업이지 흡수 아님
- 28.8 Adaptive gating — trend source 자체가 적어 skip 효용이 작음
- 28.9 Migration — `manifest [deprecated]` 가 같은 패턴으로 24070b5.md 에서 이미 적용
- 28.10 4-component version + claim queue — propagation 정책이 1 project at a time 이라 슬롯 충돌 거의 없음

## 4. Top-3 Implementation Plan 초안

### 4-1. 28.1 — 단일 source of truth (P1)

**문제**:
- `context/harvest-policy.md` 가 fitness `>= 7`, `score 6 borderline` 등 임계값을 본문에 명시
- `scripts/harness-report.sh:419-424` 가 80/50 band 인라인
- `scripts/run-harvest.sh` 와 `/harvest` 슬래시 커맨드의 5축 axes 가 markdown 으로만 정의
- 셋이 동기화 안 됨 → drift 발생 시 silent failure

**제안 변경**:
- `src/config/harness-thresholds.yml` (신규) — 단일 source:
  ```yaml
  fitness:
    auto_apply_score: 7    # >= → RECOMMEND (per harvest-policy.md)
    review_score: 6        # borderline
  harness_report:
    band:
      green: 80
      yellow: 50
  axes: [automation, friction_removal, hard_conversion, token_efficiency, measurability]
  ```
- `src/scripts/load-thresholds.sh` (신규) — bash 헬퍼 (yq 없으면 grep fallback)
- `src/scripts/harness-report.sh` 의 80/50 인라인 → `source load-thresholds.sh; echo $BAND_GREEN/$BAND_YELLOW` 식
- `context/harvest-policy.md` 의 임계값 본문은 yml 값을 참조 (또는 build 시 generate)
- `src/scripts/check-config-drift.sh` (신규) — yml 값과 docs 텍스트 일치 확인. 불일치 → exit 1. `check-harness-regression.sh` 가 호출.

**harness-report 추가 metric**:
- 옵션 a: Scripts 카테고리에 +2 (drift checker hard exit 보너스)
- 옵션 b: 신규 "Config" 카테고리 (0-5) — yml 존재 + drift check 통과 + axes 정의됨

**verify**:
- `bash src/scripts/load-thresholds.sh` → env 변수 export 확인
- `bash src/scripts/check-config-drift.sh` → exit 0
- 의도적 drift (docs 의 "7" → "8" 변경) 재현 → exit 1
- `bash src/scripts/check-harness-regression.sh` 가 drift checker 호출 → fail-closed 확인
- `bash scripts/build-template.sh` 통과

**예상 work hours**: 3~4시간 (AI 보조). yml 설계 1h + helper + drift checker 1h + 기존 스크립트 마이그레이션 1h + verify 1h.

**⚠ scope 모호점 (사용자 결정 필요)**:
- **옵션 A**: 5축 axes 정의 + fitness 임계값만 yml (가장 작은 scope, 1.5h)
- **옵션 B**: A + harness-report band 까지 (medium scope, 3h)
- **옵션 C**: A + B + harvest config (`harvest/config.json` 의 schedule / sources / thresholds 까지) 전부 통합 (큰 scope, breaking 가능, 5h+)

### 4-2. 28.5 — Confusion Protocol (P0)

**문제**:
- 본 round 분석에서 단계 폭증의 직접 원인 = 사용자 의사결정 cascade
- harness-forge 의 어떤 룰도 high-stakes ambiguity 시 STOP 패턴을 명시하지 않음
- working-rules.md 의 "If 3+ different approaches fail, stop and discuss" 만 존재 (부분)

**제안 변경**:
- `src/.claude/rules/base/decision-protocol.md` (신규, ~30~40 줄)
  - 4 시나리오 (gstack 그대로, harness 컨텍스트로 재서술):
    1. Two plausible architectures or data models
    2. A request that contradicts existing patterns
    3. A destructive operation where the scope is unclear (`rm -rf`, `git reset --hard`, mass rename)
    4. Missing context that would change your approach significantly
  - STOP → 한 문장으로 ambiguity 명명 → 2~3 options + tradeoffs → 사용자 질문
  - **scope 제한**: routine coding / small features / obvious changes 에는 적용 안 함
  - destructive 시 예시: "harness 작업 도중 SIGTERM 으로 죽었을 때 patch+resume / manual review / re-run 셋 중 하나 — 반드시 사용자 결정"
- `src/context/working-rules.md` 의 "Communication" 섹션과 cross-reference (또는 통합)
- `src/.claude/rules/base/gotchas.md` 에 "Confusion Protocol 위반 시 Reviewer 가 REQUEST_CHANGES" 한 줄 추가

**harness-report 추가 metric**:
- 자동 반영 (Rules 카테고리: +1 file_points + 30~40 lines, depth_points tier 50→2 or 100→4)

**verify**:
- `bash scripts/harness-report.sh` Rules 점수 +1~+2 확인
- mock ambiguous task ("harness 갱신 중 stale 발견 — 어떻게 할지") 입력 → 모델이 STOP + 2-3 options 패턴 따르는지 manual check (harness-report 와 별개)
- `harvest-policy.md` 의 auto-apply 분기 시점에도 동일 가드 명시되는지 cross-ref

**예상 work hours**: 1.5~2시간. 룰 작성 1h + working-rules 통합 0.5~1h.

### 4-3. 28.4 — Calibration data 주석 (P2)

**문제**:
- 5축 임계값 (`auto_apply_score: 7`, `review_score: 6`) 의 근거가 어디에도 없음
- 임계값 변경 시 회귀 추적 어려움
- 기존 update doc (8a8f0d5.md, 24070b5.md) 가 비슷한 정신이지만 임계값과 분리

**제안 변경**:
- 28.1 진행 시 `harness-thresholds.yml` 안에 `# Calibration:` 형식 주석 채택:
  ```yaml
  fitness:
    auto_apply_score: 7
    # Calibration (2026-04-12 baseline): 14 trend → 7 적용 / 7 차단.
    # 6 으로 낮추면 +3 false positive (manual review reject).
    # 8 로 올리면 -2 true positive (score 7 자동 적용 안 됨).
  ```
- 28.1 진행 안 하면 `context/harvest-policy.md` 안에 "## Calibration" 섹션 신설
- update doc 작성 시 calibration 데이터 갱신 anchor (templates/handoff.md 또는 templates/evaluation.md 에 체크리스트)

**harness-report 추가 metric**:
- 별도 metric 없음 (Guidance lines 자동 반영)

**verify**:
- 임계값 변경 PR 시 같은 commit 에 calibration 갱신 강제 (선택, hook 추가):
  - `pre-commit-calibration-check.sh` — `harness-thresholds.yml` 의 임계값 변경 + calibration 주석 미수정 → exit 1
- harvest-policy.md 본문이 calibration 섹션 grep 통과 (`grep -q "## Calibration"`)

**예상 work hours**: 1~2시간 (28.1 와 묶으면 +0.5h, 단독이면 1.5h).

**⚠ scope 모호점 (사용자 결정 필요)**:
- 기존 임계값 retroactive calibration 데이터: 측정 자체가 안 된 상태 → "no data — heuristic" 명시 시작?
- 옵션 A: 향후 새 임계값 도입 시점부터만 적용 (template 만 추가)
- 옵션 B: retroactive — 현재 7개 임계값에 "no data — heuristic" 채우고 점진 보강

## 5. 자기검증 (Confusion Protocol — 본 보고서 작성에도 적용)

| 후보 | 이미 비슷한 게? | scope 모호? | destructive? | 권장 |
|------|---------------|-----------|------------|------|
| 28.1 | 아니오. 단 `harvest/config.json` 과 부분 영역 겹침. | **있음** — 옵션 A/B/C 중 결정 필요 | reversible (yml 추출만) | **사용자 결정 후 진행** |
| 28.5 | working-rules.md 의 "Communication" 섹션 부분. 통합 가능. | 명확 | 룰 추가만 | **즉시 진행 가능** |
| 28.4 | update doc 들이 같은 정신. 28.1 과 묶음 가치. | 약간 — retroactive vs forward-only | reversible | **28.1 와 묶어 결정** |

## 6. 권장 다음 액션 (사용자 결정 대상)

> ⚠ **본 보고서 시점에 본 세션은 이미 round 3 회귀 픽스 + phase 분리 + 회귀 가드 작업이 완료 상태이며 commit 대기 중**. 사용자 메모리 ("10+ issues must split across sessions") 에 따라 본 흡수 작업은 **별도 세션** 권장.

권장 순서:
1. **(이번 세션 내)** 본 보고서 검토 + Top-3 중 진행할 후보 선정 + 28.1 의 scope 옵션 (A/B/C) 결정
2. **(별도 세션 1)** 28.5 Confusion Protocol 즉시 적용 — 비용 낮고 round 3 cascade 와 잘 묶임. round 3 commit 에 같이 포함시키는 것도 옵션.
3. **(별도 세션 2)** 28.1 + 28.4 묶음 진행 — yml + drift checker + calibration 주석. 28.1 결정 옵션에 따라 work hour 변동.
4. **(보류)** 28.2 / 28.6 / 28.8 / 28.9 / 28.10 — 별도 round 에서 재평가 (harvest pipeline 진단 round 와 묶일 가능성).

## 7. 본 round 3 commit 과의 관계

사용자가 마지막에 "이것도 포함하자" 라고 한 부분 — 두 가지 해석:
- **해석 A**: 본 평가 작업을 round 3 commit 안에 포함 (즉 본 보고서 파일 + 가능하면 28.5 Confusion Protocol 룰까지).
- **해석 B**: 본 평가만 별도 산출물로, round 3 commit 은 회귀 픽스만.

본 보고서 파일은 `outputs/proposals/` 아래 — `src/docs/updates/` 의무와 무관한 forge-only 파일이라 round 3 commit 에 같이 들어가도 hook 위반 없음. 단 commit 메시지가 두 가지 작업을 묶어 길어짐.

권장: **해석 B 가 안전** — 본 보고서를 별도 chore 커밋(`chore: gstack fitness evaluation report`) 으로 분리하면 round 3 회귀 픽스 commit 의 history 가 깔끔. 단 사용자가 해석 A 원하면 그대로 진행 가능.

---

## 부록 A — 채점 합계 표

| 패턴 | A | F | H | T | M | 합계 | 비용 | 난이도 |
|------|---|---|---|---|---|------|------|--------|
| 28.1 | 8 | 9 | 8 | 6 | 7 | **38** | medium | medium |
| 28.5 | 5 | 9 | 4 | 7 | 5 | **30** | low | low |
| 28.2 | 4 | 5 | 3 | 9 | 5 | 26 | high | high |
| 28.6 | 8 | 4 | 1 | 3 | 9 | 25 | low | low |
| 28.8 | 7 | 5 | 2 | 6 | 5 | 25 | medium | medium |
| 28.4 | 2 | 8 | 2 | 5 | 6 | **23** | low | low |
| 28.9 | 8 | 6 | 3 | 2 | 4 | 23 | medium | medium |
| 28.7 | 3 | 6 | 5 | 4 | 3 | 21 | low | low |
| 28.10 | 7 | 5 | 4 | 1 | 4 | 21 | medium | medium |
| 28.3 | 6 | 5 | 2 | 3 | 4 | 20 | medium | medium |

A=automation, F=friction removal, H=HARD conversion, T=token efficiency, M=measurability.
