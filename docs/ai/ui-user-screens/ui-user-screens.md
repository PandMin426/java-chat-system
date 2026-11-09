# FEATURE — ui-user-screens

| Field | Value |
|---|---|
| Feature name | `ui-user-screens` |
| Created | 08/11/2026 |
| Last updated | 08/11/2026 |
| Owner(s) | Trang |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

All screens of the user subsystem (`user.jar`) as JavaFX FXML views with controllers, built from the approved prototype (boards S01–S09, D01–D03). V1 scope: layout, sample data and screen-to-screen navigation only. No server, socket, database or validation code.

---

## 2. PURPOSE / USE CASE

- **Actor:** Instructor reviewing V1; later the end user
- **Trigger:** V1 submission (22/11/2026) — "mã nguồn các màn hình của 2 phân hệ"
- **Goal:** Every user screen can be opened, demoed and screenshotted for the report

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| MODIFIED | `pom.xml` | Versions for Ikonli 12.3.1 and JUnit 5.11.4 |
| MODIFIED | `src/user/pom.xml` | Ikonli (javafx + feather pack), JUnit 5 |
| MODIFIED | `src/common/src/main/resources/com/chatapp/common/theme.css` | Combo-box display cell, arrow buttons, checkbox mark color |
| MODIFIED | `src/user/src/main/java/com/chatapp/user/UserApp.java` | Sets vi-VN locale, opens `LoginView` |
| CREATED | `src/user/src/main/java/com/chatapp/user/Navigator.java` | Switches auth screens ↔ main window, swaps main content, opens modal dialogs and the generic confirm dialog |
| CREATED | `src/user/src/main/java/com/chatapp/user/sample/SampleData.java` | Hardcoded sample rows (records). **Delete in V2.** |
| CREATED | `src/user/src/main/java/com/chatapp/user/controller/ChatViews.java` | Shared builders: avatar with status dot, conversation cell, message bubble with search highlight, confirm dialogs |
| CREATED | `src/user/src/main/java/com/chatapp/user/controller/*Controller.java` (13) | One controller per view |
| CREATED | `src/user/src/main/resources/com/chatapp/user/view/*.fxml` (13) | Views (see table in section 5) |
| CREATED | `src/user/src/main/resources/com/chatapp/user/user.css` | User-app styles: rail, conversation column, bubbles, side panels, chips, dialogs |
| CREATED | `src/user/src/test/java/com/chatapp/user/FxmlLoadTest.java` | Loads every FXML (+ 6 views inside the main window); also holds `FxTestSupport` |
| CREATED | `src/user/src/test/java/com/chatapp/user/NavigationTest.java` | Fires real buttons/menus and checks which screen or dialog opens |
| CREATED | `src/user/src/test/java/com/chatapp/user/ScreenshotTool.java` | Writes report PNGs to `docs/screens/user/` |
| CREATED | `docs/screens/user/*.png` (13) | Screenshots for the V1 report |

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - no database changes in this feature.

### Socket messages
N/A - no network communication in this feature.

---

## 5. HOW TO RUN / TEST

### Prerequisites
- JDK 21+; run `.\mvnw.cmd -q install` once (builds `common`)

### How to run
```powershell
.\mvnw.cmd -pl src/user javafx:run
```
Click "Đăng nhập" (no check in V1) → main window. Rail: Trò chuyện / Bạn bè / Tìm người dùng / Hồ sơ / Đăng xuất.

