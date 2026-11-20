# PLAN — db-fe-conflict-fix

| Field | Value |
|---|---|
| Feature name | `db-fe-conflict-fix` |
| Created | 20/11/2026 |
| Owner(s) | Trang |
| Status | `DONE` |
| Plan approved by user | YES (20/11/2026) |

---

## 1. SUMMARY

Resolves the conflicts found by the final DB ↔ FE ↔ analysis-doc check (Part 3, D1–D43) on `main` @ `4e17308`. The full list, in Vietnamese, is [diff.md](./diff.md) (IDs A1–A5, B1–B3, C1–C5, E1–E6). This plan fixes the stale side of each conflict, adds V1 placeholders where the FE lacks a state the DB already stores, and removes the files the user approved for deletion.

---

## 2. INPUT / OUTPUT

### Input
- [diff.md](./diff.md), approved by the user on 20/11/2026: delete the files in section E, fix the conflicts in A and C, add the FE gaps in B; the user makes the commit.

### Output / Expected result
- Part 3 of the analysis doc (Claude Doc *Đồ án Java – Hệ thống Chat*) states the same rules and names as `script/schema.sql` (A1, A2, A4, A5, C1, C2).
- S11c no longer offers "send the new password by email" (A3); S05 has a hidden closed-group note and S13 shows open/closed groups (A4); S11 and S14 have a hidden "kick failed / retry" note (B1); S01/S10 no longer pre-fill credentials that do not exist (B2); the S10 footer names the database link (B3).
- Two wrong `SampleData` comments fixed (C4); `design-baseline.md`, `use-case-specification.md`, `ui-align-decisions.md` and `README.md` no longer contradict the schema (A2, C3, C5).
- Build output under `src/*/target/` is no longer tracked; the stale conflict reports/notes and redundant `.gitkeep` files are gone; `.gitignore` keeps only the Java block (E1–E5).

---

## 3. SCOPE

### In scope
- Items A1–A5, B1–B3, C1–C5, E1–E5 of [diff.md](./diff.md), limited to the files in section 6.
- Regenerating the screenshots of changed screens (S01, S05, S10, S11, S11c, S13, S14).

### Out of scope
- **E6 branch deletion**: branches are not files, and deleting `origin` branches is an outward-facing git action; the user handles git. Commands stay in diff.md.
- **Commits**: the user commits (stated in the request). `git rm --cached` (E1) only stages the untracking.
- **Schema changes**: `script/schema.sql`, `seed.sql`, `queries.sql`, `tests/verify.sql` stay unchanged (approved design owned by Minh). A5 and C3 are solved in docs instead.
- **V2 behaviour**: real kick/retry, closing a group when no successor exists (TransferAdminDialog branch), the S11 "Xóa" dialog with its last-admin check, a demo seed with real BCrypt hashes, and whether an admin reset sets `must_change_password`. These belong to `admin-user-mgmt`, `group-chat`, `auth` and are listed as known issues.
- RegisterView keeps its filled example values: they demonstrate the error states in S02.

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | ASSUMPTION | "đưa file diff này vào doc" = put diff.md in the repo docs as this feature's plan; it is stored as [diff.md](./diff.md) next to this English plan (the template requires English). | UNCONFIRMED |
| 2 | ASSUMPTION | "cho phép sửa các conflict" includes editing the shared Part 3 Claude Doc for A1, A2, A4, A5, C1, C2 (the side that is stale). Edits are limited to the affected cells. | UNCONFIRMED |
| 3 | ASSUMPTION | A5: `spam_reports.reason` stays one optional text column; the app requires ≥ 1 reason and stores the ticked labels joined by `"; "` (as `SampleData.SpamRow` already does). | UNCONFIRMED |
| 4 | ASSUMPTION | A4: V1 adds only display states (hidden S05 note, S13 status column); the closure action itself is V2. | UNCONFIRMED |
| 5 | ASSUMPTION | E2/E3: `docs/database/reports/` and `docs/database/research_notes/` get a `.gitkeep` so the Rule 6 folder structure survives after their files are deleted. | UNCONFIRMED |
| 6 | ASSUMPTION | A3: whether an admin password reset sets `must_change_password` is left to V2 `admin-user-mgmt`; no FE change depends on it now. | UNCONFIRMED |

