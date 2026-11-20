# FEATURE — ui-username-group-size

| Field | Value |
|---|---|
| Feature name | `ui-username-group-size` |
| Created | 20/11/2026 |
| Last updated | 20/11/2026 |
| Owner(s) | Trang |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

Aligns the V1 screens of UserApp and AdminApp with two database rules from `script/schema.sql` and `docs/database/design-baseline.md`: usernames match `^[A-Za-z0-9_]{3,30}$` (CHECK `users_username_format_check`) and are unique case-insensitively (`users_username_ci_uidx` on `lower(username)`), and a new group needs at least 3 people including the creator. Sample usernames no longer contain dots, the username hints state the real rule, and D01 asks for 2 other people instead of 3.

---

## 2. PURPOSE / USE CASE

- **Actor:** User (S01, S02, S04, S06, S07, S09, D01, D02, D04) and Admin (S11–S17).
- **Trigger:** Opening any screen that shows or asks for a username; opening D01 "Tạo nhóm chat".
- **Goal:** Screens never show a username the DB would reject, tell users the exact allowed characters, and allow creating a group with creator + 2 others.

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| MODIFIED | `src/user/src/main/java/com/chatapp/user/sample/SampleData.java` | All usernames `.`→`_` (e.g. `bich_tran`); `GROUP_PICKED` now 2 people; D31 comment |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java` | All usernames `.`→`_` in every row list and two comments; emails unchanged |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/LoginView.fxml` | Username `an_nguyen` |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml` | Username `an_nguyen`; hint "3–30 ký tự: chữ cái không dấu, số và dấu _. Không phân biệt chữ hoa/thường, không đổi được về sau." |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml` | Username `an_nguyen` (header and field) |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/ChatView.fxml` | Header username `bich_tran` |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/ReportSpamDialog.fxml` | Subtitle "Báo cáo kevin_tran …" |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/CreateGroupDialog.fxml` | Subtitle "Nhóm cần ít nhất 3 người, tính cả bạn: thêm ít nhất 2 người khác. Bạn sẽ là admin của nhóm." |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/CreateGroupController.java` | `MemberPicker` minimum 3 → 2 |
| MODIFIED | `src/user/src/test/java/com/chatapp/user/NavigationTest.java` | D31 test comment (2 others picked) |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/ResetPasswordDialog.fxml` | Username `bich_tran` |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/UserFormDialog.fxml` | `wrapText` on `usernameHint` |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/controller/UserFormController.java` | `usernameHint` always shown: rule text in add mode, "Không đổi được." in edit mode |
| MODIFIED | `docs/screens/user/*.png`, `docs/screens/admin/*.png` | 20 regenerated screenshots (S01, S02, S04, S04b, S06, S07, S09, D01, D02, D04, S11, S11a, S11b, S11c, S12, S13, S14, S15b, S16, S17a) |

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - no database changes; the screens follow the existing `schema.sql`.

### Socket messages
N/A - no network communication (V1 screens with sample data).

---

## 5. HOW TO RUN / TEST

### Prerequisites
- JDK 21+ (Maven wrapper included).

### How to run
```bash
./mvnw -B -q test
./mvnw -B -q -pl src/common,src/user,src/admin test -Dtest=ScreenshotTool -Dsurefire.failIfNoSpecifiedTests=false
```

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | Extract username arguments of every sample record in both `SampleData.java` files and grep FXML for dotted names | Only `^[A-Za-z0-9_]{3,30}$` usernames (remaining hits were 2-letter avatar initials) | PASS |
| 2 | Open screenshots S02, S11a, S11b | S02/S11a show the rule hint; S11b shows "Không đổi được." | PASS |
| 3 | `NavigationTest.createGroupNeedsThreeMembers` | "Tạo nhóm" enabled with 2 picked, disabled after removing one | PASS |
| 4 | `./mvnw -B -q test` | user 29/29, admin 23/23 | PASS |

---

## 6. TECHNICAL NOTES

- Dots were replaced by `_` (the only separator the DB allows). Emails keep their dots: the DB only requires a trimmed, nonblank email.
- The hint says "Không phân biệt chữ hoa/thường" because uniqueness and login use `lower(username)`; the stored spelling is kept for display. This replaces the older "Phân biệt chữ hoa/thường" text from report F-01, which predates the current schema.
- Group minimum follows design-baseline ("at least three people, including the creator"; Word D31 creator+three superseded). D04 "Thêm thành viên" still needs at least 1 new person; there is no maximum group size.
- Networking: none in this feature; no WebSocket.

### Changes from the original plan
Iteration 1: added `wrapText` on the S11a username hint (`UserFormDialog.fxml`) and renamed `kevin.tran` in `ReportSpamDialog.fxml` plus two admin `SampleData` comments, found during the verification grep.

---

## 7. KNOWN ISSUES / LIMITATIONS

- No real validation yet: the regex check and error labels come with the `auth` and `admin-user-mgmt` features.
- `docs/ai/ui-align-decisions/*` still describe D31 as creator + 3; those historical docs were not edited.
