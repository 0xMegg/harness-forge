# Task Evaluation

## Task
[Task N] — [Task name]

## 5 Metrics

### 1. Success Rate
- Completion criteria met: YES / NO / PARTIAL
- REQUEST_CHANGES count: [N]

### 2. Human Edit Count
- Locations directly fixed by Reviewer: [N]
- Key changes: [description]

### 3. Time
- Request → ready for approval: [duration]
- Plan → Develop → Review per phase: [duration]

### 4. Token Cost
- Total tokens: [N]
- Sessions: [N]
- Tool call count: [N]

### 5. Failure Type
Check applicable items:
- [ ] Insufficient evidence (didn't read enough information)
- [ ] Format error (output format doesn't match expectations)
- [ ] Test failure (functional error)
- [ ] Scope overflow (modified files not in the plan)
- [ ] Missing verification (skipped manual check)
- [ ] Other: [description]

### 6. Harvest Impact — optional
- Were harvest-applied rules used in this Task: YES / NO
- Applied rules: [list or "none"]
- Measured impact: harness-report delta [+/-N or "N/A"]

## Lessons Learned
- [What was learned from this task — record anything that should be reflected in gotchas.md or rules]
- [Record any patterns worth auto-collecting/applying via the harvest pipeline]
