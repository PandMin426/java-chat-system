# PLAN — ui-username-group-size

| Field | Value |
|---|---|
| Feature name | `ui-username-group-size` |
| Created | 20/11/2026 |
| Owner(s) | Trang |
| Status | `DONE` |
| Plan approved by user | YES (20/11/2026) |

---

## 1. SUMMARY

Align the V1 screens (UserApp and AdminApp) with two rules of the approved database (`script/schema.sql`, `docs/database/design-baseline.md`): usernames match `^[A-Za-z0-9_]{3,30}$` and are unique/logged in case-insensitively, and a new group starts with at least three people including the creator (creator + 2 others). Today the sample usernames use dots (`bich.tran`), the register hint allows `.` and says usernames are case-sensitive, and the create-group dialog asks for 3 people besides the creator (old Word D31).

---

## 2. INPUT / OUTPUT

### Input
- User opens any screen that shows a username (S01, S02, S04, S06, S07, S09, D01, D04, D05, S11, S11c, S12, S13, S14, S15, S16, S17).
- User opens D01 "Tạo nhóm chat" and picks members.

### Output / Expected result
- Every username shown on any screen (sample data and FXML text) matches `^[A-Za-z0-9_]{3,30}$` (dots replaced with `_`, e.g. `bich.tran` → `bich_tran`). Emails stay unchanged (the DB has no email character rule beyond trimmed/nonblank).
- S02 register hint says: 3–30 characters, unaccented letters, digits and `_` only, not case-sensitive, cannot change later.
- AdminApp S11a "Thêm người dùng": the username hint shows the same rule in add mode ("Không đổi được." stays in edit mode).
- D01: subtitle says the group needs at least 3 people including you (pick at least 2 others); "Tạo nhóm" is disabled while fewer than 2 others are picked.

---

## 3. SCOPE

### In scope
- Rename dotted sample usernames in `user/.../SampleData.java`, `admin/.../SampleData.java` and FXML texts.
- Fix the S02 username hint and add the rule hint to the S11a add form.
- Change D01 minimum from 3 others to 2 others (text, controller, sample picks, test).
- Regenerate the affected screenshots in `docs/screens/`.

### Out of scope
- Real validation (regex check on submit, error labels) — comes with the `auth` / `admin-user-mgmt` features.
- Any change to `schema.sql`, `seed.sql` or the D04 add-member rule (stays "at least 1 new member").
- A maximum group size (the DB has none) — unless the user answers Q1 otherwise.
- Changing emails, full names or other sample data.

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | QUESTION | User wrote "thêm thành viên nhóm tối đa 3 người tính luôn cả admin". The DB baseline says a new group has **at least** 3 people including the creator (creator + 2), with no maximum. User answered: minimum 3 including the creator (creator + at least 2 others), no maximum; D04 stays at least 1. | RESOLVED |
| 2 | ASSUMPTION | Usernames are case-insensitive for uniqueness and login (`users_username_ci_uidx` on `lower(username)`), so the old hint "Phân biệt chữ hoa/thường" is wrong per the current schema. | UNCONFIRMED |
| 3 | ASSUMPTION | Dots are replaced by `_` (`an.nguyen` → `an_nguyen`) so names stay readable; emails keep their dots. | UNCONFIRMED |

---

## 5. APPROACH

### Step 1: Usernames in sample data and FXML
- **Action:** Replace each dotted username literal with the `_` form in both `SampleData.java` files and in LoginView, RegisterView, ProfileView, ChatView, ResetPasswordDialog FXML.
- **Verify:** `grep` for username literals in `src/*/src/main` finds none outside `^[A-Za-z0-9_]{3,30}$` (emails excluded).

### Step 2: Username hints
- **Action:** S02 hint → "3–30 ký tự: chữ cái không dấu, số và dấu _. Không phân biệt chữ hoa/thường, không đổi được về sau." S11a: `UserFormController` shows `usernameHint` in both modes, text = rule in add mode, "Không đổi được." in edit mode.
- **Verify:** screenshots S02, S11a, S11b show the right hint.

