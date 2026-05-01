---
name: harness-report
description: |
  Measures and reports harness quality scores.
  Activate on these requests:
  "harness score", "harness report", "harness status", "quality measurement", "check baseline",
  "score check", "harness report"
  Do NOT activate on:
  "collect trends", "harvest", "code review", "bug fix"
version: 1.0.0
---

# Harness Report Skill

Measures the current quality score of the harness.

## Trigger
- "check harness score", "harness report", "update baseline", "quality measurement"

## Workflow

### 1. Run Measurement
```bash
bash scripts/harness-report.sh quick
```
Or full measurement:
```bash
bash scripts/harness-report.sh
```

### 2. Interpret Results
- **80+**: Healthy harness. Rules/skills/hooks are solid with evaluation records
- **50-79**: Moderate. Some areas need reinforcement
- **Below 50**: Early stage. Prioritize adding skills and evaluation records

### 3. Improvement Suggestions
Identify low-scoring areas and suggest specific improvement actions:
- rules low → reinforce gotchas.md, add project-specific rules
- skills low → extract repetitive workflows into skills
- hooks low → add post-edit verification
- evaluations low → build habit of writing evaluation.md after tasks
- test_lint low → verify lint/test command configuration

### 4. Baseline Update
Measurement results are automatically saved to `harvest/baseline.json`.

## Output Format
JSON scores + per-area breakdown.

## Gotchas
- Quick mode skips test/lint, so 20 points are excluded
- Measurement is based on project root, not template files (src/)
- Skills directory must be at .Codex/skills/ to be recognized
