# FEATURE — ui-admin-screens

| Field | Value |
|---|---|
| Feature name | `ui-admin-screens` |
| Created | 08/11/2026 |
| Last updated | 08/11/2026 |
| Owner(s) | Trang |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

All screens of the admin subsystem (`admin.jar`) as JavaFX FXML views with controllers, built from the approved prototype (boards S10–S17). V1 scope: layout, sample data, header sorting, the detail panes and screen-to-screen navigation. No server, socket, database, filtering or account actions.

---

## 2. PURPOSE / USE CASE

- **Actor:** Instructor reviewing V1; later the system administrator
- **Trigger:** V1 submission (22/11/2026) — "mã nguồn các màn hình của 2 phân hệ"
- **Goal:** Every admin screen can be opened, demoed and screenshotted for the report

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| MODIFIED | `src/admin/pom.xml` | Ikonli (javafx + feather pack), JUnit 5 |
| MODIFIED | `src/common/pom.xml` | `javafx-controls` dependency for `DateFields` |
| CREATED | `src/common/src/main/java/com/chatapp/common/DateFields.java` | dd/MM/yyyy converter for every DatePicker in both apps |
| MODIFIED | `src/common/src/main/resources/com/chatapp/common/theme.css` | No cell borders on selected rows; empty rows without borders |
| MODIFIED | `src/user/.../controller/RegisterController.java`, `ProfileController.java` | Use `DateFields` (fix for the user app) |
| MODIFIED | `src/admin/src/main/java/com/chatapp/admin/AdminApp.java` | Sets vi-VN locale, opens `AdminLoginView` |
| CREATED | `src/admin/src/main/java/com/chatapp/admin/AdminNavigator.java` | Login ↔ main window, content swap, modal dialogs, user form in add/edit mode |
| CREATED | `src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java` | Sample rows and monthly chart values. **Delete in V2.** |
| CREATED | `src/admin/src/main/java/com/chatapp/admin/controller/Tables.java` | Column binding: text / date (sorts by real date, shows dd/MM/yyyy) / number / graphic cells, badges |
| CREATED | `src/admin/src/main/java/com/chatapp/admin/controller/MonthlyChart.java` | One-series monthly BarChart: T1–T12, current month in accent, tooltip on every bar, value label on peak and current month |
| CREATED | `src/admin/src/main/java/com/chatapp/admin/controller/*Controller.java` (11) | One controller per view |
| CREATED | `src/admin/src/main/resources/com/chatapp/admin/view/*.fxml` (11) | Views (table in section 5) |
| CREATED | `src/admin/src/main/resources/com/chatapp/admin/admin.css` | Login, navigation, pages, detail pane, chart styling |
| CREATED | `src/admin/src/test/java/com/chatapp/admin/FxTestSupport.java` | JavaFX start-up / FX-thread helper |
| CREATED | `src/admin/src/test/java/com/chatapp/admin/FxmlLoadTest.java` | 11 views + 7 inside the main window + user form in both modes + view count |
| CREATED | `src/admin/src/test/java/com/chatapp/admin/NavigationTest.java` | Fires nav items and buttons; checks screens, dialogs and chart bar counts |
| CREATED | `src/admin/src/test/java/com/chatapp/admin/ScreenshotTool.java` | Writes report PNGs to `docs/screens/admin/` |
| CREATED | `docs/screens/admin/*.png` (13) | Screenshots for the V1 report |
| MODIFIED | `docs/screens/user/S09-ho-so.png` | Regenerated after the date-format fix |

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - no database changes in this feature.

### Socket messages
N/A - no network communication in this feature.

---

## 5. HOW TO RUN / TEST

### How to run
```powershell
.\mvnw.cmd -q install -DskipTests
.\mvnw.cmd -pl src/admin javafx:run
```
Click "Đăng nhập" (no check in V1) → Người dùng.

| Screen | FXML | Reached from |
|---|---|---|
| S10 Đăng nhập quản trị | `AdminLoginView` | App start, "Đăng xuất" |
| Main window | `AdminMainView` | "Đăng nhập" |
| S11 Người dùng | `UsersView` | Nav "Người dùng" (default) |
| S11 Thêm / Sửa | `UserFormDialog` | "Thêm người dùng", detail "Sửa" |
| S11 Đặt lại mật khẩu | `ResetPasswordDialog` | Detail "Đặt lại mật khẩu" |
| S12 Nhật ký đăng nhập | `LoginLogView` | Nav |
| S13 Nhóm chat | `GroupsView` | Nav |
| S14 Báo cáo spam | `SpamView` | Nav |
| S15 Đăng ký mới | `NewUsersView` | Nav (tabs: chart / list) |
| S16 Số lượng bạn bè | `FriendStatsView` | Nav |
| S17 Người dùng hoạt động | `ActiveUsersView` | Nav (tabs: list / chart) |

