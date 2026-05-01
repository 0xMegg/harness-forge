# Hermes Automation Boundary

Hermes automation exists to reduce repeated manual judgment, not to replace project judgment. The boundary is based on reversibility, behavioral impact, and measurement.

## Rule

Automate additive, low-risk, measurable changes. Human-gate changes that alter behavior, ownership, execution flow, permissions, or project-specific judgment. Block destructive or high-risk changes unless the user explicitly approves a scoped plan.

## Auto-Apply Candidate

A change can be recommended for automatic application only when all conditions hold:

- It is additive: `rule` or `scaffold-rule`.
- It is `risk: low` per `context/harvest-policy.md`.
- It passes the 5-axis fitness filter at score >= 7; see `context/harvest-policy.md`.
- It does not reduce the harness score measured by `bash scripts/harness-report.sh`.
- It has a concrete target file, trigger condition, and exact action.
- It does not modify existing behavior.

Typical example: adding a Known Pitfall entry after the same failure repeats and the rule can be checked against future tasks.

Source: `context/harvest-policy.md`; `context/working-rules.md`.

## Human Gate Required

Require explicit user + Claude judgment when any condition applies:

- The change adds a new skill, hook, config, execution mode, or template category.
- The change is medium risk or borderline by score.
- The effect is qualitative or not visible to the current metric.
- The change affects project-specific workflow, context policy, or operating mode.
- The change may increase meta work even if it improves harness quality.

Typical example: adopting Operating Mode / IMPL-META track separation is valuable, but it changes how a project schedules work and therefore needs project-level judgment.

Source: `src/docs/updates/12a6f9f.md`; `outputs/reports/session-report-2026-04-29.md`.

## Block

Block by default:

- Deleting rules, skills, hooks, templates, or policy.
- High-risk changes.
- Changes that lower the measured harness score.
- Modifications to existing behavior without a narrow plan and approval.
- Broad placeholder substitution or sync behavior changes without downstream smoke verification.
- Destructive operations such as reset, wipe, or mass rename without explicit user confirmation.

Source: `context/harvest-policy.md`; `src/docs/updates/cee3b30.md`; `src/.claude/rules/base/decision-protocol.md`.

## Worked Examples

### Round 3: phase split and regression gate

- Case: Review entry was blocked by infrastructure crashes and a 10-minute tool timeout.
- Boundary: human gate required, because execution flow changed and new wrappers/regression checks were introduced.
- Decision: implement as a scoped P0 fix, verify with smoke tests, then record the downstream impact.
- Source: `src/docs/updates/e2ee114.md`.

### Round 4: manifest and placeholder substitution fix

- Case: new managed files were not installed downstream, and placeholder substitution touched docs that should preserve literals.
- Boundary: human gate required before changing sync behavior; broad substitution is not a harmless doc edit.
- Decision: scope substitution to runtime files and verify downstream sync behavior.
- Source: `src/docs/updates/cee3b30.md`.

### Round 5: Operating Mode template

- Case: meta work was crowding out implementation work.
- Boundary: human gate required because the change affects project operating cadence, even though the template itself is additive.
- Decision: ship as a managed reference template; downstream projects choose whether to instantiate it.
- Source: `src/docs/updates/12a6f9f.md`.

## Acceptance Question

Before automating any Hermes improvement, ask:

"If this applies without a human decision, what is the worst plausible wrong outcome, and can the harness detect or reverse it cheaply?"

If the answer is unclear, use the human gate.
