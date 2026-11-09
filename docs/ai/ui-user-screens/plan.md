# PLAN — ui-user-screens

| Field | Value |
|---|---|
| Feature name | `ui-user-screens` |
| Created | 08/11/2026 |
| Owner(s) | Trang |
| Status | `DONE` |
| Plan approved by user | YES (08/11/2026) |

---

## 1. SUMMARY

Build every screen of the user subsystem (`user.jar`) as JavaFX FXML views, matching the approved prototype (boards S01–S09, D01–D03). This is the V1 deliverable "mã nguồn các màn hình … chỉ cần giao diện, chưa cần lập trình sự kiện". Screens show sample data so they can be screenshotted for the V1 report; no server, socket or database code.

---

## 2. INPUT / OUTPUT

### Input
- Prototype: https://claude.ai/artifact/MxZtuhNSYunZ2YF3Z4odwA (source `../design-ui/prototype-canvas/project/U-*.dc.html`, `D-*.dc.html`)
- Use cases UC-01..UC-28 and screen inventory (section 7) in `docs/ai/requirements-analysis/use-case-specification.md`
- Skeleton and `theme.css` from feature `project-setup`

### Output / Expected result
- `mvnw.cmd -pl src/user javafx:run` opens the login window; every user screen and dialog of the inventory can be reached and looks like its prototype board
- Every FXML file loads without exception (automated test)

---

## 3. SCOPE

### In scope
| Screen | FXML | Main JavaFX controls |
|---|---|---|
| S01 Đăng nhập | `LoginView.fxml` | StackPane + VBox card, TextField, PasswordField, Hyperlink |
| S02 Đăng ký | `RegisterView.fxml` | GridPane (2 columns), DatePicker, ComboBox, error Labels |
| S03 Quên mật khẩu | `ForgotPasswordView.fxml` | VBox form (form state only) |
| Main window shell | `MainView.fxml` | BorderPane: left icon rail (ToggleButtons), center content host |
| S04 Trò chuyện 1-1 | `ChatView.fxml` | Conversation ListView, online strip, find bar, message ScrollPane, composer, AI side panel, "⋯" MenuButton |
| S05 Nhóm chat | `GroupChatView.fxml` | Same layout + group info panel (rename, members with Admin badge, member MenuButton) |
| S08 Tìm tin nhắn | `SearchMessagesView.fxml` | Results ListView grouped by conversation + preview pane |
| S06 Bạn bè | `FriendsView.fxml` | TabPane: Tất cả / Đang online / Lời mời / Đã chặn, each a ListView |
| S07 Tìm người dùng | `SearchUsersView.fxml` | TextField + ListView with relation buttons |
| S09 Hồ sơ | `ProfileView.fxml` | TabPane: Thông tin / Đổi mật khẩu |
| D01 Tạo nhóm | `CreateGroupDialog.fxml` | Modal Stage: name, member chips (FlowPane), suggestion list, encryption CheckBox |
| D02 Báo cáo spam | `ReportSpamDialog.fxml` | RadioButtons (ToggleGroup), TextArea, CheckBox |
| D03/D05 Xác nhận | `ConfirmDialog.fxml` | Generic title/message/confirm button (used for "xóa lịch sử" and "chặn") |

### Out of scope
- Any network, socket, database or validation logic (V2 features)
- Interactive states that need logic: toggling the AI panel / find bar, message select-and-delete mode, admin-vs-member view switch, forgot-password "sent" state. V1 shows each screen in the prototype's default state.
- Real-time updates, unread counters, online status changes

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | QUESTION | Navigation in V1: wire only screen switching (login → main window, rail → views, links/menus → dialogs) so all screens can be demoed and screenshotted? Recommended: yes — small, and the PDF does not forbid it. **Answer 08/11/2026:** yes. | RESOLVED |
| 2 | QUESTION | Sample data: put hardcoded sample rows (same names as the prototype) in one `SampleData` class, deleted when V2 loads real data? Recommended: yes — empty lists make useless screenshots. **Answer 08/11/2026:** yes. | RESOLVED |
| 3 | QUESTION | Icons: Ikonli (`ikonli-javafx` + Feather pack, 1 dependency, `<FontIcon iconLiteral="fth-search"/>` in FXML) or hand-written `SVGPath` shapes? Recommended: Ikonli. **Answer 08/11/2026:** Ikonli. | RESOLVED |
| 4 | QUESTION | Fonts: Windows system fonts `Segoe UI` + `Consolas` (no files to ship), or bundle Inter + JetBrains Mono `.ttf` (OFL license, ~1 MB) to match the prototype exactly? Recommended: system fonts. **Answer 08/11/2026:** system fonts (Segoe UI + Consolas). | RESOLVED |
| 5 | QUESTION | Add a small `ScreenshotTool` (loads each FXML off-screen and saves `docs/screens/user/*.png` with `Scene.snapshot`) to produce the report screenshots in one command? Recommended: yes. **Answer 08/11/2026:** yes. | RESOLVED |
| 6 | ASSUMPTION | All UI text in Vietnamese, same wording as the prototype | CONFIRMED (08/11/2026) |
| 7 | ASSUMPTION | One controller per FXML; list cells (conversation, message bubble, friend row) built by small cell factories in the controller, not separate FXML files | CONFIRMED (08/11/2026) |

