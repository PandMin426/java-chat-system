# FEATURE — ui-align-decisions

| Field | Value |
|---|---|
| Feature name | `ui-align-decisions` |
| Created | 17/11/2026 |
| Last updated | 17/11/2026 |
| Owner(s) | Jul |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

Updates the V1 JavaFX screens of both apps so they match the business decisions D1–D43 of the analysis doc (section 3, column "Đề xuất mặc định"), with the user's answers: D10 stays as it was, D22 counts only level-2 friends. Screens that already matched were left untouched. Still V1: sample data and navigation only.

---

## 2. PURPOSE / USE CASE

- **Actor:** User and Admin (reviewers of the V1 screens; the team building V2 on top of them)
- **Trigger:** Opening the V1 apps or the screenshots in `docs/frontend/screens/`
- **Goal:** Every screen shows the agreed behaviour, so V2 implements the same rules the screens show

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml` | D8: username hint 3–30 characters |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/ForgotPasswordView.fxml` | D9: email field only; email-only error; sent note asks to change the password after login |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/ForgotPasswordController.java` | Removed `usernameField` |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/MainView.fxml` | D9: hidden `passwordReminder` banner (top) with "Đổi mật khẩu" → `onProfile` |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/ChatView.fxml` | D29: AI mode "Sửa câu" |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/ChatViews.java` | D24: unread `badge count` on conversation rows; D18: block note mentions shared groups |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/SearchMessagesView.fxml` | D26: no conversation filter, 1-1-only note, 1-1 preview header |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/SearchMessagesController.java` | D26: 1-1 preview, "Mở cuộc trò chuyện" → ChatView |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/GroupChatView.fxml` | D26/D29: removed group search and AI buttons; D35: E2EE consequence line; D33: "Rời nhóm" button |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/GroupChatController.java` | D33: `onLeave` opens TransferAdminDialog for the last admin, else a "Rời nhóm?" confirm |
| CREATED | `src/user/src/main/resources/com/chatapp/user/view/TransferAdminDialog.fxml` | D33: D06 dialog, pick the new admin |
| CREATED | `src/user/src/main/java/com/chatapp/user/controller/TransferAdminController.java` | One `radio-row` per other member; confirm disabled until one is chosen |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/CreateGroupDialog.fxml` | D31: "Thêm ít nhất 3 người khác" (**Superseded 20/11/2026 by ui-username-group-size:** "ít nhất 3 người, tính cả bạn: thêm ít nhất 2 người khác") |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/MemberPicker.java` | New `minPicked` parameter; confirm disabled while fewer are picked |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/CreateGroupController.java` | `minPicked = 3` (D31) (**Superseded 20/11/2026 by ui-username-group-size:** `minPicked = 2`) |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/AddMemberController.java` | `minPicked = 1` |
| MODIFIED | `src/user/src/main/resources/com/chatapp/user/view/ReportSpamDialog.fxml` | D37: five reason check boxes (multi-select) |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/ReportSpamController.java` | "Gửi báo cáo" disabled while no reason is ticked |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/controller/FriendsController.java` | D37: removed "Báo cáo spam…" from the friend row menu |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/sample/SampleData.java` | `Conversation.unread`; 1-1-only `SEARCH_HITS` (no `group` field); current user is the only group admin; 3 picked members; non-friend in add-member suggestions |
| MODIFIED | `src/user/src/test/java/com/chatapp/user/NavigationTest.java` | Updated the search → open chat path; new tests for D31, D33, D37 |
| MODIFIED | `src/user/src/test/java/com/chatapp/user/ScreenshotTool.java` | D05 note text; new D06 screenshot |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/SpamView.fxml` | D37/D38: "Lý do" column, subtitle on lock / dismiss |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/controller/SpamController.java` | Reason column; action cell by `SpamStatus` (pending: "Khóa tài khoản" + "Bỏ qua"; resolved; dismissed) |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java` | `SpamStatus` enum, `SpamRow.reasons/status`; `FriendStatRow.friendsOfFriends` with level-2 values |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/controller/FriendStatsController.java` | Uses `friendsOfFriends` |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/FriendStatsView.fxml` | D22: subtitle, column "Bạn của bạn (cấp 2)", example |
| MODIFIED | `src/admin/src/main/resources/com/chatapp/admin/view/ActiveUsersView.fxml` | D39: "mở ứng dụng = số lần đăng nhập thành công" |
| MODIFIED | `src/admin/src/test/java/com/chatapp/admin/NavigationTest.java` | New SpamView subtitle text |
| MODIFIED | `docs/frontend/screens/user/*.png`, `docs/frontend/screens/admin/*.png` | Regenerated; new `docs/frontend/screens/user/D06-chuyen-quyen-admin.png` |

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - no database changes. The screens now differ from `script/schema.sql` in these points, to be handled by the database owner:
- D31: groups need the creator + at least 3 members (schema comment says at least one other member). **Superseded 20/11/2026 by ui-username-group-size:** the approved DB baseline requires at least 3 people including the creator; screens follow it.
- D37/D38: `spam_reports` has no reason and no status (PENDING / RESOLVED / DISMISSED) columns.
- D39: "mở ứng dụng" = one successful login, while the schema also has `app_open_events`.
- D9: no flag to show the "đổi mật khẩu" reminder after a login with a reset password.

