# PLAN — ui-align-decisions

| Field | Value |
|---|---|
| Feature name | `ui-align-decisions` |
| Created | 17/11/2026 |
| Owner(s) | Jul |
| Status | `DONE` |
| Plan approved by user | YES (17/11/2026) |

---

## 1. SUMMARY

Align the V1 JavaFX screens (user and admin) with the business decisions D1–D43 agreed in section 3 ("Bước 2") of the analysis doc "Đồ án Java – Hệ thống Chat: Phân tích nghiệp vụ & Sequence Diagram" (column "Đề xuất mặc định"). Screens that already match stay untouched; only screens whose text, controls or sample data contradict a decision are changed. Still V1: no server, DB or business logic is added.

---

## 2. INPUT / OUTPUT

### Input
- Decisions D1–D43 (doc section 3.1–3.6, column "Đề xuất mặc định").
- Current V1 screens: `src/user/.../view/*.fxml`, `src/admin/.../view/*.fxml`, their controllers and `SampleData`.

### Output / Expected result
- Every screen affected by a decision shows the decided behaviour (table in section 5, step list).
- One new dialog: "Chuyển quyền admin" (D33).
- All existing FXML load / navigation tests still pass, plus checks for the new behaviour.

---

## 3. SCOPE

### In scope (decision → screen change)

| Decision | Screen(s) | Change |
|---|---|---|
| D8 username 3–30 chars | S02 RegisterView | Hint "4–30 ký tự" → "3–30 ký tự" |
| D9 reset by email only, remind to change password | S03 ForgotPasswordView, MainView | Remove the username field; error/sent texts by email only; sent note adds "đổi mật khẩu sau khi đăng nhập"; hidden reminder banner in MainView (shown by V2 after a login with a reset password) linking to Profile |
| D18 block keeps shared groups | Block confirm (ChatViews.confirmBlock) | Note adds "Trong nhóm chung hai bên vẫn chat bình thường." |
| D22 "bạn của bạn" = level-2 friends only (user answer: option b) | S16 FriendStatsView | Column/subtitle/example count only friends-of-friends, excluding direct friends and self; sample values updated |
| D20 add anyone not blocked | D04 AddMemberDialog | Sample suggestions include a non-friend ("Chưa là bạn"); fix the "friends only" comment |
| D24 unread count | S04/S05 conversation list | Unread-count badge on conversation rows (new `unread` field in `SampleData.Conversation`) |
| D26 + D35/D36 search skips encrypted groups (= all groups) | S08 SearchMessagesView, S05 GroupChatView | Remove the "Mọi cuộc trò chuyện / Chỉ chat 1-1 / Chỉ nhóm" filter; sample hits and preview from 1-1 chats only; note "Nhóm mã hóa đầu cuối không được tìm kiếm"; remove "Tìm trong nhóm" button from the group header |
| D29 LLM modes "Sửa câu" / "Gợi ý trả lời"; off for encrypted groups | S04 ChatView, S05 GroupChatView | Rename toggle "Chỉnh câu" → "Sửa câu"; remove the AI button from the group composer |
| D31 creator + ≥ 3 people | D01 CreateGroupDialog, MemberPicker | Text "Thêm ít nhất 3 người khác"; create button disabled while fewer than 3 picked (add member keeps ≥ 1); sample picks 3 people |
| D33 leave group, last admin picks successor | S05 GroupChatView + new D06 TransferAdminDialog | "Rời nhóm" button in the group info panel; last admin → dialog to pick the new admin; otherwise a "Rời nhóm?" confirm. Sample: current user is the only admin |
| D35 E2EE consequences | S05 group info panel | Line "Không tìm kiếm / không dùng trợ lý AI trong nhóm; đăng nhập máy khác không đọc được tin cũ." |
| D37 report only people who messaged you, with reasons (multi-select) | D02 ReportSpamDialog, S06 FriendsView | Reason check boxes (multi-select), send disabled until ≥ 1 reason; remove "Báo cáo spam…" from the Friends row menu (report only from a conversation) |
| D37 + D38 admin handles report: lock → RESOLVED, "Bỏ qua" → DISMISSED | S14 SpamView | New "Lý do" column; "Xử lý" column: pending → "Khóa tài khoản" + "Bỏ qua", resolved → "Đã xử lý", dismissed → "Đã bỏ qua"; `SpamRow` gets `reasons` and `status` |
| D39 "mở ứng dụng" = 1 successful login | S17 ActiveUsersView | Subtitle states "Lượt mở ứng dụng = số lần đăng nhập thành công" |

### Kept unchanged (already match)
D1–D7, D10 (user decided to keep the current dialog), D11–D17, D19, D21, D23, D25, D27, D28, D30, D32, D34, D36, D40–D43: S01 Login, S09 Profile, S07 SearchUsers, S10 AdminLogin, S11 Users + ResetPasswordDialog, UserFormDialog, S12 LoginLog, S13 Groups, S15 NewUsers, ConfirmDialog, AdminMainView. D3/D43: screens are JavaFX and the charts use JavaFX `BarChart`, matching D43.

