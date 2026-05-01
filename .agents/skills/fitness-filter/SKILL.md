---
name: fitness-filter
description: |
  Scores external trend items using a 5-axis fitness filter.
  Activate on these requests:
  "evaluate this trend", "fitness score", "fitness assessment", "5-axis analysis",
  "is this worth applying?", "trend evaluate"
  Do NOT activate on:
  "harness score", "code review", "bug fix", "collect trends"
version: 1.0.0
---

# Fitness Filter Skill

Evaluates external trends/ideas from the project's perspective using a 5-axis fitness score.

## Trigger
- "evaluate this trend [URL/description]"
- "fitness score for [item]"
- Automatically invoked during Phase 2 of the harvest pipeline

## Input
Trend item:
- title: title or summary
- url: source URL (optional)
- description: detailed description
- source_type: web_fetch / web_search / manual / internal_feedback

## Pre-Filter: Concreteness Gate

Before scoring, reject proposals that lack concrete specifics. A proposal MUST specify all three:
1. **Target file** — exact path (e.g., `.Codex/rules/gotchas.md`, not "a rule file")
2. **Triggering condition** — specific, observable event (e.g., "3+ consecutive identical error messages", not "when things go wrong")
3. **Action** — exact behavior (e.g., "exit 1 to block commit", not "warn the user")

If any of the three is missing or vague, reject immediately with reason `abstract-proposal`.
Do NOT invent specifics to pass the gate — if the input is vague, reject it.

**Reject** (abstract):
- "Add a rule about code quality" → no target file, no condition, no action
- "Improve error handling" → no specific trigger or file
- "Be more careful with tests" → aspirational, not enforceable

**Pass** (concrete):
- "Add to gotchas.md: if `git diff --cached` shows `*.env*` files, exit 1 in pre-commit hook"
- "Add rule to testing.md: run `npm test -- --bail` before committing; if exit code != 0, block"

## 5-Axis Scoring

Each axis 0–2 points, 10 points total. **Threshold: 6 points** (3+ axes meaningfully satisfied)

### 1. Automation — 0~2
- 2: Fully eliminates manual steps (e.g., automates manual verification via hooks)
- 1: Partially reduces manual steps (e.g., scripts part of a repetitive task)
- 0: No automation effect

### 2. Friction — 0~2
- 2: Directly prevents existing pitfalls from gotchas.md (e.g., auto-blocks known mistakes)
- 1: Reduces related friction but not directly connected
- 0: Unrelated to existing friction

### 3. HARD Conversion — 0~2
- 2: Directly enforceable via bash exit code (e.g., hook exits with 1 to block)
- 1: Partially auto-verifiable (e.g., warns but doesn't block)
- 0: Purely subjective judgment, cannot be automated

### 4. Token Efficiency — 0~2
- 2: Measurable token savings (e.g., shorter prompts, removes unnecessary context)
- 1: Indirect improvement (e.g., clearer rules reduce retries)
- 0: No token impact

### 5. Measurability — 0~2
- 2: Directly trackable with a single metric (e.g., test count, lint warning count, evaluation score)
- 1: Trackable via indirect metrics (e.g., session length, rework frequency)
- 0: No clear measurement metric

## Context Required
Files that must be read when calculating scores:
1. `.Codex/rules/gotchas.md` — existing pitfalls (for Friction axis evaluation)
2. `AGENTS.md` — project architecture (for applicability judgment)
3. `harvest/config.json` — per-axis weights
4. `context/harvest-policy.md` — auto-apply eligibility

## Output Format
Output in `templates/harvest-proposal.md` format.

## Decision
- score >= 7 + risk low → auto-apply candidate
- score >= 6 → proceed to Phase 3.5 (autoresearch judge)
- score < 6 → record in harvest/rejected/ + reason

## Gotchas
- Do not score based on generalities without project context
- "Looks good" and "needed for this project" are different things
- If HARD conversion is 0, the rule cannot be enforced — low effectiveness
- If a similar item already exists in gotchas.md, treat as duplicate rather than giving Friction 2 points
- Do NOT invent specifics to pass the concreteness gate — if the input is vague, reject it as `abstract-proposal`