### Socket messages
N/A - no network communication (V1 screens only).

---

## 5. HOW TO RUN / TEST

### Prerequisites
- JDK 21 and the Maven wrapper of the project.

### How to run
```bash
./mvnw -B test
./mvnw -B -pl src/user,src/admin -am test -Dtest=ScreenshotTool -Dsurefire.failIfNoSpecifiedTests=false
```

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | `./mvnw -B test` | All views load: user 29/29, admin 23/23 tests pass | PASS |
| 2 | Open `docs/frontend/screens/user/S03-quen-mat-khau.png` | Only the email field | PASS |
| 3 | Open `S04-tro-chuyen.png` / `S05-nhom-chat.png` | Blue unread counts on conversation rows | PASS |
| 4 | Open `S08-tim-tin-nhan.png`, `S05-nhom-chat.png` | 4 results, all 1-1, no filter; group header without search, composer without AI | PASS |
| 5 | `NavigationTest.createGroupNeedsThreeMembers` | "Tạo nhóm" enabled with 3 picked, disabled after removing one | PASS |
| 6 | `NavigationTest.lastAdminLeavingPicksNewAdmin` | "Rời nhóm" opens "Chuyển quyền admin"; confirm enabled only after a choice | PASS |
| 7 | `NavigationTest.spamReportNeedsReason` | Send disabled with no reason; Friends menu has no report item | PASS |
| 8 | Open `docs/frontend/screens/admin/S14-bao-cao-spam.png` | "Lý do" column; pending row has "Khóa tài khoản" + "Bỏ qua"; others show "Đã xử lý · đã khóa" / "Đã bỏ qua" | PASS |
| 9 | Open `docs/frontend/screens/admin/S16-so-luong-ban-be.png` | Column "Bạn của bạn (cấp 2)"; example gives 1 for A | PASS |

---

## 6. TECHNICAL NOTES

- Search and the AI assistant are removed from groups (not greyed out) because D36 makes every group end-to-end encrypted, and D35 rules out search and LLM on encrypted groups.
- `GroupChatController.onLeave` decides with the sample members: if every admin is the current user, the transfer dialog opens. V2 must use the real membership.
- The report dialog ticks "Quảng cáo, bán hàng" in V1 so the screenshot shows a valid state; V2 should start with nothing ticked.
- Networking: none in this feature; no WebSocket is used anywhere.

### Changes from the original plan
Iteration 1: `MainController.java` did not need a change (the banner link reuses `onProfile`), and `src/admin/.../NavigationTest.java` had to be updated for the new SpamView subtitle.

---

## 7. KNOWN ISSUES / LIMITATIONS

- The D9 reminder banner is never shown in V1 (it needs a server flag; see section 4).
- Buttons such as "Khóa tài khoản", "Bỏ qua", "Gửi báo cáo", "Chuyển quyền và rời nhóm" only close dialogs or do nothing; the actions come with the V2 features (spam-report, group-chat, admin-user-mgmt).
- A report can still be opened from the chat menu of any 1-1 chat; V2 must hide it when the other person never sent a message, or a report is already pending (D37).