### Out of scope
- Server, DB, socket, LLM, SMTP logic (V2 features).
- Changing `script/schema.sql` (conflicts are listed in section 4 for the DB owner).
- Renaming FXML files or screenshot names (e.g. `ResetPasswordDialog.fxml` keeps its name).
- New filters not required by a decision (e.g. spam status filter).

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | QUESTION | RESOLVED 17/11/2026: user chose option (b), count only level-2 friends. Original question: D22 says "(b), COUNT DISTINCT chỉ tính bạn cấp 2". S16 currently counts distinct people up to 2 hops (direct ∪ friends-of-friends, excluding self). Does "chỉ tính bạn cấp 2" mean "up to level 2" (keep S16) or "only level-2, excluding direct friends" (change S16 text/sample)? | RESOLVED |
| 2 | ASSUMPTION | Reason options for D37: "Quảng cáo, bán hàng", "Lừa đảo, giả mạo", "Quấy rối, xúc phạm", "Gửi tin nhắn hàng loạt", "Khác". | CONFIRMED |
| 3 | ASSUMPTION | D37 "only people who sent you messages" → report entry only in the 1-1 chat menu; removed from the Friends row menu. "Chặn luôn người này" check box stays. | CONFIRMED |
| 4 | ASSUMPTION | D33 demo: the user sample makes the current user the only group admin so "Rời nhóm" opens the transfer dialog. | CONFIRMED |
| 5 | ASSUMPTION | Screens follow the doc decisions even where `schema.sql` differs: D31 (schema comment says ≥ 1 other member), D37/D38 (`spam_reports` has no reason/status columns), D39 (schema has a separate `app_open_events`), D9 reminder (no "must change password" flag). These are reported to the DB owner, not fixed here. | CONFIRMED |
| 6 | ASSUMPTION | D29 keeps the AI side panel of S04; "popup gợi ý" in the "Ảnh hưởng" column is not treated as a decision. | CONFIRMED |

---

## 5. APPROACH

### Step 1: Auth screens (D8, D9)
- **Action:** Edit `RegisterView.fxml` hint; `ForgotPasswordView.fxml` + `ForgotPasswordController` (email only); `MainView.fxml` + `MainController` (hidden reminder banner with a link to ProfileView).
- **Verify:** FxmlLoadTest passes; ForgotPasswordView has no username field; banner is not visible by default.

### Step 2: Chat 1-1 and search (D18, D24, D26, D29)
- **Action:** `SampleData` (`Conversation.unread`, 1-1-only `SEARCH_HITS`); `ChatViews` (unread badge, block note); `ChatView.fxml` ("Sửa câu"); `SearchMessagesView.fxml` + `SearchMessagesController` (no filter, note, 1-1 preview, open → ChatView).
- **Verify:** NavigationTest passes; screenshot S04 shows unread badges; S08 shows only 1-1 results.

### Step 3: Group screens (D20, D31, D33, D35)
- **Action:** `CreateGroupDialog.fxml`, `MemberPicker` (minimum count), `CreateGroupController`, `AddMemberController`, `GroupChatView.fxml` (remove search + AI buttons, add E2EE line and "Rời nhóm"), `GroupChatController` (leave → transfer or confirm), new `TransferAdminDialog.fxml` + `TransferAdminController`, `SampleData` (sole admin, 3 picked, non-friend suggestion).
- **Verify:** Create button disabled with 2 picked, enabled with 3; "Rời nhóm" opens "Chuyển quyền admin"; confirm in that dialog is disabled until a member is chosen (new NavigationTest case).

### Step 4: Spam (D37, D38)
- **Action:** `ReportSpamDialog.fxml` + `ReportSpamController` (reasons, send disabled until ≥ 1); `FriendsController` (remove report item); admin `SpamView.fxml`, `SpamController`, admin `SampleData.SpamRow`.
- **Verify:** Send disabled with no reason, enabled after ticking one; SpamView shows "Lý do" column and the three action states.

### Step 5: Admin stats (D22, D39)
- **Action:** `FriendStatsView.fxml` texts + admin `SampleData.FRIEND_STATS` (level-2 only); `ActiveUsersView.fxml` subtitle.
- **Verify:** Admin FxmlLoadTest/NavigationTest pass; screenshot S16 shows the level-2 column.

### Step 6: Tests, screenshots, docs
- **Action:** Update tests whose expected titles change, add the new dialog to `ScreenshotTool`, regenerate `docs/screens/**`, write `ui-align-decisions.md`, update `work-log.md`.
- **Verify:** `mvnw test` green for user and admin modules; regenerated PNGs show the changes.

