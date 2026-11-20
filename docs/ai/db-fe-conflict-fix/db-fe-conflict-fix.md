# FEATURE — db-fe-conflict-fix

| Field | Value |
|---|---|
| Feature name | `db-fe-conflict-fix` |
| Created | 20/11/2026 |
| Last updated | 20/11/2026 |
| Owner(s) | Trang |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

Resolves the conflicts between the database (`script/schema.sql`, `docs/database/design-baseline.md`), the V1 screens and Part 3 (D1–D43) of the analysis doc, as listed in [diff.md](./diff.md). The stale side of each conflict was corrected, V1 placeholders were added for DB states the screens did not show, and the build output, stale reports and redundant placeholder files approved for deletion were removed.

---

## 2. PURPOSE / USE CASE

- **Actor:** The team (UI, DB and server owners) and reviewers reading the analysis doc, the use-case spec and the screenshots.
- **Trigger:** The final DB ↔ FE ↔ Part 3 check on `main` @ `4e17308`.
- **Goal:** Every source states the same rule and the same table/column names, so V2 is built against one consistent design.

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| CREATED | `docs/ai/db-fe-conflict-fix/diff.md` | Approved conflict list A1–A5, B1–B3, C1–C5, E1–E6 (Vietnamese) |
| UNTRACKED | `src/admin/target/`, `src/common/target/`, `src/user/target/` | E1: 52 build files removed from the index (`git rm -r --cached`), still on disk |
| DELETED | `docs/database/reports/*.md` (3), `docs/database/research_notes/Xung đột màn hình và CSDL/*.md` (4) | E2/E3: written for the old schema |
| CREATED | `docs/database/reports/.gitkeep`, `docs/database/research_notes/.gitkeep` | Keep the Rule 6 folders |
| DELETED | `src/admin/.gitkeep`, `src/user/.gitkeep`, `script/.gitkeep`, `docs/ai/_template/.gitkeep` | E4: folders already have files |
| MODIFIED | `.gitignore` | E5: Node/JS template removed; logs, `.env` and the Java block kept |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/ResetPasswordDialog.fxml` | A3: "Gửi mật khẩu mới tới …" CheckBox and its import removed |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/controller/ResetPasswordController.java` | A3: javadoc says the admin types the password (D10) |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/GroupChatView.fxml` | A4: hidden `closedNote` above the composer |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/GroupsView.fxml` | A4: "Trạng thái" column |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/controller/GroupsController.java` | A4: status badge "Hoạt động" / "Đã đóng"; detail adds "Đóng ngày …" |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java` | A4: `GroupRow.closed` (null = open), "Nhóm học CTDL" closed 06/11/2026 with 2 members and 0 admins; C4: javadoc no longer says the creator is not stored |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/UsersView.fxml` | B1: hidden `kickFailedNote` with "Thử lại" in the detail head |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/SpamView.fxml` | B1: hidden `kickFailedNote` with "Thử lại" under the subtitle; Button import |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/LoginView.fxml` | B2: username/password are `promptText` |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/AdminLoginView.fxml` | B2: `promptText`; B3: footer "CSDL localhost:5432 · config.properties" |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/sample/SampleData.java` | C4: `SEARCH_USERS` javadoc says usernames match case-insensitively |
| MODIFIED | `docs/frontend/screens/user/S01-dang-nhap.png`, `docs/frontend/screens/admin/S10-dang-nhap-quan-tri.png`, `S11c-dat-lai-mat-khau.png`, `S13-nhom-chat.png` | Regenerated |
| MODIFIED | `docs/database/design-baseline.md` | A2: the two "no D40" sentences say D40 matches section 9.6; C3: `remote_ip` purpose |
| MODIFIED | `docs/ai/requirements-analysis/use-case-specification.md` | C5: K4 note, M8/M14/M16/M18, BR-05/BR-14, UC-06, spam reasons, UC-20–24, UC-27, UC-28 (mandatory E2EE), UC-36/37/39/40/41/45, section 8 item 3 |
| MODIFIED | `docs/frontend/ai/ui-align-decisions/ui-align-decisions.md` | C5: resolved notes in section 4 |
| MODIFIED | `README.md` | C5: backend row |
| MODIFIED | Claude Doc *Đồ án Java – Hệ thống Chat*, section 3 (rev 155 → 156) | Cells of D3, D4, D7, D14, D15, D18, D26, D31, D33, D34, D35, D36, D37, D40 (2 bullets), D42 |
| MODIFIED | `docs/ai/work-log.md` | Log entries and tracker row |

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - `script/schema.sql`, `seed.sql`, `queries.sql` and `tests/verify.sql` are unchanged. A5 keeps `spam_reports.reason` as one optional text column (labels joined by `"; "`); C3 keeps `login_history.remote_ip` and only corrects its description.

### Socket messages
N/A - no network code; V1 screens with sample data.

---

## 5. HOW TO RUN / TEST

### Prerequisites
- JDK 21+ (JDK 25 used) and the Maven wrapper.

### How to run
```bash
./mvnw -B -q test
./mvnw -B -q -pl src/common,src/user,src/admin test -Dtest=ScreenshotTool -Dsurefire.failIfNoSpecifiedTests=false
git ls-files | grep /target/
git status --short | grep target | grep -v '^D  '
```

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | `git ls-files \| grep /target/` and, after a test run, `git status --short \| grep target \| grep -v '^D  '` | Both empty (the only `target` lines are the 52 staged untracking entries) | PASS |
| 2 | List the E2–E4 paths and `cat .gitignore` | Files gone; `reports/` and `research_notes/` hold `.gitkeep`; `.gitignore` has logs, `.env` and the Java block | PASS |
| 3 | `./mvnw -B -q test` | user 29/29, admin 23/23 | PASS |
| 4 | Open S01, S10, S11c, S13 screenshots | Prompts instead of credentials; S10 footer "CSDL localhost:5432"; no email checkbox; "Trạng thái" column with one "Đã đóng" row | PASS |
| 5 | grep the repo docs | No "Do not invent a D40"; no IP in BR-05/UC-37/UC-39; every "server giữ khóa" has a 20/11 update note; README backend row filled | PASS |
| 6 | Read the Part 3 tables of the Claude Doc | All 16 cells match diff.md | PASS |

---

## 6. TECHNICAL NOTES

- The hidden notes (`closedNote`, two `kickFailedNote`) follow the D9 `passwordReminder` pattern: `visible="false" managed="false"`, no controller field. V2 shows them when the server reports a closed group or a failed/unknown kick ACK (`admin_audit_log` `CONTROL_FAILED` / `CONTROL_UNKNOWN`).
- The S13 status uses `g.closed() != null` as a Boolean because `Tables.graphic` skips null values.
- Plan and log are in English (template rule); the conflict list stays in Vietnamese as approved.
- Networking: none in this feature; no WebSocket.

### Changes from the original plan
None.

---

## 7. KNOWN ISSUES / LIMITATIONS

- Not done here (V2): closing a group when no successor exists (TransferAdminDialog branch), the S11 "Xóa" dialog with its last-admin check, real kick ACK/retry, a demo seed with real BCrypt hashes, and whether an admin reset sets `must_change_password`.
- The hidden notes were not rendered visible in a screenshot; only FXML loading was tested.
- RegisterView still pre-fills example values on purpose (they show the S02 error states).
- E6 (deleting merged branches) is left to the user.
- The Claude Doc outside section 3 still has older text (SD7/SD9 group search and rename, the RSA model note in section 6, open question 9 about E2EE); not edited because the request covered Part 3.
- The 52 untracked `target/` files and the deletions are staged but not committed.
