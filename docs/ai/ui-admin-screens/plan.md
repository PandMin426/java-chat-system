# PLAN — ui-admin-screens

| Field | Value |
|---|---|
| Feature name | `ui-admin-screens` |
| Created | 08/11/2026 |
| Owner(s) | Trang |
| Status | `DONE` |
| Plan approved by user | YES (08/11/2026) |

---

## 1. SUMMARY

Build every screen of the admin subsystem (`admin.jar`) as JavaFX FXML views matching the approved prototype (boards S10–S17). V1 deliverable: screens only, with sample data for report screenshots; no server, socket or database code.

---

## 2. INPUT / OUTPUT

### Input
- Prototype boards `A-*.dc.html` in `../design-ui/prototype-canvas/project/` (published at https://claude.ai/artifact/MxZtuhNSYunZ2YF3Z4odwA)
- Use cases UC-30..UC-46 in `docs/ai/requirements-analysis/use-case-specification.md`
- Skeleton and `theme.css` from `project-setup`; answers to questions 1–5 of `docs/ai/ui-user-screens/plan.md` (same decisions apply here)

### Output / Expected result
- `mvnw.cmd -pl src/admin javafx:run` opens the admin login window; every admin screen and dialog can be reached and looks like its prototype board
- Every FXML file loads without exception (automated test)

---

## 3. SCOPE

### In scope
| Screen | FXML | Main JavaFX controls |
|---|---|---|
| S10 Đăng nhập quản trị | `AdminLoginView.fxml` | Dark StackPane + VBox card |
| Main window shell | `AdminMainView.fxml` | BorderPane: left nav (group labels "Quản lý", "Thống kê", ToggleButtons, spam count badge), center host |
| S11 Người dùng | `UsersView.fxml` | Search TextField, 2 status ComboBoxes, TableView (sortable only on Họ tên, Ngày tạo), pagination row, detail pane with TabPane: Thông tin / Lịch sử đăng nhập / Bạn bè, action buttons (Sửa, Đặt lại mật khẩu, Khóa/Mở khóa, Xóa) |
| S11 dialogs | `UserFormDialog.fxml`, `ResetPasswordDialog.fxml` | GridPane form; password field + "Tạo ngẫu nhiên"; CheckBox "Gửi qua email" |
| S12 Nhật ký đăng nhập | `LoginLogView.fxml` | 2 DatePickers, search, TableView (Thời gian, Tên đăng nhập, Họ tên, IP) |
| S13 Nhóm chat | `GroupsView.fxml` | TableView (sortable on Tên nhóm, Ngày tạo) + detail TabPane: Thành viên / Admin |
| S14 Báo cáo spam | `SpamView.fxml` | 2 DatePickers, username filter, status ComboBox, TableView (sortable on Thời gian, Bị báo cáo) with action column (Bỏ qua, Khóa tài khoản) |
| S15 Đăng ký mới | `NewUsersView.fxml` | TabPane: "Biểu đồ theo năm" (year ToggleButtons + `BarChart` months × count) / "Danh sách" (DatePickers + TableView) |
| S16 Thống kê bạn bè | `FriendStatsView.fxml` | Name filter, operator ToggleButtons (Tất cả, =, <, >), Spinner, TableView with "Bạn trực tiếp" and "Tính cả bạn của bạn" columns |
| S17 Người dùng hoạt động | `ActiveUsersView.fxml` | TabPane: "Danh sách" (DatePickers, metric + operator ToggleButtons, Spinner, TableView with 3 count columns) / "Biểu đồ theo năm" (`BarChart`) |

### Out of scope
- Filtering, locking, deleting, password reset logic and data loading (V2)
- Charts' data from the database (V1 uses sample values, labelled "Dữ liệu mẫu")
- Dashboard screen (not required by the PDF)

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | ASSUMPTION | Navigation, sample data, icons, fonts and screenshot tool follow the answers to questions 1–5 in `docs/ai/ui-user-screens/plan.md` (all "yes / recommended", 08/11/2026) | CONFIRMED (08/11/2026) |
| 2 | ASSUMPTION | Table sorting uses TableView's built-in header click; columns not required to sort are `sortable="false"` | CONFIRMED (08/11/2026) |
| 3 | ASSUMPTION | Bar charts: one series, bars in `#151515`, current month in accent `#1764D8`, a Tooltip with the exact value on each bar (dataviz rule: hover layer by default) | CONFIRMED (08/11/2026) |
| 4 | ASSUMPTION | Table cell values come from small Java records in `SampleData`, bound with `setCellValueFactory(c -> new SimpleStringProperty(...))` | CONFIRMED (08/11/2026) |

---

## 5. APPROACH

### Step 1: App entry and navigation shell
- **Action:** `AdminApp` loads `AdminLoginView.fxml`; `AdminNavigator` switches login ↔ main window, swaps center content from the left nav, opens the two dialogs. `admin.css` for admin-only styles.
- **Verify:** Login button opens `UsersView`; each nav item opens its view.

### Step 2: User management (S11 + dialogs)
- **Action:** `UsersView` with table + detail pane; `UserFormDialog` (add/edit, username disabled in edit mode); `ResetPasswordDialog`.
- **Verify:** All A1a–A1f entry points visible: filters, sort headers, add, edit, delete, lock, reset password, login-history tab, friends tab.

### Step 3: Log, groups, spam (S12–S14)
- **Action:** `LoginLogView`, `GroupsView`, `SpamView` + controllers.
- **Verify:** A2, A3a–d, A4a–d entry points visible (filters, sorts, member/admin tabs, lock button).

### Step 4: Statistics (S15–S17)
- **Action:** `NewUsersView`, `FriendStatsView`, `ActiveUsersView` with BarCharts and tables.
- **Verify:** A5–A9 entry points visible: date range, year chooser, =/</> filters, two friend-count columns, three activity columns; x-axis T1–T12.

### Step 5: Automated load test
- **Action:** JUnit 5 `FxmlLoadTest` loads every `*.fxml` under `/com/chatapp/admin/view/` (+ `ScreenshotTool` if chosen).
- **Verify:** `mvnw.cmd -pl src/admin -am test` passes.

### Alternatives considered
- Separate Stage per admin screen: rejected — one main window with left nav matches the prototype and is easier to demo.
- Third-party chart library (JFreeChart): not needed; JavaFX `BarChart` covers A6 and A9.

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| MODIFY | `src/admin/pom.xml` | Add Ikonli (if chosen) and JUnit 5 test dependency |
| MODIFY | `src/admin/src/main/java/com/chatapp/admin/AdminApp.java` | Load login view instead of empty window |
| CREATE | `src/admin/src/main/java/com/chatapp/admin/AdminNavigator.java` | Scene/center/dialog switching |
| CREATE | `src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java` | Sample rows and chart values |
| CREATE | `src/admin/src/main/java/com/chatapp/admin/controller/` `AdminLoginController`, `AdminMainController`, `UsersController`, `UserFormController`, `ResetPasswordController`, `LoginLogController`, `GroupsController`, `SpamController`, `NewUsersController`, `FriendStatsController`, `ActiveUsersController` (`.java`) | One controller per view |
| CREATE | `src/admin/src/main/resources/com/chatapp/admin/view/` 11 FXML files listed in section 3 | Views |
| CREATE | `src/admin/src/main/resources/com/chatapp/admin/admin.css` | Admin-only styles (nav, chart colors) |
| MODIFY | `src/common/pom.xml` | Iteration 2: `javafx-controls` dependency for `DateFields` |
| CREATE | `src/common/src/main/java/com/chatapp/common/DateFields.java` | Iteration 2: dd/MM/yyyy DatePicker converter for both apps |
| MODIFY | `src/common/src/main/resources/com/chatapp/common/theme.css` | Iteration 2: no cell borders on selected / empty table rows |
| MODIFY | `src/user/src/main/java/com/chatapp/user/controller/RegisterController.java`, `ProfileController.java` | Iteration 2: use `DateFields` |
| CREATE | `src/admin/src/main/java/com/chatapp/admin/controller/Tables.java` | Iteration 1: shared column binding |
| CREATE | `src/admin/src/main/java/com/chatapp/admin/controller/MonthlyChart.java` | Iteration 1: shared monthly bar chart |
| CREATE | `src/admin/src/test/java/com/chatapp/admin/FxTestSupport.java` | Iteration 1: JavaFX start-up and FX-thread helper for tests |
| CREATE | `src/admin/src/test/java/com/chatapp/admin/NavigationTest.java` | Iteration 1: clicks through nav and dialogs |
| CREATE | `src/admin/src/test/java/com/chatapp/admin/FxmlLoadTest.java` | Loads every FXML |
| CREATE | `src/admin/src/test/java/com/chatapp/admin/ScreenshotTool.java` + `docs/screens/admin/*.png` | Only if chosen |
| CREATE | `docs/ai/ui-admin-screens/ui-admin-screens.md` | Feature description document (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- `org.openjfx:javafx-controls`, `javafx-fxml 21.0.6` — includes `javafx.scene.chart.BarChart`
- `org.kordamp.ikonli:ikonli-javafx`, `ikonli-feather-pack 12.3.1` — only if chosen
- `org.junit.jupiter:junit-jupiter 5.11.4` (test)

### Depends on other features
- `project-setup` — skeleton and theme.
- `ui-user-screens` — answers to the shared questions; no code dependency.

### Technical constraint check (Rule 8)
- [x] This feature uses only `java.net.Socket` / `java.net.ServerSocket` for networking. (N/A — no networking in V1)
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| Default JavaFX BarChart look (colors, legend, gaps) differs from the prototype | MEDIUM | Hide legend (single series), style `.chart-bar` in `admin.css`, set `categoryGap` |
| Wide tables overflow at 1280 px with the detail pane open | LOW | Detail pane fixed at 340 px; table columns with min widths; horizontal scroll allowed |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | All 11 FXML files load | `mvnw.cmd -pl src/admin -am test` → `FxmlLoadTest` passes | PASS (20 tests) |
| 2 | Every admin screen (S10–S17 + 2 dialogs) is reachable from the running app | `NavigationTest` (Iteration 1) | PASS (3 tests) |
| 3 | Each A1–A9 sub-requirement has a visible control on its screen | Checklist A1a…A9 in the feature doc, checked on the screenshots | PASS |
| 4 | Charts show months T1–T12 on the x-axis and counts on the y-axis | `NavigationTest.chartsShowTwelveMonthsAndSwitchYear` + screenshots S15a, S17b | PASS |

---

## 10. ITERATION LOG

## [ITERATION 1 - 08/11]
**Reason for change:** Lessons from `ui-user-screens`: (1) 8 tables need the same column binding/formatting code and 2 screens draw the same bar chart; (2) navigation was verified automatically there with `NavigationTest`, which caught a real bug; the admin app should get the same check. (3) Test helpers cannot be shared across modules without a test-jar.
**Old approach:** Column binding inside each controller; criterion 2 by manual click-through; no shared test helper.
**New approach:** `controller/Tables.java` (bind text / date / number columns, date columns sort by real date), `controller/MonthlyChart.java` (fills a `BarChart` with T1–T12, current month in accent, tooltip on every bar, value label on peak and current month only). Tests: `FxTestSupport.java` (own file), `FxmlLoadTest`, `NavigationTest`, `ScreenshotTool`.
**Impact:** Adds the 4 files above to section 6. Criterion 2 verified by `NavigationTest`. The "Xóa" (delete user) button has no confirm dialog in V1 because the plan lists only 2 dialogs; noted in the feature doc.

## [ITERATION 2 - 08/11]
**Reason for change:** Screenshot review found DatePickers showing "1/11/2026" (admin) and "12/5/2004" (user app, already committed): the vi-VN short date style has no leading zeros, so the locale fix from `ui-user-screens` was not enough. Also: vertical cell borders on the selected table row, and the chart card cut off at the window bottom.
**Old approach:** Rely on the default locale for DatePicker format; table and chart styling only in `admin.css`.
**New approach:** New shared helper `com.chatapp.common.DateFields.useDayMonthYear(DatePicker...)` (dd/MM/yyyy converter; invalid text keeps the previous value) in the `common` module, which therefore gets a `javafx-controls` dependency. Called from every controller with a DatePicker in both apps. Theme: no cell borders on selected rows, no borders on empty rows. `admin.css`: bottom padding under chart cards.
**Impact:** Section 6 gains: MODIFY `src/common/pom.xml`; CREATE `src/common/src/main/java/com/chatapp/common/DateFields.java`; MODIFY `src/common/.../theme.css`; MODIFY `src/user/.../RegisterController.java`, `ProfileController.java` (cross-feature fix of `ui-user-screens`, also corrected in its feature doc). No criteria changed.

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | 08/11/2026 |
| Commit message to use | `feat(ui-admin-screens): add JavaFX screens for the admin subsystem` |
| Notes | 11 FXML views, 24 admin tests passing (48 in total), 13 screenshots in `docs/screens/admin/`. Shared `DateFields` in `common` also fixes the user app's date format. |

---
*Feature description: [ui-admin-screens.md](./ui-admin-screens.md)*
