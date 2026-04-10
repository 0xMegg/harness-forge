# Trend Harvester

Claude Code 하네스를 자동으로 개선하는 self-improvement 파이프라인.

외부 트렌드를 수집하고, 프로젝트 철학에 맞는지 필터링하고, 실제 효과를 측정한 뒤에만 적용한다.

> "외부 세계가 빠르게 변하므로 시스템도 진화해야 한다. 단, 맹목적이지 않게."

## How It Works

```
Phase 0  Guard       ─  lock + cooldown
Phase 1  Collect     ─  WebFetch, WebSearch, 수동 입력, 내부 피드백
Phase 2  Analyze     ─  5축 Fitness Filter (임계값 6/10)
Phase 3  Measure     ─  harness-report baseline
Phase 3.5 Judge      ─  임시 적용 → 재측정 → keep/discard
Phase 4  Apply       ─  정책 기반 자동/수동 적용
Phase 5  Report      ─  실행 보고서 생성
```

모든 제안은 **Double-Gating**을 통과해야 한다:
1. **SOFT gate** — 5축 점수 >= 6 (프로젝트에 적합한가?)
2. **HARD gate** — harness-report 실측 (실제로 개선되는가?)

## Quick Start

```bash
cd trend-harvester
claude

# 현황 확인
/harvest status

# 수동으로 규칙 제안
/harvest add "bash 스크립트에 set -euo pipefail 누락 시 경고"

# 외부 트렌드 수집
/harvest scan

# 전체 파이프라인
/harvest
```

## 5-Axis Fitness Filter

| 축 | 질문 | 0 | 1 | 2 |
|----|------|---|---|---|
| Automation | 수동 단계를 줄이는가? | 영향 없음 | 부분 축소 | 완전 제거 |
| Friction | 기존 함정을 방지하는가? | 무관 | 간접 관련 | 직접 방지 |
| HARD conversion | exit code로 강제 가능? | 불가 | 경고만 | 직접 강제 |
| Token efficiency | 토큰을 줄이는가? | 영향 없음 | 간접 개선 | 측정 가능 |
| Measurability | 단일 지표로 추적? | 불가 | 간접 추적 | 직접 추적 |

총 10점 만점, **6점 이상**이면 Gate 2(실측)로 진행.

## Auto-Apply Policy

| 조건 | 동작 |
|------|------|
| rule/scaffold-rule + score >= 7 + risk low + harness 유지 | 자동 적용 |
| new-skill, hook, config 변경 | 승인 필요 |
| 삭제, risk high, harness 하락 | 차단 |

## Project Structure

```
trend-harvester/
├── CLAUDE.md                    # 프로젝트 계약서
├── .claude/
│   ├── commands/harvest.md      # /harvest 커맨드
│   └── skills/                  # 3개 스킬
│       ├── trend-harvest/       #   파이프라인 오케스트레이션
│       ├── fitness-filter/      #   5축 점수 산출
│       └── harness-report/      #   하네스 품질 측정
├── scripts/
│   ├── run-harvest.sh           # 파이프라인 오케스트레이터 (참조용)
│   ├── harness-report.sh        # 하네스 점수 측정 (0-100)
│   └── build-template.sh        # src/ → 하네스 템플릿 레포 배포
├── harvest/
│   ├── config.json              # 수집 소스 + 임계값 설정
│   ├── baseline.json            # 현재 harness 점수
│   ├── applied/                 # 적용 이력
│   └── reports/                 # 실행 보고서
├── src/                         # 하네스 템플릿 소스 (배포 대상)
│   ├── .claude/
│   │   ├── hooks/               # 6 훅 (block-dangerous, post-edit-*,
│   │   │                        #        pre-commit-branch-check)
│   │   └── rules/               # api/frontend/testing/git/gotchas
│   ├── scripts/
│   │   ├── run-task.sh          # 3-Role + 자동 task/{id} 브랜치
│   │   ├── run-epic.sh          # Epic + overlap gate + worktree opt-in
│   │   └── diagnose.sh          # 실패 상태 자동 진단 (exit 0/1)
│   └── docs/
│       ├── epic-guide.md        # Epic 분할 + 병렬 안전장치
│       └── troubleshooting.md   # 5개 실패 시나리오 복구
├── context/
│   ├── harvest-policy.md        # 자동 적용 정책 (2단계 판단 의무)
│   ├── mcp-policy.md            # MCP 연결 체크리스트
│   └── working-rules.md         # 워크플로우 + 세션 분할 + token 예산
├── docs/harvest-guide.md        # 파이프라인 상세 가이드
└── templates/                   # 제안서/보고서 형식
```

## Hardening Highlights (2026-04)

외부 트렌드 + 자체 운영 피드백을 파이프라인으로 적용한 최근 강화 항목:

| 영역 | 변경 | 효과 |
|------|------|------|
| Context 예산 | `working-rules.md` 세션 분할 체크리스트 + 파일 크기 상한 + `post-edit-size-check.sh` 훅 | 편집 시 `CLAUDE.md>200`, `rules/*>50`, `context/*>150` 초과 자동 경고 |
| 실패 복구 | `docs/troubleshooting.md` + `scripts/diagnose.sh` | 5개 시나리오(run-task mid-fail, Reviewer loop, slice 충돌, hook 실패, lock 잔존) 자동 스캔 + 복구 명령 |
| 브랜치 격리 | `run-task.sh` `task/{id}` / `run-epic.sh` `epic/{RUN_ID}` 자동 분기 + `pre-commit-branch-check.sh` 훅 | main 직접 커밋 차단 (exit 2), APPROVE 시 ff-only 자동 병합, `HARVEST_ALLOW_MAIN=1` 우회 |
| 병렬 안정성 | `run-epic.sh` overlap gate (상시) + `HARVEST_PARALLEL_WORKTREE=1` git worktree 격리 (opt-in) | slice 간 파일 충돌 사전 차단, 선택적 워크트리 완전 격리 |

상세 적용 내역은 `harvest/applied/` 각 JSON과 `handoff/latest.md` 참고.

## Relationship with Harness Template

```
trend-harvester/          claude-code-harness-template/
(이 레포)                  (결과물 레포)
    │                          │
    │  src/ 편집               │  순수 하네스 템플릿
    │  build-template.sh ──→   │  (플레이스홀더 포함)
    │                          │
    │  harvest pipeline        │  프로젝트에 복사해서
    │  로 src/ 개선            │  사용하는 대상
    └──────────────────────    └──────────────────
```

- **이 레포**: 하네스를 만들고, 측정하고, 개선하는 시스템
- **[harness-template](https://github.com/0xMegg/claude-code-harness-template)**: 시스템이 만든 결과물

## Harness Score

`bash scripts/harness-report.sh`로 측정. 6개 영역, 100점 만점.

| 영역 | 배점 | 측정 기준 |
|------|------|-----------|
| Rules | 20 | 규칙 파일 수 + 내용 충실도 |
| Skills | 20 | 스킬 수 + examples 유무 |
| Hooks | 15 | hook 수 + 실행 권한 |
| Templates | 15 | 템플릿 수 + 플레이스홀더 아닌 실제 내용 |
| Evaluations | 10 | 평가 기록 수 |
| Test/Lint | 20 | 린트/테스트 통과율 |

## License

Private