### Step 3: Group minimum size
- **Action:** `CreateGroupController` `minPicked` 3 → 2; CreateGroupDialog subtitle → "Nhóm cần ít nhất 3 người, tính cả bạn (chọn ít nhất 2 người khác). Bạn sẽ là admin của nhóm."; `GROUP_PICKED` sample → 2 people; update comments; `NavigationTest.createGroupNeedsThreeMembers` still asserts enabled at 2 picked, disabled at 1.
- **Verify:** `./mvnw -B test` passes; D01 screenshot shows 2 picked and enabled button.

### Step 4: Screenshots and docs
- **Action:** Regenerate screenshots with the existing `ScreenshotTool`; write feature doc and work-log.
- **Verify:** affected PNGs updated and reviewed.

### Alternatives considered
- Strip dots instead of `_` (`bichtran`): less readable; `_` is what the DB allows as a separator.

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| MODIFY | `src/user/src/main/java/com/chatapp/user/sample/SampleData.java` | Usernames `.`→`_`; GROUP_PICKED 2 people; D31 comment |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java` | Usernames `.`→`_` |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/LoginView.fxml` | Username text |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml` | Username text and hint |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml` | Username text |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/ChatView.fxml` | Username text |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/CreateGroupDialog.fxml` | Subtitle (min 3 incl. creator) |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/CreateGroupController.java` | `minPicked` 2 + comment |
| MODIFY | `src/user/src/test/java/com/chatapp/user/NavigationTest.java` | D01 test comment/name |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/ResetPasswordDialog.fxml` | Username text |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/controller/UserFormController.java` | Username hint in add mode |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/UserFormDialog.fxml` | `wrapText` on username hint (Iteration 1) |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/ReportSpamDialog.fxml` | Username in subtitle (Iteration 1) |
| MODIFY | `docs/screens/**.png` | Regenerated screenshots |
| CREATE | `docs/ai/ui-username-group-size/ui-username-group-size.md` | Feature description (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- JavaFX 21, JUnit 5 (already in the project) — no new library.

### Depends on other features
- database-schema — source of the username and group-size rules.

### Technical constraint check (Rule 8)
- [x] This feature uses only `java.net.Socket` / `java.net.ServerSocket` for networking. (No networking in this change.)
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| Missing a dotted username in some screen | MEDIUM | Grep both modules after the change (Step 1 verify) |
| Q1 misread (max vs min) | HIGH | Ask the user before coding |
| Tests look up text that changed | LOW | Run `./mvnw -B test` |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | No username on any screen breaks `^[A-Za-z0-9_]{3,30}$` | grep username literals in `src/*/src/main` | PASS |
| 2 | S02 and S11a hints state the DB rule | Screenshots S02, S11a | PASS |
| 3 | D01 enables "Tạo nhóm" at 2 others, disables at 1 | `NavigationTest.createGroupNeedsThreeMembers` | PASS |
| 4 | All existing tests pass | `./mvnw -B test` (user 29/29, admin 23/23) | PASS |

---

## 10. ITERATION LOG

## [ITERATION 1 - 20/11]
**Reason for change:** The S11a add-mode username hint is a full sentence and gets cut off in a half-width column; also a dotted username (`kevin.tran`) was found in the D02 subtitle and two admin SampleData comments.
**Old approach:** Only `UserFormController` changes for S11a; FXML username list limited to Login/Register/Profile/Chat/ResetPassword.
**New approach:** Add `wrapText="true"` to `usernameHint` in `UserFormDialog.fxml`; rename `kevin.tran` in `ReportSpamDialog.fxml`; update the two comments in admin `SampleData.java`.
**Impact:** Two more files in section 6 (`UserFormDialog.fxml`, `ReportSpamDialog.fxml`); D02 screenshot regenerated; criteria unchanged.

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | 20/11/2026 |
| Commit message to use | `feat(ui-username-group-size): align usernames and group minimum with DB rules` |
| Notes | Sample usernames use `_` instead of `.`; S02/S11a hints state the DB rule (case-insensitive); D01 needs creator + 2 others. No real validation yet (auth / admin-user-mgmt). |

Do NOT write a commit hash here. This file is part of the commit itself, so the hash does not exist yet when the file is written.

---
*Feature description: [ui-username-group-size.md](./ui-username-group-size.md)*
