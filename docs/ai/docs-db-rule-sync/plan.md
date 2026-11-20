# PLAN — docs-db-rule-sync

| Field | Value |
|---|---|
| Feature name | `docs-db-rule-sync` |
| Created | 20/11/2026 |
| Owner(s) | Trang |
| Status | `DONE` |
| Plan approved by user | YES (20/11/2026) |

---

## 1. SUMMARY

`ui-username-group-size` changed the screens to the database rules (username `^[A-Za-z0-9_]{3,30}$`, case-insensitive; a new group has at least 3 people including the creator). Several living documents still state the old rules (username 4–30 `[a-z0-9_.]`, group "≥ 2 thành viên" or "creator + 3"). This feature makes those documents consistent with `script/schema.sql` and `docs/database/design-baseline.md`.

---

## 2. INPUT / OUTPUT

### Input
- User request (20/11/2026): "sửa luôn các tài liệu liên quan để đảm bảo tính nhất quán, và các điểm khác liên quan".

### Output / Expected result
- `use-case-specification.md`: BR-01 = 3–30 characters `[A-Za-z0-9_]`, unique ignoring case, cannot change; BR-09 = a new group has ≥ 3 members including the creator; M19 answer and UC-22 step 4 = "≥ 2 thành viên khác".
- `ui-align-decisions` plan/feature doc: D31 and D8 lines carry a short "Superseded 20/11/2026 by ui-username-group-size" note (history kept, not rewritten).
- `database-schema.md` handoff row for `CreateGroupController` carries a "Resolved 20/11/2026 by ui-username-group-size" note.
- `ui-username-group-size.md`: known-issue line about stale ui-align-decisions docs removed.

---

## 3. SCOPE

### In scope (Q1 = A, confirmed)
- Only the two rules changed in `ui-username-group-size`: username format/case and group minimum size, in every living doc listed in section 6.

### Out of scope
- `docs/Final_Project_He_Thong_Chat_Chi_Tiet.md` — instructor's brief, never edited.
- `docs/database/reports/*`, `docs/database/research_notes/*` — dated analysis snapshots with line references; editing them would falsify what was analysed.
- `docs/ai/work-log.md` old entries — append-only.
- Other DB-vs-use-case differences listed in `database-schema.md` handoff (mandatory E2EE instead of the "Mã hóa tin nhắn" option, admin-only rename, Q1 closure, D38, activity definition…) — unless the user picks option B of Q1.

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | QUESTION | "các điểm khác liên quan": (A) only username + group-size rules, or (B) also sync the whole use-case spec with all DB decisions from the `database-schema.md` handoff list (E2EE, admin-only rename, successor/closure, spam D38, activity, etc.)? User answered: (A) only username + group-size rules. | RESOLVED |
| 2 | ASSUMPTION | Historical feature docs get a dated "Superseded/Resolved" note instead of a rewrite. | CONFIRMED |
| 3 | ASSUMPTION | This feature is committed before `docs-restructure`, so its file edits are not mixed with file moves. User asked the AI to commit each feature (no push). | CONFIRMED |

---

## 5. APPROACH

### Step 1: Use-case specification
- **Action:** Edit BR-01, BR-09, M19, UC-22 step 4 in `docs/ai/requirements-analysis/use-case-specification.md`.
- **Verify:** `grep` for `4–30`, `[a-z0-9_.]`, `≥ 2 thành viên`, `≥1 thành viên khác` in that file returns nothing.

### Step 2: Historical feature docs notes
- **Action:** Add the dated notes in `ui-align-decisions/plan.md`, `ui-align-decisions/ui-align-decisions.md`, `database-schema/database-schema.md`; remove the stale known-issue line in `ui-username-group-size.md`.
- **Verify:** Every remaining "creator + 3" / "ít nhất 3 người khác" / "MemberPicker(3)" occurrence outside snapshots/work-log is followed by a superseded/resolved note.

### Alternatives considered
- Rewrite the old D31 text in ui-align-decisions: rejected, those docs record what that feature did at the time.

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| MODIFY | `docs/ai/requirements-analysis/use-case-specification.md` | BR-01, BR-09, M19, UC-22 step 4 |
| MODIFY | `docs/frontend/ai/ui-align-decisions/plan.md` | Superseded notes on D8/D31 rows |
| MODIFY | `docs/frontend/ai/ui-align-decisions/ui-align-decisions.md` | Superseded notes on D31 lines |
| MODIFY | `docs/database/ai/database-schema/database-schema.md` | Resolved note on CreateGroupController handoff row |
| MODIFY | `docs/frontend/ai/ui-username-group-size/ui-username-group-size.md` | Remove stale known-issue line |
| CREATE | `docs/ai/docs-db-rule-sync/docs-db-rule-sync.md` | Feature description (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- None — documentation only.

### Depends on other features
- ui-username-group-size — the screen changes these docs now describe.
- database-schema — source of the rules.

### Technical constraint check (Rule 8)
- [x] No networking code touched.
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| Scope creep into a full use-case rewrite | MEDIUM | Q1 decides; default A |
| Missing a stale mention | LOW | Grep check in Step 2 |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | Use-case spec states the DB username and group-size rules | grep in Step 1 | PASS |
| 2 | No unmarked old rule remains in living docs | grep in Step 2 | PASS |

---

## 10. ITERATION LOG

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | 20/11/2026 |
| Commit message to use | `feat(docs-db-rule-sync): sync username and group-size rules in docs` |
| Notes | Use-case BR-01/BR-09/M19/UC-22 updated; old feature docs annotated; course brief, reports, research notes and other DB-vs-use-case differences intentionally untouched. |

Do NOT write a commit hash here. This file is part of the commit itself, so the hash does not exist yet when the file is written.

---
*Feature description: [docs-db-rule-sync.md](./docs-db-rule-sync.md)*
