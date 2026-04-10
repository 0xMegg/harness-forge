# Project Gotchas

Project-specific pitfalls that cause repeated mistakes.
Add entries as you discover them — each bug fix or unexpected behavior is a candidate.

## Known Pitfalls
- Run existing tests before modifying code — if they already fail, fix or flag before starting your task
- When lint or tests fail, paste the full error output into your next fix attempt — never guess the cause from the test name alone
- Implement one function or feature at a time — verify it works before moving to the next. Large-scope changes produce jumbled, undebuggable output
- Reference real file paths and symbol names in task specs — never describe code by concept alone. Vague references produce hallucinated paths and wasted cycles
- If the same fix fails 3 times, stop — reassess the approach instead of retrying. Endless retry loops waste tokens and context
- Run lint/test before requesting code review — computational checks (lint, type-check, test) must pass before LLM-based review. Never waste review cycles on code with syntax errors
- When context nears 70% capacity, proactively /compact or start a fresh session — degraded context produces hallucinations and forgotten instructions. Write handoff before resetting