All QUESTION rows must be RESOLVED before coding starts.

---

## 5. APPROACH

### Step 1: App entry and navigation shell
- **Action:** `UserApp` loads `LoginView.fxml`. `Navigator` (one class) switches the stage scene (login/register/forgot ↔ main window), swaps `MainView`'s center content, and opens dialogs as modal `Stage`s. `user.css` adds user-only styles (rail, bubbles, chips) on top of `theme.css`.
- **Verify:** Login button opens the main window; each rail button changes the center view.

### Step 2: Auth screens (S01–S03)
- **Action:** `LoginView`, `RegisterView`, `ForgotPasswordView` + controllers.
- **Verify:** Each matches its prototype board (fields, labels, links) when compared side by side.

### Step 3: Chat screens (S04, S05, S08)
- **Action:** `ChatView`, `GroupChatView`, `SearchMessagesView` + controllers; message bubbles (left/right, highlight, focus ring), conversation cells, AI panel with 3 suggestion cards, group info panel, "⋯" menus with every item from the prototype.
- **Verify:** All UC-14..21 and UC-23..27 entry points are visible: find bar, AI button, menu items (tìm, chọn tin, xóa lịch sử, hủy kết bạn, báo cáo spam, chặn), group rename, add member, member menu (đặt admin, xóa khỏi nhóm).

### Step 4: Friends, search users, profile (S06, S07, S09)
- **Action:** `FriendsView` (4 tabs with the right row actions per tab), `SearchUsersView` (relation button states: Kết bạn / Đã gửi lời mời / Chấp nhận / Bạn bè), `ProfileView` (2 tabs, username field disabled).
- **Verify:** Tab contents and buttons match boards S06, S07, S09.

### Step 5: Dialogs (D01–D03)
- **Action:** `CreateGroupDialog`, `ReportSpamDialog`, `ConfirmDialog` + controllers.
- **Verify:** Dialogs open modally from: "Nhóm mới" button, menu "Báo cáo spam…", menu "Xóa toàn bộ lịch sử…" and "Chặn người này…".

### Step 6: Automated load test (+ screenshots if question 5 = yes)
- **Action:** JUnit 5 `FxmlLoadTest` starts the JavaFX toolkit once and loads every `*.fxml` under `/com/chatapp/user/view/`. Optional `ScreenshotTool`.
- **Verify:** `mvnw.cmd -pl src/user -am test` passes with one assertion per FXML file.