### Alternatives considered
- Leave V1 screens as they are and apply decisions only in V2: rejected, the user asked to align the screens now.
- Keep group search/AI and grey them out: rejected, D36 makes every group encrypted, so those controls can never work.

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml` | D8 hint |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/ForgotPasswordView.fxml` | D9 email only |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/ForgotPasswordController.java` | Drop `usernameField` |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/MainView.fxml` | D9 hidden reminder banner |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/ChatView.fxml` | D29 "Sửa câu" |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/ChatViews.java` | D24 unread badge, D18 block note |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/SearchMessagesView.fxml` | D26 no filter, note, 1-1 preview header |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/SearchMessagesController.java` | D26 1-1 preview, open ChatView |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/GroupChatView.fxml` | D26/D29/D33/D35 |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/GroupChatController.java` | D33 leave flow |
| CREATE | `src/user/src/main/resources/com/chatapp/user/view/TransferAdminDialog.fxml` | D33 pick new admin |
| CREATE | `src/user/src/main/java/com/chatapp/user/controller/TransferAdminController.java` | D33 dialog logic (V1) |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/CreateGroupDialog.fxml` | D31 text |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/MemberPicker.java` | D31 minimum count |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/CreateGroupController.java` | Pass minimum 3 |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/AddMemberController.java` | Pass minimum 1 |
| MODIFY | `src/user/src/main/resources/com/chatapp/user/view/ReportSpamDialog.fxml` | D37 reasons |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/ReportSpamController.java` | D37 send enabled by reasons |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/FriendsController.java` | D37 remove report item |
| MODIFY | `src/user/src/main/java/com/chatapp/user/sample/SampleData.java` | unread, 1-1 hits, sole admin, picks, suggestions |
| MODIFY | `src/user/src/test/java/com/chatapp/user/NavigationTest.java` | Leave-group / report checks |
| MODIFY | `src/user/src/test/java/com/chatapp/user/ScreenshotTool.java` | D06 dialog screenshot |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/FriendStatsView.fxml` | D22 level-2 texts |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/SpamView.fxml` | D37/D38 columns, subtitle |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/controller/SpamController.java` | D37/D38 reason + status cells |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java` | `SpamRow` reasons + status; level-2 friend counts |
| MODIFY | `src/admin/src/main/resources/com/chatapp/admin/view/ActiveUsersView.fxml` | D39 subtitle |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/controller/FriendStatsController.java` | D22 renamed record field |
| MODIFY | `src/admin/src/test/java/com/chatapp/admin/NavigationTest.java` | New SpamView subtitle (iteration 1) |
| MODIFY | `docs/screens/**/*.png` | Regenerated screenshots |
| CREATE | `docs/ai/ui-align-decisions/ui-align-decisions.md` | Feature description (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- JavaFX 21 and Ikonli (already in the project) — no new library.

### Depends on other features
- ui-user-screens, ui-admin-screens — the V1 screens being changed.

### Technical constraint check (Rule 8)
- [x] This feature uses only `java.net.Socket` / `java.net.ServerSocket` for networking. (No networking at all.)
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| Screens drift from `schema.sql` (D31, D37/D38, D39, D9) | MEDIUM | List the conflicts in the feature doc and work-log NOTE for the DB owner |
| Tests assert old texts/titles | LOW | Run both modules' tests and update the assertions that depend on changed titles |
| D22 changes the A7 query meaning | LOW | Resolved with the user (option b); noted in the feature doc for the admin-stats feature |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | All FXML views still load | `mvnw -pl src/user,src/admin -am test` (FxmlLoadTest) | PASS (user 29/29, admin 23/23) |
| 2 | ForgotPasswordView asks only for email | Screenshot S03 / lookup has no username field | PASS |
| 3 | Conversation rows show unread badges | Screenshot S04 | PASS |
| 4 | Message search shows only 1-1 results, no group filter; group header has no search, composer has no AI button | Screenshots S05, S08 | PASS |
| 5 | Create group: button disabled with < 3 picked, enabled with 3 | NavigationTest case | PASS |
| 6 | "Rời nhóm" (sole admin) opens "Chuyển quyền admin"; its confirm is disabled until a member is chosen | NavigationTest case | PASS |
| 7 | Report spam: send disabled until ≥ 1 reason; Friends menu has no report item | NavigationTest case | PASS |
| 8 | Admin SpamView shows "Lý do" and pending / resolved / dismissed actions | Screenshot S14 | PASS |
| 9 | S16 "bạn của bạn" column counts level-2 friends only (example A–B, A–C, B–D, C–D → 1) | Screenshot S16 | PASS |

---

## 10. ITERATION LOG

## [ITERATION 1 - 17/11]
**Reason for change:** Found while coding and testing.
**Old approach:** Section 6 listed `MainController.java` as modified and did not list the admin `NavigationTest.java`.
**New approach:** The D9 banner link reuses the existing `MainController.onProfile`, so `MainController.java` is not changed. Admin `NavigationTest.java` asserted the old SpamView subtitle, so it now asserts the new subtitle.
**Impact:** Files: -`MainController.java`, +`src/admin/src/test/java/com/chatapp/admin/NavigationTest.java`. Section 9 unchanged.

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | 17/11/2026 |
| Commit message to use | `feat(ui-align-decisions): align V1 screens with business decisions D1–D43` |
| Notes | 15 decisions applied (D8, D9, D18, D20, D22, D24, D26, D29, D31, D33, D35, D37, D38, D39 + D36 via D26); D10 kept by user choice; one new dialog (D06). DB conflicts listed in the feature doc, schema not changed. |

---
*Feature description: [ui-align-decisions.md](./ui-align-decisions.md)*