---

## 5. APPROACH

### Step 1: Plan and conflict list in docs
- **Action:** Copy diff.md into `docs/ai/db-fe-conflict-fix/`, write this plan, log in work-log.
- **Verify:** Both files exist; work-log has SESSION_START / PLAN_CREATED / PLAN_APPROVED.

### Step 2: Repository cleanup (E1–E5)
- **Action:** `git rm -r --cached` the three `target/` folders; delete the 3 reports and 4 research notes and add `.gitkeep` to both folders; delete the 4 redundant `.gitkeep`; trim `.gitignore` to the Java block.
- **Verify:** `git ls-files | grep /target/` is empty; after `./mvnw -B -q test`, `git status` lists no `target/` path; the deleted paths no longer exist.

### Step 3: FE fixes (A3, A4, B1, B2, B3, C4)
- **Action:** S11c: remove the email CheckBox. S05: hidden `closedNote` above the composer. S13: `GroupRow.closed` (LocalDate, null = open), "Trạng thái" column, closed date in the detail; one closed sample group with 0 admins. S11/S14: hidden `kickFailedNote` with "Thử lại". S01/S10: credentials become `promptText`. S10 footer names the DB. Fix the two SampleData javadocs.
- **Verify:** `./mvnw -B -q test` passes (user 29/29, admin 23/23); ScreenshotTool regenerates S01, S05, S10, S11, S11c, S13, S14 and each shows the change (or, for the hidden notes, nothing changes visually).

### Step 4: Repository doc fixes (A2, C3, C5)
- **Action:** design-baseline: replace the two "no D40" sentences, fix the `remote_ip` purpose; use-case spec: K4/UC-28/M18/BR-05/UC-37/UC-38 aligned with E2EE, admin-only rename, no IP; ui-align-decisions §4: resolved notes; README backend row.
- **Verify:** grep finds no "Do not invent a D40", "server giữ khóa" without an update note, "IP" in BR-05/UC-37/UC-38, or "chưa thống nhất" in the README tech table.

### Step 5: Part 3 Claude Doc fixes (A1, A2, A4, A5, C1, C2)
- **Action:** Update the "Đề xuất mặc định" / "Ảnh hưởng" cells of D3, D4, D7, D14, D15, D18, D26, D31, D33, D34, D35, D36, D37, D40, D42.
- **Verify:** Re-read the D-tables; every cell matches diff.md's "Real schema" / fix column.

### Step 6: Feature doc and log
- **Action:** Write `db-fe-conflict-fix.md`, update work-log and tracker, remind the user to commit.
- **Verify:** Rule 5 checklist all ticked.

