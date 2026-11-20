# diff.md: CSDL ↔ Giao diện ↔ Thỏa thuận Phần 3 (D1–D43)

Kiểm tra ngày 20/11/2026 trên `main` @ `4e17308` (Merge PR #8 fix_FE_v2).
Nguồn đối chiếu:
- **Phần 3**: mục "3. Bước 2" của doc *Đồ án Java – Hệ thống Chat* (D1–D43, cột "Đề xuất mặc định")
- **CSDL**: `script/schema.sql`, `script/seed.sql`, `docs/database/design-baseline.md`
- **Giao diện (FE)**: `src/user`, `src/admin`, `src/common` (FXML, controller, SampleData)

**Kết luận:** CSDL và các màn hình FE khớp nhau gần như hoàn toàn. **Không có xung đột CSDL ↔ FE nào gây chặn.**
Những gì còn lại:
- **4 chỗ lệch quyết định thật sự.** CSDL/FE đã đổi nhưng Phần 3 vẫn ghi cách cũ, hoặc FE đang hiện một phương án mà Phần 3 đã loại.
- **3 chỗ FE còn thiếu.** CSDL đã lưu các quy tắc này nhưng chưa màn hình nào thể hiện.
- **Một số tên gọi và tài liệu đã cũ.**

---

## A. Xung đột thật (cần chốt và sửa một phía)

| # | D | Phần 3 ghi | CSDL | FE đang hiện | Phía phải sửa | Mức độ |
|---|---|---|---|---|---|---|
| A1 | D31 | "Người tạo + ≥ **3** người" (= 4 người) | ≥ 3 người **tính cả** người tạo (baseline §9.4, §13: "Word D31 creator+three superseded") | D01: "ít nhất 3 người, tính cả bạn: thêm ít nhất **2** người khác", `minPicked = 2` | **Doc Phần 3**: sửa thành "Người tạo + ≥ 2 người" (CSDL và FE đã khớp nhau) | Trung bình |
| A2 | D40 | "tin nhóm: **thành viên của** bao nhiêu nhóm"; "tin riêng: số đoạn hội thoại 1-1" | Số nhóm = COUNT DISTINCT nhóm mà người dùng **đã gửi** tin; số người = COUNT DISTINCT người mà người dùng **đã gửi** tin riêng tới; chỉ nhận mà không gửi thì không tính (baseline §9.6). Baseline còn ghi "do not invent a D40 decision", tức người viết CSDL không biết D40 tồn tại | S17: "số người khác nhau đã được gửi tin riêng và số nhóm đã gửi tin" (khớp CSDL) | **Doc Phần 3**: sửa D40 thành "đã gửi tin". **Baseline**: bỏ các dòng "không có D40" | Trung bình |
| A3 | D10 | Admin **tự gõ** mật khẩu mới (phương án "ngẫu nhiên + gửi email" đã bị loại) | OK: audit `PASSWORD_RESET`, hash do admin nhập | S11c có nút **"Tạo ngẫu nhiên"** và ô **"Gửi mật khẩu mới tới bich.tran@gmail.com"**, chính là phương án đã loại. Gửi email từ AdminApp còn cần `smtp.*`, nhưng D6 chỉ để SMTP trong cấu hình server | **FE**: bỏ ô gửi email (giữ nút ngẫu nhiên cũng được). Cần chốt thêm: admin đặt lại mật khẩu có bật `must_change_password` không (Phần 3 chưa nói) | Trung bình |
| A4 | D33 | Admin cuối rời nhóm → popup chọn admin mới. Không có gì thêm | Có thêm **đóng nhóm ngoại lệ**: nếu không còn ai đủ điều kiện làm admin thì ghi `conversations.closed_at`; vẫn đọc được tin cũ, không gửi/thêm người được nữa. Bước "chuyển quyền hoặc đóng nhóm" này cũng chạy khi admin hệ thống **xóa mềm** một user đang là admin cuối của nhóm (§9.4) | Chỉ có `TransferAdminDialog`. S05 không có trạng thái "nhóm đã đóng" (ô soạn tin vẫn bật), S13 không có cột trạng thái, nút "Xóa" ở S11 không có bước chuyển quyền/đóng nhóm | **Doc Phần 3**: thêm quy tắc đóng nhóm. **FE (V2)**: banner nhóm đã đóng + khóa ô soạn tin, nhãn "đã đóng" ở S13, kiểm tra nhóm trong luồng xóa ở S11 | Trung bình |
| A5 | D37 | Bắt buộc có lý do, chọn nhiều | `spam_reports.reason` là **một** cột text **không bắt buộc** | Bắt tick ≥ 1; dữ liệu mẫu nối các nhãn bằng `"; "` | **Cả nhóm**: chốt cách lưu (nối nhãn bằng `"; "`?). Có thể đổi `reason` thành NOT NULL | Thấp |

## B. FE còn thiếu so với quy tắc CSDL đã lưu

| # | Chủ đề | CSDL | FE hiện tại | Cách sửa (V2) | Mức độ |
|---|---|---|---|---|---|
| B1 | D12 kết quả đá phiên | `admin_audit_log` có `CONTROL_REQUESTED/ACKNOWLEDGED/FAILED/UNKNOWN`. Baseline §9.6: FAILED/UNKNOWN **phải hiện ra và cho thử lại thủ công** | Nút "Khóa" ở S11 và "Khóa tài khoản" ở S14 không có chỗ báo "đá phiên thất bại / thử lại" | Thêm dòng trạng thái/nút thử lại sau khi khóa | Trung bình |
| B2 | Tài khoản demo | Admin trong seed là `demo_admin`, mọi hash đều là `DB_FIXTURE_NOT_BCRYPT` | `AdminLoginView` điền sẵn `admin` / `admin@2026`; `LoginView`/`RegisterView` điền sẵn `an_nguyen` / `matkhau123` bằng `text=`. Không tài khoản nào có trong seed | Dùng `promptText` thay cho `text`; thêm seed demo có hash BCrypt thật | Thấp |
| B3 | Kết nối của AdminApp | D1/D6: AdminApp → CSDL qua JDBC (`db.*`); chỉ nối server để đá phiên (D12) | Chân trang `AdminLoginView`: "Máy chủ localhost:9999 · config.properties" | Hiện địa chỉ CSDL (hoặc cả hai) | Thấp |

## C. Sai tên / sai chú thích (không đổi hành vi, chỉ sửa chữ)

### C1. Cột "Ảnh hưởng" của Phần 3 so với tên thật trong schema

| D | Phần 3 ghi | Schema thật |
|---|---|---|
| D7 | `role` | `users.system_role` |
| D14 | `login_time` | `login_history.logged_in_at` + `username_snapshot`, `full_name_snapshot` |
| D15 | `CHECK (user_a < user_b)` | `friendships` `CHECK (user_low_id < user_high_id)` |
| D18 | bảng `blocks` | `user_blocks` |
| D34 | `joined_at` | `membership_periods.joined_at` |
| D35 | `user_keys`, `group_keys` | `e2ee_devices`, `group_key_epochs`, `group_key_grants` |
| D36 | `conversations.is_encrypted` | **không tồn tại**: mọi GROUP đều mã hóa (`messages_payload_shape_check`) |
| D42 | `users.status` | `users.account_status` (ACTIVE/LOCKED) + `deleted_at` |

### C2. Các dòng Phần 3 đã lỗi thời

- **D3**: đề xuất Swing + FlatLaf. Code dùng JavaFX, và D43 cũng ghi JavaFX.
- **D4**: "MySQL 8 hoặc PostgreSQL". Đã chốt PostgreSQL 17.
- **D26**: "U11.g gồm cả nhóm không mã hóa". Từ D36 không còn nhóm nào không mã hóa. CSDL không tìm trong nhóm, và FE S08 ghi "Chỉ tìm trong chat 1-1".

### C3. CSDL có cột không ai dùng

- `login_history.remote_ip` (inet, cho phép NULL). Baseline ghi là "optional source for existing admin UI", nhưng S12 và tab lịch sử đăng nhập ở S11 không có cột IP, D14 cũng không nhắc IP. Hoặc bỏ cột, hoặc sửa câu trong baseline.

### C4. Chú thích sai trong code FE

- `src/admin/.../sample/SampleData.java`, javadoc của `GroupRow`: "the creator is not stored". CSDL có lưu `conversations.created_by_user_id`.
- `src/user/.../sample/SampleData.java`, javadoc của `SEARCH_USERS`: "usernames match exactly". CSDL so khớp username **không phân biệt hoa/thường** (`lower(username)`, baseline §9.6), và gợi ý ở S02 cũng đã ghi như vậy.

### C5. Tài liệu cũ trong repo mâu thuẫn với CSDL + FE + Phần 3

| File | Nội dung đã cũ |
|---|---|
| `docs/ai/requirements-analysis/use-case-specification.md` | K4 / UC-28 (d.423, d.529): "server giữ khóa, mã hóa khi lưu trữ (không phải E2EE)". d.428: có tùy chọn bật/tắt mã hóa. BR-05 d.216, d.460, d.466: lịch sử đăng nhập lưu **IP**. M18 d.46: **mọi thành viên được đổi tên**, trong khi D32 chỉ cho admin |
| `docs/frontend/ai/ui-align-decisions/ui-align-decisions.md` §4 | Ghi rằng CSDL thiếu lý do/trạng thái báo cáo spam, vẫn còn `app_open_events`, và không có cờ nhắc đổi mật khẩu. Cả ba đã có trong schema hiện tại |
| `README.md` d.27 | "Backend: framework chưa thống nhất". D1/D2 đã chốt: `server.jar` TCP thuần, JSON mỗi dòng |

---

## D. Đã kiểm tra và khớp (không cần làm gì)

D1–D2 (giao thức, chưa làm), D5 `password_hash`, D6, D8 (regex `^[A-Za-z0-9_]{3,30}$` = gợi ý trên FE), D9 (`must_change_password` + banner ở MainView), D11 (xóa mềm; S11 không hiện tài khoản đã xóa), D12 (câu chữ khi khóa), D13, D16, D17, D18 (tìm kiếm một chiều, nhóm chung không bị ảnh hưởng), D19 (nhãn "Người lạ"), D20 (D01/D04 gợi ý cả người chưa là bạn), D21 (không có cột online, không có "hoạt động lần cuối"), D22 (chỉ bạn cấp 2, cùng ví dụ A–B–C–D), D23, D24 (`last_read_message_id` + số tin chưa đọc), D25 (`message_hidden`, `cleared_at`), D27 (nhảy tới tin theo message_id + conversation_id), D28 (50 tin, "Cuộn lên để tải thêm"), D29 (AI chỉ ở chat 1-1, có câu cảnh báo), D30 (chỉ text), D32 (mọi thành viên thêm người; admin đổi tên/xóa/gán quyền, khớp menu admin trên FE), D34 (FE: "chỉ xem được tin nhắn gửi từ lúc mình tham gia"), D35/D36 (bắt buộc E2EE, câu chữ FE khớp), D38 (RESOLVED/DISMISSED), D39 (lượt mở = số dòng `login_history`), D41, D42 (S11 lọc Hoạt động/Bị khóa + Online/Offline), D43 (biểu đồ JavaFX).

---

## E. File thừa: đề xuất xóa

| # | Đường dẫn | Lý do | Cách làm |
|---|---|---|---|
| E1 | `src/admin/target/`, `src/common/target/`, `src/user/target/` (**52 file đang được track**: 3 jar, 2 `run.png`, surefire reports, maven-status) | Sản phẩm build. Đã có trong `.gitignore` (`**/target/`) nhưng bị commit từ trước, nên mỗi lần chạy `mvnw test` là `git status` lại bẩn (hiện có 13 file modified) | `git rm -r --cached src/admin/target src/common/target src/user/target`. Lệnh này chỉ bỏ track, vẫn giữ file trên máy |
| E2 | `docs/database/reports/Xung đột màn hình và CSDL.md`, `…/Xung đột lấy CSDL làm chuẩn.md`, `…/Xung đột lấy CSDL làm chuẩn - đầy đủ V2.md` | Viết cho schema **cũ** (`app_open_events`, `private_message_hides`, `group_messages`, "DB không lưu IP", "chỉ admin thêm thành viên"). Đã được thay bằng `design-baseline.md` và file diff này. Bản V1 chỉ là bản kém đầy đủ hơn của V2 | Xóa (lịch sử git vẫn giữ) |
| E3 | `docs/database/research_notes/Xung đột màn hình và CSDL/` (4 file: `admin.md`, `csdl_tai_lieu.md`, `user_chat_ban_be.md`, `user_tai_khoan.md`) | Ghi chú thô làm ra E2, cũng dựa trên schema cũ | Xóa cùng E2 |
| E4 | `src/admin/.gitkeep`, `src/user/.gitkeep`, `script/.gitkeep`, `docs/ai/_template/.gitkeep` | File giữ chỗ trong các thư mục giờ đã có file thật | Xóa. **Giữ** `docs/backend/.gitkeep`, `git/.gitkeep`, `release/.gitkeep`: các thư mục này vẫn trống và có trong cấu trúc của README |
| E5 | `.gitignore` dòng 1 đến khoảng 150 | Mẫu Node/JS (npm, yarn, Next.js, Nuxt, Gatsby, Vite…) trong một dự án Java/Maven. Chỉ khối cuối (`**/target/`, `*.class`, `.idea/`, …) là có tác dụng | Cắt file còn khối Java (sửa, không xóa file) |
| E6 | Nhánh `feature/project-setup`, `feature/ui-admin-screens`, `feature/ui-user-screens`, `fix_FE`, `fix_FE_v2` (local + origin) và `origin/docs/review-docs` | Tất cả đã merge hết vào `main` (`git branch --no-merged main` trả về rỗng) | Tùy chọn: `git branch -d …` / `git push origin --delete …` |

**Giữ lại:** cả hai `SampleData.java` (đến khi V2 tải dữ liệu thật), `ScreenshotTool.java` (dùng để tạo lại `docs/frontend/screens/*.png`), các log/plan trong `docs/ai/**`, và `use-case-specification.md` (cập nhật theo C5, không xóa).
