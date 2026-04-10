# Harvest Guide — Self-Improvement Pipeline

## Overview

The harvest module is the 7th element of the harness — a self-improvement pipeline that collects external trends and applies them to the project.

**Core principle**: "The external world changes rapidly, so the system must evolve too. But not blindly — only what passes the project's philosophy filter is kept."

## 7-Element Harness Model

| # | Element | Role |
|---|---------|------|
| 1 | Permissions | settings.json + access-policy.md |
| 2 | Validation | hooks (block, check, lint, test) |
| 3 | Execution Mode | 3-Role workflow (plan/develop/review) |
| 4 | State Maintenance | handoff/ + context/ |
| 5 | Decision Trace | decision-log.md + evaluation.md |
| 6 | External Integration | mcp-policy.md + plugin-guide.md |
| 7 | **Self-Improvement Loop** | **harvest pipeline** |

## Pipeline Flow

```
Phase 0: Guard (lock + cooldown)
    ↓
Phase 1: Collect (WebFetch, WebSearch, manual, internal feedback)
    ↓
Phase 2: Analyze (5-axis fitness filter, threshold >= 6)
    ↓
Phase 3: Measure (harness-report baseline)
    ↓
Phase 3.5: Judge (temp apply → re-measure → keep/discard)
    ↓
Phase 4: Apply (auto or pending approval per harvest-policy.md)
    ↓
Phase 5: Report (harvest/reports/)
```

## 5-Axis Fitness Filter

Each axis 0–2 points, 10 points total. Threshold: 6 points (3+ axes meaningfully satisfied).

| Axis | Question | 2 pts | 1 pt | 0 pts |
|------|----------|-------|------|-------|
| Automation | Does it reduce manual steps? | Fully eliminates | Partially reduces | No effect |
| Friction | Does it prevent existing pitfalls? | Directly prevents | Indirectly related | Unrelated |
| HARD conversion | Enforceable via exit code? | Directly enforced | Warning only | Not possible |
| Token efficiency | Does it reduce tokens? | Measurable savings | Indirect improvement | No effect |
| Measurability | Trackable with a single metric? | Directly trackable | Indirectly trackable | Not possible |

## Double-Gating

Both gates must pass before applying:

1. **Gate 1 (SOFT)**: 5-axis score >= 6 — "Is this suitable for this project?"
2. **Gate 2 (HARD)**: harness-report measurement — "Does it actually improve things?"

This combination blocks two types of failure:
- Gate 1 only: Changes that seem plausible but are actually harmful
- Gate 2 only: Changes that aren't harmful but are irrelevant to the project

## Usage

### Full Pipeline
```
/harvest
```

### Manual Input
```
/harvest add "Block if more than 3 TODOs in pre-commit"
/harvest add https://github.com/trending/shell
```

### Check Status
```
/harvest status
```

### Partial Execution
```
/harvest scan      # Collection only
/harvest judge     # Measurement + verification only
/harvest apply     # Apply pending proposals
```

## Auto-Apply Policy Summary

| Condition | Action |
|-----------|--------|
| rule/scaffold-rule + score >= 7 + risk low + harness maintained | Auto-apply |
| new-skill, hook, config changes | Requires approval |
| Deletion, risk high, harness decline | Blocked |

Details: `context/harvest-policy.md`

## Project Customization Guide

### 1. Enable
Set `"enabled": true` in `harvest/config.json`.

### 2. Customize Sources
```json
"web_fetch": {
  "targets": [
    {"name": "GitHub Trending Swift", "url": "https://github.com/trending/swift"}
  ]
},
"web_search": {
  "queries": ["iOS development best practices 2026"]
}
```

### 3. Adjust Axis Weights (optional)
Change weights based on project characteristics:
- Web projects: increase friction weight
- Mobile apps: increase hard_conversion weight
- Automation projects: increase automation weight

### 4. Output Settings
```json
"output": {
  "provider": "obsidian",
  "obsidian": {
    "vault_path": "/path/to/vault",
    "folder": "harvest-reports"
  }
}
```

## Directory Structure

```
harvest/
├── config.json       # Configuration (git-tracked)
├── baseline.json     # Current harness score (git-tracked)
├── .seen.json        # Dedup index (gitignored)
├── .lock             # Concurrent execution prevention (gitignored)
├── raw/              # Collected raw data (gitignored)
├── analyzed/         # Analysis results (gitignored)
├── rejected/         # Rejected proposals (gitignored)
├── applied/          # Apply history (git-tracked)
└── reports/          # Execution reports (git-tracked)
```