### Requirement checklist (criterion 3)

| Req | Control on screen | Where |
|---|---|---|
| A1a | Search field + status/connection dropdowns; sortable "Họ tên", "Ngày tạo" | S11 |
| A1b | "Thêm người dùng", "Sửa", "Xóa" | S11, dialog |
| A1c | "Khóa" / "Mở khóa" | S11 detail |
| A1d | "Đặt lại mật khẩu" | S11 detail, dialog |
| A1e | Tab "Lịch sử đăng nhập" | S11 detail |
| A1f | Tab "Bạn bè" | S11 detail |
| A2 | Date range + table newest first | S12 |
| A3a–A3d | Name filter, sortable "Tên nhóm"/"Ngày tạo", tabs "Thành viên"/"Admin" | S13 |
| A4a–A4d | Sortable "Thời gian"/"Bị báo cáo", date range, username filter, "Khóa tài khoản" | S14 |
| A5a–A5c | Date range, name filter, sortable "Họ tên"/"Thời gian tạo" | S15 list |
| A6 | Year toggle + monthly BarChart | S15 chart |
| A7a–A7d | Name filter, sortable "Họ tên"/"Ngày tạo", =/</> + number, two friend-count columns | S16 |
| A8a–A8d | Date range, name filter, sortable columns, metric + =/</> + number, 3 activity columns | S17 list |
| A9 | Year toggle + monthly BarChart | S17 chart |

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | `.\mvnw.cmd -pl src/admin test` | `FxmlLoadTest` 20 + `NavigationTest` 3 pass | PASS (23/23; 24 with ScreenshotTool) |
| 2 | `.\mvnw.cmd -pl src/admin test -Dtest=ScreenshotTool` | 13 PNGs in `docs/screens/admin/` | PASS, all reviewed |
| 3 | `.\mvnw.cmd -pl src/admin javafx:run` | Login window, clean output | PASS (alive 20 s, clean log) |
| 4 | Whole project `.\mvnw.cmd install -Dtest=FxmlLoadTest,NavigationTest,ScreenshotTool -Dsurefire.failIfNoSpecifiedTests=false` | Both modules green | PASS (48/48) |

---

## 6. TECHNICAL NOTES

- Date columns hold `LocalDate`/`LocalDateTime` and format in the cell, so header sorting is chronological (a dd/MM/yyyy string would sort wrongly). Name columns sort with a vi-VN `Collator`.
- Columns the PDF does not ask to sort are `sortable="false"`.
- `BarChart` resets each bar's style classes when the series is added, so `MonthlyChart` adds the `current` class, tooltips and value labels afterwards. Value labels are unmanaged `Text` nodes so they do not resize the bars.
- Dataviz rules applied: one series → no legend (the title names it), recessive horizontal grid only, value labels only on peak and current month, tooltip on every bar, text in ink colors.
- FXML cannot load `SpinnerValueFactory.IntegerSpinnerValueFactory` as an element here; spinners use the `Spinner(min, max, initialValue)` constructor arguments instead.
- Networking: none; no WebSocket.

### Differences from the prototype
- Not wired in V1 (need logic): filters, search, pagination, lock/unlock, delete, ignore/lock spam, "Xem", "Tạo ngẫu nhiên". Tables show the sample rows that match the default filter shown (e.g. "> 5").
- "Xóa" has no confirm dialog yet (plan lists 2 dialogs only).
- Every group shows the same sample members; every user shows the same login history and friends.
- Login uses the 1280×800 main stage instead of an 880×620 window.

### Changes from the original plan
Iteration 1: `Tables`, `MonthlyChart`, `FxTestSupport`, `NavigationTest`. Iteration 2: shared `DateFields` in `common` (fixes both apps), theme fixes for selected/empty rows, chart bottom padding.

---

## 7. KNOWN ISSUES / LIMITATIONS

- `SampleData` must be removed when V2 loads real data.
- Same harmless JDK 25 / classpath-mode JavaFX warnings as the user app.