| Screen | FXML | Reached from |
|---|---|---|
| S01 Đăng nhập | `LoginView` | App start, "Đăng xuất", back links |
| S02 Đăng ký | `RegisterView` | "Tạo tài khoản" |
| S03 Quên mật khẩu | `ForgotPasswordView` | "Quên mật khẩu?" |
| Main window | `MainView` | "Đăng nhập" |
| S04 Trò chuyện 1-1 | `ChatView` | Rail 1, conversation rows |
| S05 Nhóm chat | `GroupChatView` | Group rows, "Mở cuộc trò chuyện" |
| S08 Tìm tin nhắn | `SearchMessagesView` | "Tìm tin nhắn trong mọi cuộc trò chuyện" |
| S06 Bạn bè | `FriendsView` | Rail 2, "Xem tất cả" |
| S07 Tìm người dùng | `SearchUsersView` | Rail 3, "Tìm người để kết bạn" |
| S09 Hồ sơ | `ProfileView` | Rail 4 (avatar) |
| D01 Tạo nhóm | `CreateGroupDialog` | "Nhóm mới", "Tạo nhóm", "Thêm thành viên" |
| D02 Báo cáo spam | `ReportSpamDialog` | "⋯" › Báo cáo spam…, friend row menu |
| D03/D05 Xác nhận | `ConfirmDialog` | "⋯" › Xóa toàn bộ lịch sử… / Hủy kết bạn / Chặn người này…; member menu › Xóa khỏi nhóm… |

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | `.\mvnw.cmd -pl src/user test` | `FxmlLoadTest` 19 + `NavigationTest` 4 pass | PASS (23/23) |
| 2 | `.\mvnw.cmd -pl src/user test -Dtest=ScreenshotTool` | 13 PNGs in `docs/screens/user/` | PASS |
| 3 | Compare each PNG with its prototype board | Same fields, buttons, menu items | PASS (differences below) |
| 4 | `.\mvnw.cmd -pl src/user javafx:run` | Login window, no exception or CSS warning in output | PASS (process alive after 20 s, clean log) |

---

## 6. TECHNICAL NOTES

- `Navigator` keeps no static view state: the main window's controller is stored as the root node's user data, and `showMain` checks the root actually on screen. (A first version stored it in a static field; `NavigationTest` caught that `buildMain` from another caller left the field pointing at a view not on screen.)
- `Text` nodes have no default style class; `ChatViews.text()` adds `"text"` so `.bubble.me > .text` (white text on dark bubbles) applies.
- List cells created during a layout pass get CSS on the next pulse. On screen this is invisible, but a single `Scene.snapshot` showed the selected conversation empty; `ScreenshotTool` takes one warm-up snapshot first.
- Locale vi-VN is set at start-up for Vietnamese month names. **Correction (08/11/2026, ui-admin-screens Iteration 2):** the vi-VN short style still printed "12/5/2004" (no leading zeros); dd/MM/yyyy now comes from `com.chatapp.common.DateFields`, called in `RegisterController` and `ProfileController`.
- `minWidth="-Infinity"` (USE_PREF_SIZE) keeps the "Gửi" button from shrinking to "…" next to the growing text area.
- Networking: none; no WebSocket.

### Differences from the prototype
- Interactive states not wired in V1 (need logic): closing the AI panel / find bar, "Chỉnh câu" mode content, select-and-delete mode, group rename edit mode, admin-vs-member view switch, forgot-password "sent" state, wrong-password / locked error states on login, register error states. Each screen shows the prototype's default state.
- "Tìm trong cuộc trò chuyện" and "Chọn tin nhắn để xóa" menu items exist but do nothing yet.
- Fonts are Segoe UI / Consolas instead of Inter / JetBrains Mono (user decision).
- Login/register/forgot use the 1280×800 main stage instead of a separate 880×620 window.

### Changes from the original plan
Iteration 1: shared `ChatViews` helper. Iteration 2: theme fixes in `common/theme.css`, vi-VN locale, `NavigationTest` replaces the manual click-through for criterion 2.

---

## 7. KNOWN ISSUES / LIMITATIONS

- JDK 25 prints "Unsupported JavaFX configuration: classes were loaded from 'unnamed module'" (classpath mode, chosen in project-setup) plus native-access warnings; harmless.
- `FxTestSupport` lives in `FxmlLoadTest.java` as a package-private class.
- `SampleData` must be removed when V2 loads real data.