### Alternatives considered
- Building UI in Java code without FXML: rejected — FXML separates layout from logic and can be opened in Scene Builder.
- Separate FXML per list cell: rejected for V1 (more files, no benefit until real data).

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| MODIFY | `src/user/pom.xml` | Add Ikonli (if Q3 = yes) and JUnit 5 test dependency |
| MODIFY | `pom.xml` | Versions for Ikonli 12.3.1 and JUnit 5.11.4 in `dependencyManagement` |
| MODIFY | `src/user/src/main/java/com/chatapp/user/UserApp.java` | Load login view instead of empty window |
| CREATE | `src/user/src/main/java/com/chatapp/user/Navigator.java` | Scene/center/dialog switching |
| CREATE | `src/user/src/main/java/com/chatapp/user/sample/SampleData.java` | Hardcoded sample rows (if Q2 = yes) |
| CREATE | `src/user/src/main/java/com/chatapp/user/controller/` `LoginController`, `RegisterController`, `ForgotPasswordController`, `MainController`, `ChatController`, `GroupChatController`, `SearchMessagesController`, `FriendsController`, `SearchUsersController`, `ProfileController`, `CreateGroupController`, `ReportSpamController`, `ConfirmController` (`.java`) | One controller per view |
| CREATE | `src/user/src/main/java/com/chatapp/user/controller/ChatViews.java` | Iteration 1: shared builders for conversation cells, avatars and message bubbles |
| CREATE | `src/user/src/main/resources/com/chatapp/user/view/` 13 FXML files listed in section 3 | Views |
| CREATE | `src/user/src/main/resources/com/chatapp/user/user.css` | User-app-only styles |
| CREATE | `src/user/src/test/java/com/chatapp/user/FxmlLoadTest.java` | Loads every FXML |
| CREATE | `src/user/src/test/java/com/chatapp/user/NavigationTest.java` | Iteration 2: clicks through navigation and dialogs |
| MODIFY | `src/common/src/main/resources/com/chatapp/common/theme.css` | Iteration 2: combo-box, arrow button and checkbox mark fixes |
| CREATE | `src/user/src/test/java/com/chatapp/user/ScreenshotTool.java` + `docs/screens/user/*.png` | Only if Q5 = yes |
| CREATE | `docs/ai/ui-user-screens/ui-user-screens.md` | Feature description document (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- `org.openjfx:javafx-controls`, `javafx-fxml 21.0.6` (from `project-setup`)
- `org.kordamp.ikonli:ikonli-javafx 12.3.1`, `org.kordamp.ikonli:ikonli-feather-pack 12.3.1` — icons (only if Q3 = Ikonli)
- `org.junit.jupiter:junit-jupiter 5.11.4` (test scope) — FXML load test

### Depends on other features
- `project-setup` — parent POM, `common/theme.css`, `UserApp`.

### Technical constraint check (Rule 8)
- [x] This feature uses only `java.net.Socket` / `java.net.ServerSocket` for networking. (N/A — no networking in V1)
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| JavaFX CSS cannot reproduce some prototype details (e.g. CSS grid, `box-shadow` spread, `:hover` on parents) | MEDIUM | Use JavaFX equivalents (`-fx-effect: dropshadow`, HBox/VBox/GridPane); small visual differences accepted and listed in the feature doc |
| ListView cell factories render wrong sizes for wrapped message text | MEDIUM | Messages use a VBox in a ScrollPane instead of ListView |
| Too much scope for one commit | LOW | Steps 2–5 can be committed as they finish, still under this feature name |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | All 13 FXML files load | `mvnw.cmd -pl src/user -am test` → `FxmlLoadTest` passes | PASS (19 tests: 13 views + 6 views inside the main window) |
| 2 | Every screen of the inventory (S01–S09, D01–D03) is reachable from the running app (if Q1 = yes) | `NavigationTest` (Iteration 2) | PASS (4 tests) |
| 3 | Each screen matches its prototype board in content (all fields, buttons, menu items of the board are present) | Side-by-side comparison per board, recorded in the feature doc | PASS — 13 screenshots reviewed against boards; differences listed in the feature doc |
| 4 | No non-Java UI and no networking code | Review: only `.java`, `.fxml`, `.css` under `src/user` | PASS |

---

## 10. ITERATION LOG

## [ITERATION 1 - 08/11]
**Reason for change:** `ChatView`, `GroupChatView` and `SearchMessagesView` need the same conversation cell, avatar-with-status-dot and message bubble builders; copying them into 3 controllers would triple the code.
**Old approach:** Cell factories live inside each controller.
**New approach:** One package-private helper `com.chatapp.user.controller.ChatViews` with static builders (`avatar`, `conversationCell`, `messageLine`, `fillMessages`), used by the 3 chat controllers.
**Impact:** Adds `src/user/src/main/java/com/chatapp/user/controller/ChatViews.java` to section 6. ScreenshotTool runs as a JUnit class invoked with `-Dtest=ScreenshotTool` (not matched by default Surefire includes, so normal `test` runs skip it). No criteria changed.

## [ITERATION 2 - 08/11]
**Reason for change:** Reviewing the generated screenshots showed theme problems that belong in the shared theme (dropdown display area had a grey background, arrow buttons grey, checkbox tick invisible) and DatePicker showing US format "5/12/2004". Criterion 2 ("every screen reachable") could be checked automatically instead of only by hand.
**Old approach:** Only user-module files change; criterion 2 verified by a manual click-through.
**New approach:** Small fixes in `src/common/.../theme.css` (combo-box list cell, arrow buttons, checkbox mark color). `Navigator.LOCALE` = vi-VN set as default locale at start-up (dd/MM/yyyy dates). New `NavigationTest` fires the real buttons, rail toggles and menu items and asserts which screen or dialog opens.
**Impact:** Adds `src/common/src/main/resources/com/chatapp/common/theme.css` (MODIFY) and `src/user/src/test/java/com/chatapp/user/NavigationTest.java` (CREATE) to section 6. Criterion 2 is now verified by `NavigationTest`. The admin app reuses the same theme fixes.

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | 08/11/2026 |
| Commit message to use | `feat(ui-user-screens): add JavaFX screens for the user subsystem` |
| Notes | 13 FXML views, 23 passing tests, 13 report screenshots in `docs/screens/user/`. Interactive states that need logic stay for V2 (see feature doc). |

---
*Feature description: [ui-user-screens.md](./ui-user-screens.md)*