### Alternatives considered
- Change `schema.sql` for A5 (reason NOT NULL) and C3 (drop `remote_ip`): rejected; the schema is approved and verified by A/B/C SQL tests, and the docs-only fix is enough.
- Delete E2/E3 folders entirely: rejected; Rule 6 lists them.

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| CREATE | `docs/ai/db-fe-conflict-fix/plan.md` | This plan |
| CREATE | `docs/ai/db-fe-conflict-fix/diff.md` | Approved conflict list (Vietnamese) |
| CREATE | `docs/ai/db-fe-conflict-fix/db-fe-conflict-fix.md` | Feature description (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker |
| UNTRACK | `src/admin/target/`, `src/common/target/`, `src/user/target/` | E1, `git rm -r --cached` |
| DELETE | `docs/database/reports/*.md` (3), `docs/database/research_notes/Xung đột màn hình và CSDL/*.md` (4) | E2, E3 |
| CREATE | `docs/database/reports/.gitkeep`, `docs/database/research_notes/.gitkeep` | Keep Rule 6 folders |
| DELETE | `src/admin/.gitkeep`, `src/user/.gitkeep`, `script/.gitkeep`, `docs/ai/_template/.gitkeep` | E4 |
| MODIFY | `.gitignore` | E5, keep the Java block only |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/ResetPasswordDialog.fxml` | A3, remove the email CheckBox |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/controller/ResetPasswordController.java` | A3, javadoc no longer mentions emailing |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/GroupChatView.fxml` | A4, hidden `closedNote` |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/GroupsView.fxml` | A4, "Trạng thái" column |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/controller/GroupsController.java` | A4, status column and closed date |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java` | A4 `GroupRow.closed` + sample; C4 comment |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/UsersView.fxml` | B1, hidden `kickFailedNote` |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/SpamView.fxml` | B1, hidden `kickFailedNote` |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/LoginView.fxml` | B2, `promptText` |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/AdminLoginView.fxml` | B2 `promptText`; B3 footer |
| MODIFY | `src/user/src/main/java/com/chatapp/user/sample/SampleData.java` | C4 comment |
| MODIFY | `docs/frontend/screens/user/*.png`, `docs/frontend/screens/admin/*.png` | Regenerated screenshots |
| MODIFY | `docs/database/design-baseline.md` | A2, C3 |
| MODIFY | `docs/ai/requirements-analysis/use-case-specification.md` | C5 |
| MODIFY | `docs/frontend/ai/ui-align-decisions/ui-align-decisions.md` | C5 resolved notes |
| MODIFY | `README.md` | C5 backend row |
| MODIFY | Claude Doc *Đồ án Java – Hệ thống Chat*, section 3 | A1, A2, A4, A5, C1, C2 |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- None new. JavaFX 21 / Ikonli already in `pom.xml`.

### Depends on other features
- `database-schema` — `script/schema.sql` and `design-baseline.md` are the source of truth for names and rules.
- `ui-align-decisions`, `ui-username-group-size` — current V1 screens.

### Technical constraint check (Rule 8)
- [x] This feature uses only `java.net.Socket` / `java.net.ServerSocket` for networking (no networking added).
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| `git rm --cached` mistaken for deleting local build output | LOW | Only the index changes; files stay on disk; explained to the user |
| Editing the shared Claude Doc overwrites a teammate's edit | MEDIUM | Targeted `find` replacements only; re-read the tables afterwards |
| New SampleData field breaks a test or screenshot | LOW | Run `./mvnw -B -q test` and regenerate screenshots |
| Deleting the reports loses history | LOW | Git history keeps them; diff.md supersedes them |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | No build output tracked; tests no longer dirty git | `git ls-files \| grep /target/` empty; `./mvnw -B -q test` then `git status --short \| grep target` empty | PASS |
| 2 | E2–E5 files gone, Rule 6 folders kept, `.gitignore` Java-only | `ls` the paths; `cat .gitignore` | PASS |
| 3 | All FXML loads and navigation tests pass | `./mvnw -B -q test`: user 29/29, admin 23/23 | PASS |
| 4 | Screens show the fixes | Regenerate screenshots; S11c has no email checkbox, S13 has "Trạng thái" with one "Đã đóng" row, S01/S10 show prompts, S10 footer names the DB | PASS |
| 5 | Repo docs no longer contradict the schema | grep checks of Step 4 | PASS |
| 6 | Part 3 cells match the schema | Re-read D-tables from the Claude Doc | PASS |

---

## 10. ITERATION LOG

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | 20/11/2026 |
| Commit message to use | `feat(db-fe-conflict-fix): resolve DB, FE and Part 3 conflicts and remove stale files` |
| Notes | Done: E1–E5, A1–A5, B1–B3, C1–C5 (Part 3 doc rev 156). Not done: E6 branch deletion (user), V2 behaviour listed in the feature doc section 7. No schema change. |

Do NOT write a commit hash here. This file is part of the commit itself, so the hash does not exist yet when the file is written.

---
*Feature description: [db-fe-conflict-fix.md](./db-fe-conflict-fix.md)*
