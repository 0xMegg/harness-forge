# Hermes Harness Philosophy

Hermes inherits only the load-bearing invariants from harness-forge: rules that prevent a known failure, force a concrete decision, and answer a question an operator will face again.

This is not a copy of the 7-Element Harness, 6-Phase Pipeline, or 5-axis scoring mechanics. Those belong in templates, skills, scripts, and checks. This document preserves the judgment behind them.

## Inclusion Test

An invariant belongs here only if all three answers are concrete:

1. What failure does it prevent?
2. What decision does it force?
3. What Hermes operator question does it answer?

If any answer is generic, the invariant belongs in a script, a role template, a short rule, or nowhere.

## Invariants

### 1. Measurement beats plausible improvement

- Prevents: adoption-by-vibes, where a rule sounds correct but does not improve the harness in use.
- Forces: no self-improvement change is accepted as an improvement unless it survives a SOFT suitability check and a HARD measurement check.
- Operator question: "This proposal feels useful; do we apply it now or measure it first?"
- Decision: measure first. If the metric cannot see the effect, label it qualitative and keep the human gate.
- Source: `context/working-rules.md` Self-Improvement Loop; `context/harvest-policy.md`; `docs/harvest-guide.md`.

### 2. Claude filters; the user decides

- Prevents: automated drift, where scoring turns into permission to change the system without project-level judgment.
- Forces: Claude can recommend, reject, or request review, but final application requires the second-stage user + Claude decision.
- Operator question: "The proposal passes fitness and does not lower the score; can it auto-merge?"
- Decision: only low-risk additive rule/scaffold changes may be recommended for auto-apply, and even those still pass through the final judgment path defined by policy.
- Source: `context/harvest-policy.md` Two-stage judgment; `harvest/reports/20260411-040351.md`.

### 3. Decision trace is part of the artifact

- Prevents: repeated debates and un-auditable changes, especially when a later session lacks the original context.
- Forces: record why a decision was made, what it was meant to prevent, and what should be checked next.
- Operator question: "Will a future operator understand why this rule exists?"
- Decision: if the reason matters, preserve it in a decision log, update note, handoff, evaluation, or proposal rather than relying on chat memory.
- Source: `context/working-rules.md` Evaluation Loop; `src/docs/updates/INDEX.md`; `templates/evaluation.md`.

### 4. Context reset is an engineering tool

- Prevents: long-session compaction pressure, context anxiety, and rushed completion after the task boundary changes.
- Forces: split sessions at task boundaries, after long work blocks, or after direction changes; handoff must be strong enough for re-entry.
- Operator question: "Should this continue in the same session?"
- Decision: continue only when it is the same task with stable context. Otherwise write handoff and restart or fork.
- Source: `context/working-rules.md` Session Management and Context Reset Rules.

### 5. Meta work needs a box

- Prevents: meta-ceremony consuming implementation time, where improving the harness becomes a standing substitute for shipping downstream work.
- Forces: separate IMPL and META tracks, cap carry-over, and define an error budget for harness improvement rounds.
- Operator question: "Do we fix another harness issue now or return to product work?"
- Decision: if the current META box is spent or the carry-over limit is reached, record the item and return to IMPL unless it blocks sync or execution.
- Source: `src/docs/updates/12a6f9f.md`; `outputs/reports/session-report-2026-04-29.md`.

### 6. Ambiguity is cheap only when the blast radius is small

- Prevents: silent wrong choices for destructive, architectural, or hard-to-reverse operations.
- Forces: stop and surface options when the next action is ambiguous and the cost of guessing wrong is high.
- Operator question: "Should the agent choose among plausible recovery or architecture paths?"
- Decision: for high-stakes ambiguity, name the ambiguity, present 2-3 options with tradeoffs, and wait for the user choice.
- Source: `src/.claude/rules/base/decision-protocol.md`; `src/docs/updates/e2ee114.md`.

## Non-Invariants

Do not promote these into Hermes philosophy:

- A workflow step already enforced by a script or hook.
- A generic software principle without a harness-forge failure behind it.
- A long session narrative that should remain a report.
- A scoring rubric that belongs inside a skill.
- A template structure that should be executed, not described.
