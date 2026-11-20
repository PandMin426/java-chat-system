# FEATURE — docs-db-rule-sync

| Field | Value |
|---|---|
| Feature name | `docs-db-rule-sync` |
| Created | 20/11/2026 |
| Last updated | 20/11/2026 |
| Owner(s) | Trang |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

Brings the living documentation in line with the two database rules that `ui-username-group-size` applied to the screens: usernames are 3–30 characters of `[A-Za-z0-9_]`, unique and logged in case-insensitively, and a new group has at least 3 members including the creator. Historical feature docs keep their original text with a dated "Superseded/Resolved" note.

---

## 2. PURPOSE / USE CASE

- **Actor:** Team members reading the requirements and feature docs.
- **Trigger:** Reading BR-01, BR-09, M19 or UC-22, or the older ui-align-decisions / database-schema docs.
- **Goal:** Every document states (or points to) the same username and group-size rules as `script/schema.sql` and `docs/database/design-baseline.md`.

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| MODIFIED | `docs/ai/requirements-analysis/use-case-specification.md` | BR-01: 3–30 `[A-Za-z0-9_]`, case-insensitive unique/login; BR-09 and M19: ≥ 3 members including the creator; UC-22 step 4: button enabled at ≥ 2 other members |
| MODIFIED | `docs/ai/ui-align-decisions/plan.md` | Superseded notes on the D8 and D31 rows |
| MODIFIED | `docs/ai/ui-align-decisions/ui-align-decisions.md` | Superseded notes on the two D31 file rows and the D31 conflict note |
| MODIFIED | `docs/ai/database-schema/database-schema.md` | Resolved note on the `CreateGroupController` handoff row |
| MODIFIED | `docs/ai/ui-username-group-size/ui-username-group-size.md` | Removed the known-issue line about stale ui-align-decisions docs |

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - documentation only; the rules come from the existing `script/schema.sql`.

### Socket messages
N/A - no network communication.

---

## 5. HOW TO RUN / TEST

### Prerequisites
- Git Bash (grep).

### How to run
```bash
grep -n "4–30\|a-z0-9_\.\|≥ 2 thành viên\|≥1 thành viên khác" docs/ai/requirements-analysis/use-case-specification.md
grep -rn "creator + 3\|ít nhất 3 người khác\|MemberPicker(3)\|minPicked = 3\|creator + ≥ 3\|creator+three" docs --include=*.md
```

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | First grep | No match | PASS |
| 2 | Second grep, excluding work-log, reports and research_notes | Every match carries a Superseded/Resolved note, is the new rule, or is design-baseline's own "superseded" sentence | PASS |

---

## 6. TECHNICAL NOTES

- Old feature docs are annotated, not rewritten, so they still show what each feature did at the time.
- Not edited on purpose: `docs/Final_Project_He_Thong_Chat_Chi_Tiet.md` (course brief: "tối thiểu một tên đăng nhập"; the DB decision is stricter), `docs/reports/*` and `docs/research_notes/*` (dated analysis snapshots with line references), old `work-log.md` entries (append-only).
- Networking: none; no WebSocket.

### Changes from the original plan
None - implemented as planned (Q1 = only username and group-size rules).

---

## 7. KNOWN ISSUES / LIMITATIONS

- The use-case specification still differs from the DB on other points listed in the `database-schema.md` handoff (mandatory E2EE instead of the "Mã hóa tin nhắn" option, admin-only rename, successor/closure, spam D38, activity definition). Out of scope by the user's choice.
