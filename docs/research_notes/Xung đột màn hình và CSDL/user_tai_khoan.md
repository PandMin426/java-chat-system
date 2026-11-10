# Xung đột giữa các màn hình tài khoản của USER app (S01/S02/S03/S09, đăng xuất, online) và script CSDL V1

> Phạm vi: so sánh (a) FXML/controller/CSS/Navigator/mock data/ảnh chụp `docs/screens/user/S01, S02, S03, S09` và tài liệu mô tả chúng với (b) `script/schema.sql`, `script/seed.sql`, `script/tests/verify.sql`. Đường dẫn trích dẫn là tương đối so với thư mục gốc repo `D:\Julia06\TaiLieu\Uni\Nam03\Java\Project\code`; "L" là số dòng.
>
> Ký hiệu phân loại: **FE** = sửa ở UI JavaFX · **BE** = sửa ở schema/script DB hoặc logic server tương lai · **FE+BE** = cả hai. Nhóm: **Lưu trữ** (hình dạng dữ liệu) · **Nghiệp vụ** (quy tắc) · **Luồng** (trình tự xử lý).
> Phân biệt: **[DB thiếu]** = script DB hiện không lưu/không ràng buộc được · **[Server chưa viết]** = DB đủ, nhưng logic server/auth chưa tồn tại.

## Bối cảnh: backend có tồn tại chưa, và mức độ "thật" của các màn hình?

### Takeaway
Chưa có server/backend: Maven chỉ có 3 module `common`, `user`, `admin`; không có module `server`, không có JDBC/BCrypt. Mọi màn hình tài khoản ở V1 chỉ chuyển màn hình, không kiểm tra hay lưu gì. Vì vậy mọi quy tắc nghiệp vụ hiện chỉ có ở hai nơi: lời gợi ý trên UI và ràng buộc trong `schema.sql`. Phần lớn xung đột dưới đây là hai nơi này nói khác nhau.

### Cited Findings
- Maven root chỉ khai báo `src/common`, `src/user`, `src/admin` — [pom.xml L14–L16](../../pom.xml). Thư mục `src/` chỉ có `admin`, `common`, `user` (đã liệt kê bằng `ls src`).
- README nói kiến trúc chốt là 3 jar, trong đó `server.jar` (socket server + truy cập CSDL) là "vị trí chốt trong plan của feature socket-server", và client không kết nối thẳng CSDL — [README.md L31, L42](../../README.md).
- Bảng tiến độ: `socket-server`, `socket-client`, `auth`, `email-reset-pw` đều ⬜ (chưa bắt đầu) — [docs/ai/work-log.md L274–L283](../../docs/ai/work-log.md). Lúc làm core DB, nhóm ghi rõ "backend authentication and event capture were not tested" — [work-log.md L118](../../docs/ai/work-log.md).
- `LoginController.onLogin()` chỉ gọi `Navigator.showMain("ChatView")`, không xác thực — [src/user/src/main/java/com/chatapp/user/controller/LoginController.java L8, L16–L19](../../src/user/src/main/java/com/chatapp/user/controller/LoginController.java).
- `RegisterController.onRegister()` chỉ quay về `LoginView`, có chú thích "validation and saving come with the auth feature" — [RegisterController.java L11, L36–L39](../../src/user/src/main/java/com/chatapp/user/controller/RegisterController.java).
- `ForgotPasswordController` chỉ có `onBack()` — [ForgotPasswordController.java L7, L15–L18](../../src/user/src/main/java/com/chatapp/user/controller/ForgotPasswordController.java). `ProfileController` chỉ gán ngày sinh mẫu — [ProfileController.java L9, L15–L19](../../src/user/src/main/java/com/chatapp/user/controller/ProfileController.java).
- Tài liệu feature xác nhận phạm vi V1 "No server, socket, database or validation code". Các trạng thái lỗi đăng nhập (sai mật khẩu/bị khóa), lỗi đăng ký và trạng thái "đã gửi" của quên mật khẩu chưa được nối — [docs/ai/ui-user-screens/ui-user-screens.md L15, L67, L106](../../docs/ai/ui-user-screens/ui-user-screens.md).
- Thiết kế DB ghi rằng các kiểm tra về phiên và quyền theo người gọi thuộc tích hợp V2 — [docs/database/design-baseline.md L251](../../docs/database/design-baseline.md).

### Inferences
- Mỗi xung đột cần ghi rõ là "DB thiếu hỗ trợ" hay "server chưa viết". Nếu không, nhóm dễ sửa nhầm chỗ: thêm cột cho một quy tắc lẽ ra thuộc server, hoặc chờ server cho một quy tắc lẽ ra phải là CHECK trong DB.

### Gaps
- Không có tài liệu thiết kế giao thức socket (tên lệnh LOGIN/REGISTER/RESET, mã lỗi trả về). Vì thế chưa đối chiếu được cách lỗi DB (SQLSTATE 23505/23514) sẽ hiện trên UI.

## Tổng hợp: danh sách đầy đủ các xung đột và cách phân loại

### Takeaway
Tìm thấy 31 xung đột hoặc lệch pha (XD-01 → XD-31). Nặng nhất có năm nhóm:
- Quy tắc tên đăng nhập: UI và tài liệu ghi chữ thường `[a-z0-9._]` 4–30 ký tự, còn DB phân biệt hoa/thường, không có CHECK, và seed/verify cố ý dùng `Minh` và `minh`.
- Giới tính: không có tập giá trị chuẩn. User app có 4 nhãn, admin app có 3 nhãn, DB là text tự do.
- Đăng nhập: tài liệu đòi `login_history` có IP, DB chỉ có `login_events` không IP.
- Trạng thái "Hoạt động X giờ trước" không có nguồn dữ liệu.
- Seed chứa hash giả và người dùng khác hẳn mock của UI, nên không thể demo đăng nhập bằng dữ liệu seed.

### Cited Findings
Bảng tổng hợp (chi tiết và trích dẫn đầy đủ có ở các mục sau):

| ID | Xung đột (ngắn) | Phía UI / tài liệu | Phía DB | Loại | Nhóm | Hướng sửa |
|---|---|---|---|---|---|---|
| XD-01 | Định dạng và độ dài username không được DB ràng buộc | RegisterView.fxml L38; use-case-specification.md L212 (BR-01) | schema.sql L8, L23–L29 (chỉ NOT NULL + không rỗng) | FE+BE | Nghiệp vụ | CHECK `username ~ '^[a-z0-9._]{4,30}$'` + validator FE + kiểm tra ở server |
| XD-02 | Username phân biệt hoa/thường (DB), còn BR-01 chỉ cho chữ thường | RegisterView L38; BR-01 | schema L8 `COLLATE "C"`, L38–L39; design-baseline L73, L225; verify.sql L17–L20, L64–L65 | FE+BE | Nghiệp vụ | Chốt một quy tắc. Khuyến nghị chỉ chữ thường; sửa seed/verify; ô login chuẩn hóa hoặc từ chối chữ hoa |
| XD-03 | Seed dùng username vi phạm BR-01 (`Minh`, `Trang`, `Binh`) | BR-01 | seed.sql L29, L35, L38 | BE | Lưu trữ | Đổi fixture sang chữ thường; cập nhật verify.sql L17–L20 |
| XD-04 | Chỉ email được trim; username/họ tên có khoảng trắng đầu/cuối vẫn lưu được | Register/Profile TextField không trim | schema L79–L80 (chỉ trim email), L26, L29 (chỉ chặn chuỗi rỗng) | FE+BE | Lưu trữ | FE trim; trigger trim họ tên; CHECK định dạng username (XD-01) tự chặn khoảng trắng |
| XD-05 | Không kiểm tra định dạng email | BR-02 (UC L213); hint RegisterView L47 | schema L9, L27 (không CHECK định dạng) | FE+BE | Nghiệp vụ | Regex ở FE + server; tùy chọn CHECK đơn giản |
| XD-06 | Lỗi trùng username/email phải báo dưới đúng trường, nhưng UI không có nhãn lỗi | UC-01 4a (UC L246), UC-05 (L286); plan.md L38 hứa "error Labels"; RegisterView L35–L79 không có; theme.css L47, L112 có style mà không dùng | schema L38–L42 (unique index trả 23505) | FE+BE | Luồng | Thêm Label `.error-text` cho từng trường; server ánh xạ tên index → mã lỗi theo trường |
| XD-07 | Không có tập giá trị giới tính chuẩn: user 4 nhãn, admin 3 nhãn, DB tự do | RegisterView L67–L70, ProfileView L66–L69; admin UserFormDialog.fxml L49–L51 | schema L14 (text, không CHECK) | FE+BE | Lưu trữ | Chốt mã (VD `MALE/FEMALE/OTHER`, NULL = không nêu) + CHECK; FE ánh xạ nhãn ↔ mã; đồng bộ admin |
| XD-08 | ComboBox giới tính chọn sẵn "Nam" dù trường là tùy chọn | RegisterView L73, ProfileView L72; M23 (UC L51) | schema L14 nullable | FE | Nghiệp vụ | Bỏ giá trị mặc định, dùng promptText "Chọn…" |
| XD-09 | Ngày sinh: không giới hạn khoảng; gõ sai thì UI âm thầm giữ giá trị cũ | DateFields.java L33–L35; RegisterView L60 (promptText trông như đã có giá trị trong S02) | schema L13 `date`, không CHECK | FE+BE | Nghiệp vụ | FE báo lỗi khi parse sai và giới hạn khoảng; server/trigger chặn ngày tương lai hoặc < 1900 |
| XD-10 | Chính sách mật khẩu chỉ ghi trong hint, chưa nơi nào kiểm tra | RegisterView L52, ProfileView L96; BR-03 (UC L214) | schema L10 chỉ lưu hash (DB không kiểm được) | FE+BE | Nghiệp vụ | [Server chưa viết] Validator ở FE + server; thêm độ dài tối đa (giới hạn 72 byte của BCrypt) |
| XD-11 | Hash giả trong seed + thông tin đăng nhập mẫu của UI không có trong seed | LoginView L24, L32 (`an.nguyen`/`matkhau123`); N6/BR-03 BCrypt | seed L2, L29–L45 `'fixture-only'`; schema L10 không CHECK định dạng hash | FE+BE | Lưu trữ | Seed hash BCrypt thật cho một mật khẩu demo đã biết; tùy chọn CHECK `password_hash LIKE '$2%'`; V2 bỏ chữ điền sẵn |
| XD-12 | Reset mật khẩu: không có cờ "bắt buộc đổi", không có nhật ký/giới hạn tần suất reset | UC-04 (UC L270–L281), M21 (L49 "khuyến nghị đổi") | Chỉ có `users.password_hash` (schema L10); design-baseline L223 "không cần bảng riêng" | BE | Nghiệp vụ | [DB thiếu, tùy chọn] Thêm `must_change_password`/`password_changed_at` hoặc bảng `password_reset_events`; giới hạn tần suất ở server |
| XD-13 | Nút "Gửi mật khẩu mới" không có handler; thiếu trạng thái "đã gửi" và trạng thái lỗi | ForgotPasswordView.fxml L29; UC-04 L277–L280; ui-user-screens.md L106 | (DB đủ: cập nhật `password_hash`) | FE | Luồng | [Server chưa viết] Nối onAction, thêm thông báo che email, thông báo chung khi không khớp |
| XD-14 | Tab đổi mật khẩu: PasswordField không có fx:id, nút không có handler | ProfileView.fxml L91, L95, L100, L103; UC-06 (L288–L291) | (DB đủ) | FE | Luồng | Thêm fx:id + handler; [Server chưa viết] so sánh BCrypt với mật khẩu hiện tại |
| XD-15 | Tab thông tin hồ sơ: chỉ ngày sinh có fx:id; "Lưu"/"Hoàn tác" không có handler | ProfileView.fxml L50–L83; ProfileController L12–L13 | (DB đủ cột) | FE | Luồng | Thêm fx:id cho họ tên/email/giới tính/địa chỉ; nối Lưu/Hoàn tác |
| XD-16 | Tài liệu gọi là `login_history` có IP; DB có `login_events` không IP | BR-05 (UC L216), UC-02 L256, UC-37 L460, UC-39 L466; requirements-analysis.md L46 | schema L89–L94 (chỉ `user_id`, `logged_in_at`) | FE+BE | Lưu trữ | [DB thiếu] Thêm `ip_address inet` (server lấy từ socket), hoặc bỏ IP khỏi tài liệu/UI; đổi tên trong tài liệu |
| XD-17 | BR-05 coi "login = mở app"; DB tách `login_events`/`app_open_events`; "reused sessions" là luồng chưa ai thiết kế | BR-05, M9 (UC L37); UI không có "ghi nhớ đăng nhập" | schema L89, L102–L107; design-baseline L65–L66; verify.sql L172–L173 | FE+BE | Luồng | Chốt: mỗi lần login thành công ghi cả 2 bảng trong 1 giao dịch; nếu muốn dùng lại phiên thì cần bảng phiên/token (DB thiếu) + checkbox UI |
| XD-18 | Tài khoản bị khóa: DB có LOCKED, UI không có trạng thái lỗi; DB không chặn ghi sự kiện đăng nhập cho tài khoản bị khóa | LoginView.fxml (không có nhãn lỗi); UC-02 2b (L262); M22 (L50); BR-04 (L215) | schema L16, L20; seed L45 `locked_user`; design-baseline L74 | FE+BE | Nghiệp vụ / Luồng | FE: nhãn lỗi + hộp thoại "Tài khoản đã bị khóa" khi bị ngắt; [Server chưa viết] kiểm tra `account_status`; tùy chọn trigger từ chối `login_events`/`app_open_events` khi khác ACTIVE |
| XD-19 | UI hiện "Hoạt động 2 giờ trước / hôm qua / 05/11" nhưng không có nguồn dữ liệu | user SampleData.java L119–L121 | Không có `last_seen_at`; không có sự kiện logout (schema L6–L107); design-baseline L223 (online lấy từ lớp kết nối) | FE+BE | Lưu trữ | [DB thiếu] Thêm `users.last_seen_at` (ghi khi đăng xuất/mất kết nối), hoặc đổi chữ thành "Mở app lần cuối …" dựa trên `max(app_open_events.opened_at)`, hoặc bỏ |
| XD-20 | Đăng xuất chỉ chuyển màn hình | MainController.java L54–L57; MainView.fxml L46–L49; UC-03 (L266–L268) | Không cần cột (online nằm trong bộ nhớ server) trừ khi áp dụng XD-19 | FE+BE | Luồng | [Server chưa viết] Đóng socket → server đánh dấu offline (+ ghi `last_seen_at` nếu có) |
| XD-21 | Đăng nhập giao tin offline và nhãn "Đã gửi/Đã nhận", nhưng DB không có trạng thái giao | UC-02 L258; UC-15 L348; user SampleData L78, L80 ("Đã nhận") | schema L163–L169 (`private_messages` không có `delivered_at`) | FE+BE | Lưu trữ | [DB thiếu] Thêm `delivered_at` hoặc bỏ nhãn; liên quan nhóm nghiên cứu chat |
| XD-22 | `registration_source` NOT NULL nhưng không có DEFAULT; server đăng ký phải tự gán | UC-01 bước 4 (L243) | schema L17, L21–L22 | BE | Luồng | Server luôn gửi `'SELF_REGISTERED'`, không nhận role/status từ client; hoặc thêm DEFAULT |
| XD-23 | Đăng ký xong không điền sẵn username ở màn hình Login | UC-01 bước 5 (L244); RegisterController L37–L39; LoginView L24 (chữ cứng) | — | FE | Luồng | Navigator truyền username sang LoginController |
| XD-24 | Mock của UI và seed là hai bộ người dùng khác nhau | ProfileView L30–L31, RegisterView L37–L78, admin SampleData L55, user SampleData L114–L135 | seed L28–L45, L126–L127 | FE+BE | Lưu trữ | Gộp về một bộ demo chung; lưu ý verify.sql đếm cứng số lượng (L47–L53, L171–L173) |
| XD-25 | Seed/verify không chạm tới cột hồ sơ tùy chọn (địa chỉ, ngày sinh, giới tính) | S02/S09 thu thập và sửa ba trường này | seed L28–L45 (không chèn); verify (không kiểm) | BE | Lưu trữ | Thêm fixture có giá trị + kiểm tra CHECK giới tính/ngày sinh |
| XD-26 | Giá trị điền sẵn trong form (mock) có thể bị gửi thật khi nối server | LoginView L24, L32; RegisterView L37, L42, L46, L51, L56, L78; ForgotPasswordView L22, L26 | — | FE | Lưu trữ | V2 xóa `text=` mẫu, chuyển thành promptText |
| XD-27 | Múi giờ hiển thị ngày (VD "tham gia 12/09/2026"): tài liệu mâu thuẫn | ProfileView L31; BR-15 (UC L226) "múi giờ máy client" | schema L2–L3; design-baseline L225 (`Asia/Ho_Chi_Minh`) | FE+BE | Nghiệp vụ | Chốt một múi giờ hiển thị (khuyến nghị Asia/Ho_Chi_Minh như DB) |
| XD-28 | "Duy nhất" theo BR-01/BR-02 so với DB cho dùng lại username/email sau khi xóa mềm | BR-01/BR-02; hint "Không đổi được về sau" | schema L38–L42 (unique có điều kiện); design-baseline L74; verify L76–L83 | BE (tài liệu) | Nghiệp vụ | Ghi rõ trong BR là "duy nhất trong các tài khoản chưa xóa" |
| XD-29 | Mô hình mã hóa (E2EE theo thiết bị trong DB) lệch với khẳng định "reset/đổi mật khẩu không ảnh hưởng nhóm mã hóa" | UC-04 HĐK L281; UC-28 L423–L430; work-log L172 (K4: server giữ khóa) | schema L459–L471 (`e2ee_devices`, mỗi tài khoản 1 thiết bị đang hoạt động); design-baseline L196–L198, L205 | FE+BE | Nghiệp vụ | Chốt mô hình. Nếu giữ E2EE thì S01/S03/S09 phải cảnh báo đăng nhập máy mới/reset sẽ mất lịch sử nhóm |
| XD-30 | `login_events` không phân biệt đăng nhập từ user.jar hay admin.jar; chưa nói ADMIN có được vào user.jar không | UC-30 L437 (login admin không tính "mở app") | schema L89–L94 (không có cột nguồn/app); seed L44 `demo_admin` | BE | Lưu trữ | [DB thiếu] Thêm cột `client_app` hoặc quy ước admin không ghi `login_events`; chốt quyền ADMIN ở user.jar |
| XD-31 | Không giới hạn độ dài họ tên/địa chỉ/email ở cả UI lẫn DB | TextField không có giới hạn (RegisterView L42, L46, L78; ProfileView L51, L55, L77) | schema L9, L11, L12 (`text`) | FE+BE | Lưu trữ | Chốt giới hạn (VD họ tên ≤ 100, email ≤ 254, địa chỉ ≤ 255): CHECK `char_length` + TextFormatter |

Những điểm KHỚP (để người viết báo cáo không đưa nhầm vào danh sách xung đột):
- Trường bắt buộc khớp nhau. S02 đánh dấu `*` cho username, họ tên, email, mật khẩu ([RegisterView.fxml L36, L41, L45, L50](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml)). DB bắt buộc đúng 4 trường này với tài khoản chưa xóa ([schema.sql L23–L29](../../script/schema.sql)). M23 cũng nêu địa chỉ/ngày sinh/giới tính là tùy chọn ([use-case-specification.md L51](../../docs/ai/requirements-analysis/use-case-specification.md)).
- Username không đổi được. Ô username bị khóa ở S09 ("Không đổi được.", [ProfileView.fxml L45–L47](../../src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml)), và trigger chặn đổi username ([schema.sql L73–L76](../../script/schema.sql)).
- Email duy nhất không phân biệt hoa/thường ([schema.sql L41–L42](../../script/schema.sql), [verify.sql L67](../../script/tests/verify.sql)), khớp BR-02.
- Đủ 6 trường hồ sơ mà PDF yêu cầu (tên đăng nhập, họ tên, địa chỉ, ngày sinh, giới tính, email — [docs/Final_Project_He_Thong_Chat_Chi_Tiet.md L63–L68](../../docs/Final_Project_He_Thong_Chat_Chi_Tiet.md)) đều có cột trong `users` ([schema.sql L8–L14](../../script/schema.sql)). Ngày sinh là `date`, map trực tiếp sang `LocalDate` của DatePicker. Định dạng dd/MM/yyyy chỉ dùng để hiển thị ([DateFields.java L13](../../src/common/src/main/java/com/chatapp/common/DateFields.java)), nên không có xung đột kiểu.
- Avatar: UI chỉ hiện chữ cái đầu ("AN", [ProfileView.fxml L28](../../src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml), [MainView.fxml L43](../../src/user/src/main/resources/com/chatapp/user/view/MainView.fxml)), không upload ảnh. DB không có cột avatar và PDF không yêu cầu nên không xung đột.
- Giá trị mặc định khi đăng ký: `system_role='USER'`, `account_status='ACTIVE'`, `created_at=CURRENT_TIMESTAMP` ([schema.sql L15, L16, L18](../../script/schema.sql)) khớp UC-01 bước 4 "tạo tài khoản trạng thái Hoạt động, ghi thời điểm tạo" ([UC L243](../../docs/ai/requirements-analysis/use-case-specification.md)). Tự đăng ký không thể tạo ADMIN ([schema.sql L22](../../script/schema.sql)).
- Quên mật khẩu theo đề là sinh mật khẩu ngẫu nhiên và gửi email ([Final_Project…md L198–L204](../../docs/Final_Project_He_Thong_Chat_Chi_Tiet.md)), không dùng link/token. Vì vậy việc không có bảng token/hạn dùng là đúng thiết kế ([design-baseline.md L223](../../docs/database/design-baseline.md)), không phải thiếu sót.
- Tài khoản đã xóa không đăng nhập được: username bị đặt NULL khi xóa mềm ([schema.sql L31–L33](../../script/schema.sql)), nên tra cứu tự thất bại và hiện thông báo chung, khớp BR-04.

### Inferences
- Ưu tiên sửa: XD-02/03 (quyết định hoa/thường ảnh hưởng tới seed, verify và cách đăng nhập), XD-07 (giới tính, dính cả admin app), XD-11/24 (không demo đăng nhập được với seed), XD-16/17 (định nghĩa sự kiện đăng nhập dùng cho thống kê admin).

### Gaps
- Không đọc được prototype HTML (`../design-ui/...`, nằm ngoài repo) để so tweak "wrong password / locked" với FXML.

## Mỗi trường trên S01/S02/S03/S09 có cột tương ứng không, và có cùng kiểu, độ dài, nullability, tính duy nhất, định dạng không?

### Takeaway
Mọi trường đều có cột (trừ `confirmPassword`, đúng là không cần lưu), nhưng DB gần như không ràng buộc định dạng. Có CHECK cho vai trò/trạng thái/nguồn tạo và cho các trường bắt buộc, nhưng không có CHECK nào cho định dạng username, email, giá trị giới tính, khoảng ngày sinh hay độ dài chuỗi. Riêng quy tắc hoa/thường của username thì UI và DB nói ngược nhau.

### Cited Findings
**Bảng đối chiếu trường ↔ cột**

| Trường UI | Nơi xuất hiện | Cột DB | Khớp? |
|---|---|---|---|
| Tên đăng nhập | S01 [LoginView L23–L24]; S02 [RegisterView L36–L38] hint "4–30 ký tự: a-z, 0-9, dấu . và _. Không đổi được về sau."; S03 [ForgotPasswordView L21–L22]; S09 [ProfileView L45–L47] disabled | `username text COLLATE "C"` [schema L8]; unique khi chưa xóa [L38–L39]; không đổi được [L73–L76] | Thiếu CHECK định dạng/độ dài (XD-01); hoa/thường lệch (XD-02) |
| Họ tên | S02 [RegisterView L41–L42] `*`; S09 [ProfileView L50–L51] | `full_name text`, bắt buộc và không rỗng khi chưa xóa [schema L11, L29] | Khớp bắt buộc; không giới hạn độ dài (XD-31); không trim (XD-04) |
| Email | S02 [RegisterView L45–L47] `*`; S03 [ForgotPasswordView L25–L27]; S09 [ProfileView L54–L55] | `email text` [L9]; unique `lower(email)` [L41–L42]; trigger trim [L79–L80] | Khớp tính duy nhất; thiếu kiểm tra định dạng (XD-05) |
| Mật khẩu / Nhập lại | S01 [LoginView L32]; S02 [RegisterView L50–L56]; S09 [ProfileView L89–L101] | `password_hash text` [L10], bắt buộc [L28] | Đúng hướng (chỉ lưu hash); chính sách mật khẩu không ai kiểm (XD-10); seed dùng hash giả (XD-11) |
| Ngày sinh | S02 [RegisterView L59–L60]; S09 [ProfileView L58–L59] | `birth_date date` nullable [L13] | Khớp kiểu; không giới hạn khoảng (XD-09) |
| Giới tính | S02 [RegisterView L63–L74]; S09 [ProfileView L62–L73] | `gender text` nullable, không CHECK [L14] | Không có tập giá trị chuẩn (XD-07, XD-08) |
| Địa chỉ | S02 [RegisterView L77–L78]; S09 [ProfileView L76–L77] | `address text` nullable [L12] | Khớp; không giới hạn độ dài (XD-31) |
| "tham gia 12/09/2026" | S09 [ProfileView L31] | `created_at timestamptz` [L18], không sửa được [L62–L66] | Khớp; múi giờ hiển thị chưa thống nhất (XD-27) |
| Avatar chữ cái | S09 [ProfileView L28]; rail [MainView L43] | (không có cột; suy ra từ `full_name`) | Khớp (không yêu cầu ảnh) |

(Đường dẫn: `src/user/src/main/resources/com/chatapp/user/view/*.fxml`, `script/schema.sql`.)

**Chi tiết các xung đột**
- **XD-01 (FE+BE, Nghiệp vụ).** UI và BR-01 quy định "Tên đăng nhập 4–30 ký tự `[a-z0-9_.]`, duy nhất, không đổi được" — [use-case-specification.md L212](../../docs/ai/requirements-analysis/use-case-specification.md); hint trong [RegisterView.fxml L38](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml). DB chỉ yêu cầu `username IS NOT NULL AND btrim(username) <> ''` — [schema.sql L26](../../script/schema.sql). Không có CHECK độ dài hay ký tự, nên server sau này có thể chèn `"A B!"` hoặc chuỗi 500 ký tự. **Hướng sửa:** thêm `CONSTRAINT users_username_format_check CHECK (username IS NULL OR username ~ '^[a-z0-9._]{4,30}$')`, có validator ở FE (TextFormatter) và validator ở server.
- **XD-02 (FE+BE, Nghiệp vụ).** DB cố ý phân biệt hoa/thường: cột dùng `COLLATE "C"` ([schema.sql L8](../../script/schema.sql)); thiết kế ghi "so sánh `username` có phân biệt hoa/thường" và "Tìm theo tên đăng nhập giữ phân biệt hoa/thường" ([design-baseline.md L73, L225](../../docs/database/design-baseline.md)). verify.sql chọn riêng hai tài khoản `'Minh'` và `'minh'` và báo lỗi nếu chúng không cùng tồn tại ("Username case sensitivity ... failed") — [verify.sql L17, L20, L64–L65](../../script/tests/verify.sql). BR-01 và hint UI chỉ cho `a-z`, tức chỉ chữ thường. Nếu giữ thiết kế DB, người dùng gõ `An.Nguyen` ở S01 có thể (a) không tìm thấy tài khoản hoặc (b) vào nhầm tài khoản khác chỉ khác chữ hoa. **Hướng sửa:** khuyến nghị theo BR-01 (chỉ chữ thường + CHECK ở XD-01), khi đó COLLATE "C" vô hại. Đổi fixture và bài kiểm tra case-sensitivity trong verify.sql. Ô username ở S01/S03 tự chuyển về chữ thường hoặc báo lỗi.
- **XD-03 (BE, Lưu trữ).** Seed chèn `'Minh'`, `'Trang'`, `'Binh'` (chữ hoa đầu) — [seed.sql L29, L35, L38](../../script/seed.sql). Các tên này vi phạm BR-01 và không thể tạo qua S02 nếu UI kiểm theo hint.
- **XD-04 (FE+BE, Lưu trữ).** Trigger chỉ trim email ("Strip surrounding whitespace before profile checks and the unique index") — [schema.sql L79–L80](../../script/schema.sql). Username và họ tên chỉ bị kiểm `btrim(...) <> ''` ([L26, L29](../../script/schema.sql)), nên `' an.nguyen'` và `'an.nguyen'` thành hai tài khoản khác nhau. Controller hiện không trim gì.
- **XD-05 (FE+BE, Nghiệp vụ).** BR-02 yêu cầu "Email đúng định dạng, duy nhất" — [UC L213](../../docs/ai/requirements-analysis/use-case-specification.md). DB chỉ đảm bảo không rỗng và duy nhất — [schema.sql L27, L41–L42](../../script/schema.sql). S02/S03 dùng email để nhận mật khẩu mới ([RegisterView L47](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml)), nên email sai định dạng sẽ khiến tài khoản không thể khôi phục.
- **XD-06 (FE+BE, Luồng).** UC-01 4a: "Tên đăng nhập hoặc email đã tồn tại → báo lỗi ngay dưới trường tương ứng" — [UC L246](../../docs/ai/requirements-analysis/use-case-specification.md). UC-05 có ngoại lệ "Email trùng → báo lỗi tại trường email" — [UC L286](../../docs/ai/requirements-analysis/use-case-specification.md). Plan của S02 ghi "error Labels" — [docs/ai/ui-user-screens/plan.md L38](../../docs/ai/ui-user-screens/plan.md). Thực tế RegisterView chỉ có Label `hint`, không có Label lỗi — [RegisterView.fxml L35–L79](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml). Style `.error-text` và `.text-field.error` đã có sẵn — [theme.css L47, L112](../../src/common/src/main/resources/com/chatapp/common/theme.css). Phía DB, trùng lặp sinh lỗi 23505 trên `users_live_username_uidx` hoặc `users_live_email_uidx` ([schema.sql L38–L42](../../script/schema.sql)); server cần ánh xạ tên index sang trường.
- **XD-09 (FE+BE, Nghiệp vụ).** `birth_date date` không có CHECK — [schema.sql L13](../../script/schema.sql). DatePicker không có giới hạn khoảng ngày, và khi người dùng gõ sai định dạng thì converter "keeps the previous value" một cách im lặng — [DateFields.java L18, L33–L35](../../src/common/src/main/java/com/chatapp/common/DateFields.java). Ngoài ra, ở S02, `12/05/2004` chỉ là `promptText` ([RegisterView.fxml L60](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml)) nhưng ảnh S02-dang-ky.png trông như đã có giá trị.
- **XD-31 (FE+BE, Lưu trữ).** Các cột chuỗi đều là `text`, không giới hạn — [schema.sql L9, L11, L12](../../script/schema.sql). TextField cũng không giới hạn.

### Inferences
- Nếu không thêm CHECK, mọi quy tắc BR-01/BR-02 sẽ chỉ nằm ở server tương lai. Admin app ghi qua cùng server, nên vẫn ổn, nhưng không còn lớp bảo vệ cuối ở DB như các bảng chat (vốn dùng trigger rất chặt).
- Đổi XD-02 sang chữ thường kéo theo sửa `seed.sql` L29–L38 và `verify.sql` L17–L20, L64–L67 (bài kiểm tra trùng email cũng dùng biến `d` = `'minh'`).

### Gaps
- Chưa có quyết định nào về độ dài tối đa của họ tên, địa chỉ hay email trong mọi tài liệu đã đọc.

## Mật khẩu được lưu thế nào, và DB có đủ cho luồng quên mật khẩu (S03) và đổi mật khẩu (S09) không?

### Takeaway
DB lưu đúng một cột `password_hash` (không có cột salt riêng; BCrypt nhúng salt trong hash nên không cần). Cột này đủ cho cả S03 (sinh mật khẩu ngẫu nhiên → lưu hash → gửi email) và S09 (so hash cũ → lưu hash mới); không cần bảng token, vì đề yêu cầu gửi mật khẩu chứ không gửi link. Vấn đề nằm ở chỗ khác: seed không có hash thật, không có cờ "nên đổi mật khẩu", không có nhật ký reset, và UI chưa nối bất kỳ nút nào.

### Cited Findings
- `password_hash text`, bắt buộc và không rỗng với tài khoản chưa xóa — [schema.sql L10, L28](../../script/schema.sql). Không có cột salt, thuật toán, `password_changed_at`, `must_change_password` hay bảng reset/token (cả schema chỉ có 16 bảng, verify.sql khẳng định đúng danh sách này — [verify.sql L47–L53](../../script/tests/verify.sql)).
- Thiết kế: "USR-03 … Reset qua email dùng email và hash mật khẩu ở `users` … không yêu cầu thêm bảng riêng" — [design-baseline.md L223](../../docs/database/design-baseline.md).
- Yêu cầu gốc: "Mật khẩu mới được tạo ngẫu nhiên (random)… gửi đến email… Không thay yêu cầu này bằng quy trình khác" — [Final_Project_He_Thong_Chat_Chi_Tiet.md L198–L204](../../docs/Final_Project_He_Thong_Chat_Chi_Tiet.md). Đổi mật khẩu (USR-04) — [L206–L208](../../docs/Final_Project_He_Thong_Chat_Chi_Tiet.md).
- UC-04: kiểm tra cặp tên đăng nhập–email khớp (M21), "sinh mật khẩu ngẫu nhiên 10 ký tự, lưu bản băm, gửi email", hiện "Đã gửi mật khẩu mới tới email ***@gmail.com"; không khớp → thông báo chung; gửi email thất bại → không đổi mật khẩu — [use-case-specification.md L270–L281](../../docs/ai/requirements-analysis/use-case-specification.md). M21 thêm "khuyến nghị đổi sau khi đăng nhập" — [L49](../../docs/ai/requirements-analysis/use-case-specification.md).
- N6/BR-03: lưu BCrypt, mật khẩu ≥ 8 ký tự có chữ và số — [UC L62, L214](../../docs/ai/requirements-analysis/use-case-specification.md). Hint UI khớp chữ: "Ít nhất 8 ký tự, có chữ và số." — [RegisterView.fxml L52](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml), [ProfileView.fxml L96](../../src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml).
- S03: mô tả "Hệ thống tạo mật khẩu ngẫu nhiên mới và gửi tới email đã đăng ký của bạn."; hai trường username + email; hint "Phải khớp với email của tài khoản."; nút "Gửi mật khẩu mới" **không có `onAction`** — [ForgotPasswordView.fxml L16–L29](../../src/user/src/main/resources/com/chatapp/user/view/ForgotPasswordView.fxml); ảnh S03-quen-mat-khau.png khớp FXML.
- S09 tab "Đổi mật khẩu": ba `PasswordField` không có `fx:id`, nút "Đổi mật khẩu" không có handler — [ProfileView.fxml L86–L105](../../src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml).
- Seed: "Password … values are placeholders"; mọi tài khoản có `password_hash = 'fixture-only'` — [seed.sql L2, L29–L45, L127](../../script/seed.sql); [design-baseline.md L243](../../docs/database/design-baseline.md) xác nhận là dữ liệu giả.
- Mô hình mã hóa: DB lưu `e2ee_devices` (khóa công khai, một thiết bị đang hoạt động cho mỗi tài khoản) và gói khóa theo thiết bị — [schema.sql L459–L471, L487–L502](../../script/schema.sql). Thiết kế nói "Khóa riêng và khóa nhóm dạng rõ nằm phía thiết bị", và thiết bị mới chỉ nhận khóa cho tin phát sinh sau khi được cấp quyền — [design-baseline.md L198, L205](../../docs/database/design-baseline.md). Ngược lại, UC-04 khẳng định "Không ảnh hưởng nhóm mã hóa (khóa nhóm do server giữ, UC-28)" — [UC L281, L423–L430](../../docs/ai/requirements-analysis/use-case-specification.md). Quyết định K4 "server giữ khóa" ghi lúc 18:25 — [work-log.md L172](../../docs/ai/work-log.md). Còn Prompt 03 của DB được duyệt với "group E2EE scope" — [work-log.md L98](../../docs/ai/work-log.md).

Xung đột tương ứng: **XD-10, XD-11, XD-12, XD-13, XD-14, XD-29** (xem bảng tổng hợp).

### Inferences
- **XD-11:** Hash giả khiến ngay khi server có BCrypt, không tài khoản seed nào đăng nhập được, kể cả `locked_user` dùng để thử UC-02 2b. Thông tin mẫu trên S01 (`an.nguyen` / `matkhau123`, [LoginView.fxml L24, L32](../../src/user/src/main/resources/com/chatapp/user/view/LoginView.fxml)) cũng không tồn tại trong seed. Cần seed hash BCrypt của một mật khẩu demo đã công bố.
- **XD-10:** BCrypt chỉ dùng 72 byte đầu của mật khẩu. Đây là kiến thức chung, không lấy từ repo. Tiếng Việt có dấu chiếm nhiều byte UTF-8, nên nên đặt giới hạn tối đa (VD 64 ký tự) ở cả FE và server.
- **XD-12:** Chỉ cần biết username + email là reset được mật khẩu của người khác nhiều lần liên tiếp, làm họ bị đẩy ra khỏi tài khoản. Không có bảng/cột nào để giới hạn tần suất hay ghi lại. Đây là [DB thiếu, tùy chọn] + [Server chưa viết]. Cờ `must_change_password` cũng là cách duy nhất để thực hiện "khuyến nghị đổi" của M21 ở lần đăng nhập sau.
- **XD-29:** Nếu nhóm giữ mô hình thiết bị của DB, thì sau khi reset/đổi mật khẩu hoặc đăng nhập máy mới (UC-02 2c), người dùng có thể mất quyền đọc lịch sử nhóm mã hóa. Khi đó S03/S09 đang hứa sai. Mục này giao với nhóm nghiên cứu "nhóm chat/mã hóa".
- UC-06 có ngoại lệ "mật khẩu mới trùng mật khẩu cũ"; ngoại lệ này kiểm được bằng cách gọi BCrypt verify mật khẩu mới với hash hiện tại, không cần bảng lịch sử mật khẩu.

### Gaps
- Chưa có quyết định cho tài khoản LOCKED gửi yêu cầu quên mật khẩu (cho reset hay không), cũng như việc admin (role ADMIN) reset qua S03.
- Không có tài liệu SMTP/cấu hình email để đối chiếu.

## Luồng đăng nhập: lịch sử đăng nhập, tài khoản bị khóa/vô hiệu, trạng thái online, phiên và đăng xuất

### Takeaway
DB có `login_events` (chỉ ghi lần đăng nhập thành công, không có IP) và `app_open_events` (mỗi lần mở app, "kể cả phiên dùng lại"). DB không có cột online/last-seen/phiên; theo thiết kế, phần này nằm trong bộ nhớ server. Tài liệu lại đòi `login_history (thời gian, IP)` và coi đăng nhập là mở app. UI thì có chữ "Hoạt động X giờ trước", là dữ liệu không ai lưu. Trạng thái LOCKED có trong DB nhưng UI chưa có màn hình hay thông báo cho nó.

### Cited Findings
- `login_events(login_event_id, user_id, logged_in_at)`, chú thích "Write only successful authentications" — [schema.sql L89–L94](../../script/schema.sql). `app_open_events(user_id, opened_at)`, chú thích "Write one event per app launch once its user is known, including reused sessions" — [schema.sql L102–L107](../../script/schema.sql); mục đích ghi ở [design-baseline.md L65–L66](../../docs/database/design-baseline.md).
- Tài liệu: BR-05 "Mỗi lần đăng nhập thành công ghi 1 dòng `login_history` (thời gian, IP) = 1 lần 'mở ứng dụng'" — [UC L216](../../docs/ai/requirements-analysis/use-case-specification.md). UC-02 bước 2 "ghi `login_history`" — [L256](../../docs/ai/requirements-analysis/use-case-specification.md). M5 "Chỉ ghi đăng nhập thành công (= 1 lần 'mở ứng dụng')" — [L33](../../docs/ai/requirements-analysis/use-case-specification.md). M9 đếm "số người khác nhau có ≥1 lần đăng nhập" — [L37](../../docs/ai/requirements-analysis/use-case-specification.md). Admin xem IP — [UC-37 L460, UC-39 L466](../../docs/ai/requirements-analysis/use-case-specification.md). requirements-analysis cũng gọi là "login_history" — [requirements-analysis.md L46](../../docs/ai/requirements-analysis/requirements-analysis.md).
- verify.sql dùng `app_open_events` (không dùng `login_events`) cho thống kê hoạt động theo tháng — [verify.sql L172–L173](../../script/tests/verify.sql).
- Tài khoản bị khóa: `account_status IN ('ACTIVE','LOCKED','DELETED')` — [schema.sql L16, L20](../../script/schema.sql). Fixture `locked_user` — [seed.sql L45](../../script/seed.sql). "Tài khoản bị khóa vẫn giữ username/email và bị chặn đăng nhập mới" — [design-baseline.md L74](../../docs/database/design-baseline.md). Schema không có trigger nào ngăn chèn `login_events`/`app_open_events` cho user LOCKED/DELETED, chỉ có FK — [schema.sql L92, L105](../../script/schema.sql).
- UI: UC-02 2a/2b có thông báo "Tên đăng nhập hoặc mật khẩu không đúng" và "Tài khoản đã bị khóa. Liên hệ quản trị viên"; 2c "phiên cũ bị đăng xuất" — [UC L261–L263](../../docs/ai/requirements-analysis/use-case-specification.md). M22/BR-04: đang online mà bị khóa thì server ngắt kết nối, client hiện thông báo — [UC L50, L215](../../docs/ai/requirements-analysis/use-case-specification.md). Hiện LoginView không có Label lỗi nào — [LoginView.fxml L16–L39](../../src/user/src/main/resources/com/chatapp/user/view/LoginView.fxml); tài liệu feature ghi "wrong-password / locked error states on login" chưa nối — [ui-user-screens.md L106](../../docs/ai/ui-user-screens/ui-user-screens.md).
- Online/last seen: thiết kế ghi "Online/offline và phản hồi realtime lấy từ lớp kết nối … không yêu cầu thêm bảng riêng" — [design-baseline.md L223](../../docs/database/design-baseline.md). UI hiện "Đang online" và "Hoạt động 2 giờ trước", "Hoạt động hôm qua", "Hoạt động 05/11" — [user SampleData.java L115–L121](../../src/user/src/main/java/com/chatapp/user/sample/SampleData.java); hiển thị qua [FriendsController.java L69](../../src/user/src/main/java/com/chatapp/user/controller/FriendsController.java); header chat "· Đang online" — [ChatView.fxml L62](../../src/user/src/main/resources/com/chatapp/user/view/ChatView.fxml).
- Đăng xuất: `MainController.onLogout()` chỉ `Navigator.showAuth("LoginView")` — [MainController.java L54–L57](../../src/user/src/main/java/com/chatapp/user/controller/MainController.java); nút ở [MainView.fxml L46–L49](../../src/user/src/main/resources/com/chatapp/user/view/MainView.fxml). UC-03: client đóng socket → server đánh dấu offline và báo bạn bè — [UC L266–L268](../../docs/ai/requirements-analysis/use-case-specification.md).
- Giao tin offline khi đăng nhập (UC-02 bước 4) và nhãn "Đã gửi/Đã nhận" — [UC L258, L348](../../docs/ai/requirements-analysis/use-case-specification.md); mock "09:14 · Đã nhận" — [user SampleData.java L78, L80](../../src/user/src/main/java/com/chatapp/user/sample/SampleData.java). `private_messages` không có cột trạng thái giao — [schema.sql L163–L169](../../script/schema.sql).
- PDF không quy định "cơ chế lưu phiên đăng nhập" — [Final_Project…md L574](../../docs/Final_Project_He_Thong_Chat_Chi_Tiet.md). UC-30: đăng nhập admin "Không ghi vào thống kê 'mở ứng dụng'" — [UC L437](../../docs/ai/requirements-analysis/use-case-specification.md). `login_events` không có cột phân biệt app — [schema.sql L90–L94](../../script/schema.sql). Seed có `demo_admin` role ADMIN — [seed.sql L44](../../script/seed.sql).

Xung đột tương ứng: **XD-16, XD-17, XD-18, XD-19, XD-20, XD-21, XD-30** (xem bảng tổng hợp).

### Inferences
- **XD-16:** IP đơn giản là [DB thiếu]. Server lấy được IP từ `Socket.getInetAddress()` nhưng không có chỗ lưu. Hoặc thêm cột `ip_address inet`, hoặc sửa BR-05/UC-37/UC-39 và UI admin để bỏ IP.
- **XD-17:** User app không có "ghi nhớ đăng nhập", nên mỗi lần mở app đều là một lần đăng nhập, và server nên chèn cả `login_events` lẫn `app_open_events` trong cùng giao dịch khi xác thực thành công. Chú thích "reused sessions" ở schema L102 ám chỉ một luồng chưa được UI hay tài liệu thiết kế. Nếu sau này làm "ghi nhớ đăng nhập" thì cần thêm bảng phiên/token, mà verify.sql đang khóa cứng 16 bảng (L47–L57).
- **XD-18:** Kiểm tra `account_status = 'ACTIVE'` lúc đăng nhập là [Server chưa viết]. DB có thể thêm lớp chặn cuối (trigger BEFORE INSERT trên `login_events`/`app_open_events` từ chối user khác ACTIVE), cho nhất quán với cách các bảng chat dùng trigger.
- **XD-19:** "Hoạt động 2 giờ trước" cần thời điểm offline hoặc hoạt động cuối, mà không bảng nào lưu. `max(app_open_events.opened_at)` chỉ là lần mở app gần nhất, không phải lần offline. Hoặc thêm `users.last_seen_at` (server ghi khi socket đóng, gắn với XD-20), hoặc đổi chữ trên UI.
- **XD-21:** Không có `delivered_at` thì không phân biệt được "Đã gửi" với "Đã nhận", và server cũng không biết tin nào cần giao khi người nhận đăng nhập (trừ khi giao lại toàn bộ lịch sử). Mục này giao với nhóm nghiên cứu chat 1-1.
- **XD-30:** Nếu admin.jar cũng ghi `login_events`, nhật ký ADM-02 và thống kê sẽ trộn đăng nhập quản trị với đăng nhập người dùng, vì không có cột phân biệt.
- Phiên đơn (UC-02 2c) và trạng thái online nằm trong bộ nhớ server theo thiết kế. Đây là [Server chưa viết], không phải DB thiếu.

### Gaps
- Chưa có quyết định tài khoản ADMIN có được đăng nhập user.jar không.
- Không có tài liệu nói lý do khóa (UC-35 "kèm lý do tùy chọn") có cần hiển thị cho người dùng ở S01 không. DB cũng không có cột lý do khóa.

## Đăng ký: DB tự gán giá trị mặc định nào, UI giả định gì, và có gì UI thu thập mà DB không lưu được (hoặc ngược lại)?

### Takeaway
Giá trị mặc định nhìn chung khớp. Có ba lệch: `registration_source` là NOT NULL không DEFAULT nên server bắt buộc phải tự gán; UI chọn sẵn giới tính "Nam" cho một trường tùy chọn; và luồng sau khi đăng ký thành công không mang username về S01. DB không yêu cầu trường nào mà UI không thu thập.

### Cited Findings
- DEFAULT: `system_role 'USER'`, `account_status 'ACTIVE'`, `created_at CURRENT_TIMESTAMP`; `registration_source text NOT NULL` **không DEFAULT**, chỉ nhận `'SELF_REGISTERED'|'INTERNAL'`; ADMIN phải là INTERNAL — [schema.sql L15–L22](../../script/schema.sql). `created_at` và `registration_source` không sửa được — [L62–L66](../../script/schema.sql). Seed luôn truyền `registration_source` tường minh — [seed.sql L28–L45](../../script/seed.sql).
- UC-01 bước 4–5: tạo tài khoản "Hoạt động", ghi thời điểm tạo, rồi "quay về màn hình Đăng nhập, điền sẵn tên đăng nhập" — [UC L243–L244](../../docs/ai/requirements-analysis/use-case-specification.md). Controller chỉ gọi `Navigator.showAuth("LoginView")`, không truyền dữ liệu — [RegisterController.java L37–L39](../../src/user/src/main/java/com/chatapp/user/controller/RegisterController.java); `Navigator.showAuth` chỉ nạp FXML — [Navigator.java L69–L71](../../src/user/src/main/java/com/chatapp/user/Navigator.java). LoginView có `text="an.nguyen"` cứng — [LoginView.fxml L24](../../src/user/src/main/resources/com/chatapp/user/view/LoginView.fxml).
- ComboBox giới tính có `<value>Nam</value>` mặc định — [RegisterView.fxml L73](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml), [ProfileView.fxml L72](../../src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml). M23 nói giới tính là tùy chọn — [UC L51](../../docs/ai/requirements-analysis/use-case-specification.md).
- "Nhập lại mật khẩu" ([RegisterView.fxml L55–L56](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml)) không có cột. Đúng như vậy là hợp lý, vì chỉ dùng để so khớp ở client/server.
- Các thống kê admin dựa vào `registration_source='SELF_REGISTERED'` và `created_at` — [design-baseline.md L220](../../docs/database/design-baseline.md); [verify.sql L171](../../script/tests/verify.sql).

Xung đột tương ứng: **XD-22, XD-08, XD-23, XD-26**.

### Inferences
- **XD-22:** Nếu server đăng ký quên truyền `registration_source`, INSERT lỗi 23502. Nếu server lỡ truyền `'INTERNAL'`, tài khoản tự đăng ký sẽ không được tính vào A5/A6. Thêm `DEFAULT 'SELF_REGISTERED'` là an toàn, vì admin luôn truyền `'INTERNAL'` tường minh. Server không bao giờ được nhận `system_role`/`account_status` từ client.
- **XD-08:** Người dùng bỏ qua giới tính vẫn bị lưu "Nam". Điều này làm sai dữ liệu hiển thị trong cột giới tính ở admin S11.

### Gaps
- Không tìm thấy quy định UI có tự đăng nhập sau khi đăng ký hay không (UC-01 chỉ nói quay về S01).

## Có giá trị enum/trạng thái nào mà chữ hiển thị lệch với giá trị DB không (VD "Nam/Nữ" so với "M/F")?

### Takeaway
DB không định nghĩa enum cho giới tính, nên lệch không phải kiểu "Nam" và "M". Vấn đề là hoàn toàn chưa có tập mã chuẩn, trong khi hai app dùng hai tập nhãn khác nhau. Trạng thái tài khoản và vai trò là mã tiếng Anh trong DB, UI hiển thị nhãn tiếng Việt; cần một bảng ánh xạ ở client.

### Cited Findings
- Giới tính: user app có 4 lựa chọn "Nam", "Nữ", "Khác", "Không muốn nêu" — [RegisterView.fxml L67–L70](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml), [ProfileView.fxml L66–L69](../../src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml). Admin app có 3 lựa chọn "Nam", "Nữ", "Khác" — [src/admin/src/main/resources/com/chatapp/admin/view/UserFormDialog.fxml L46–L51](../../src/admin/src/main/resources/com/chatapp/admin/view/UserFormDialog.fxml). Mock admin lưu thẳng nhãn "Nam"/"Nữ" — [src/admin/.../sample/SampleData.java L54–L63](../../src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java). DB: `gender text`, không CHECK — [schema.sql L14](../../script/schema.sql). Seed không chèn giới tính cho ai — [seed.sql L28–L45](../../script/seed.sql).
- Trạng thái tài khoản: DB có `'ACTIVE','LOCKED','DELETED'` — [schema.sql L20](../../script/schema.sql). Admin hiển thị "Hoạt động" / "Bị khóa" — [UsersView.fxml L47–L48](../../src/admin/src/main/resources/com/chatapp/admin/view/UsersView.fxml). M1 tách "Tài khoản" và "Kết nối (Online/Offline)" — [UC L29](../../docs/ai/requirements-analysis/use-case-specification.md). Ở user app, trạng thái tài khoản chỉ xuất hiện qua thông báo khi đăng nhập hoặc bị ngắt (XD-18).
- Mã `registration_source` `'SELF_REGISTERED'|'INTERNAL'` và `system_role` `'ADMIN'|'USER'` — [schema.sql L19, L21](../../script/schema.sql). User app không hiển thị hai giá trị này.

Xung đột tương ứng: **XD-07** (chính), **XD-08**.

### Inferences
- Khuyến nghị: thống nhất giá trị lưu là mã (VD `'MALE','FEMALE','OTHER'`), dùng NULL cho "Không muốn nêu" hoặc khi bỏ trống, và thêm `CHECK (gender IS NULL OR gender IN (...))`. Cả hai app dùng chung một enum/converter trong `src/common` để không lệch nhãn. Admin cần thêm lựa chọn tương ứng NULL ("Không nêu"), nếu không admin sẽ ghi đè NULL của người dùng thành một giá trị cụ thể khi sửa hồ sơ.
- Nếu lưu thẳng nhãn tiếng Việt, mọi thay đổi chữ hiển thị (VD "Nữ" ↔ "Nữ giới") sẽ làm hỏng dữ liệu cũ, và lọc/thống kê sẽ phải so chuỗi có dấu.

### Gaps
- Chưa có tài liệu nào chốt tập giá trị giới tính.

## Dữ liệu mock trong controller/FXML có nhất quán với seed.sql không?

### Takeaway
Không. UI và cả admin app xoay quanh `an.nguyen` / "Nguyễn Văn An" / `@gmail.com` cùng một nhóm bạn `bich.tran`, `minh.vo`… Seed lại dùng `Minh`, `Trang`, `Binh`, `archive`, `demo_admin`, `locked_user` với email `@example.test`, hash giả và không có trường hồ sơ tùy chọn. Seed được thiết kế để kiểm thử ràng buộc chứ không để demo UI, và verify.sql đếm cứng nên khó bổ sung dữ liệu demo.

### Cited Findings
- Mock tài khoản hiện tại: `an.nguyen`, "Nguyễn Văn An", `an.nguyen@gmail.com`, ngày sinh 12/05/2004, "Nam", "227 Nguyễn Văn Cừ, Quận 5, TP.HCM", "tham gia 12/09/2026" — [ProfileView.fxml L30–L31, L46–L77](../../src/user/src/main/resources/com/chatapp/user/view/ProfileView.fxml); [ProfileController.java L18](../../src/user/src/main/java/com/chatapp/user/controller/ProfileController.java); [RegisterView.fxml L37–L78](../../src/user/src/main/resources/com/chatapp/user/view/RegisterView.fxml); admin mock có cùng hồ sơ — [admin SampleData.java L55](../../src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java). Mật khẩu mẫu `matkhau123` — [LoginView.fxml L32](../../src/user/src/main/resources/com/chatapp/user/view/LoginView.fxml).
- Mock bạn bè/lời mời/chặn: `bich.tran`, `camly.le`, `minh.vo`, `ha.do`, `dung.pham`, `khang.ngo`, `thu.huynh`, `phong.lam`, `kevin.tran`… — [user SampleData.java L114–L135](../../src/user/src/main/java/com/chatapp/user/sample/SampleData.java). Lớp này có ghi chú "Delete this class when V2 loads real data" — [L5–L8](../../src/user/src/main/java/com/chatapp/user/sample/SampleData.java).
- Seed: `Minh`/`minh`/`Trang`/`Binh`/`archive`/`demo_admin`/`locked_user`, email `@example.test` (có cả email cố ý thừa khoảng trắng `' Minh@example.test '`), `password_hash 'fixture-only'`, không có address/birth_date/gender — [seed.sql L28–L45, L126–L127](../../script/seed.sql).
- verify.sql khóa cứng danh sách 16 bảng và 16 PK — [L47–L57](../../script/tests/verify.sql). Nó cũng đếm chính xác 3 tài khoản SELF_REGISTERED, 3 lượt mở app và 2 người mở app trong tháng 11/2026 (giờ VN) — [L171–L173](../../script/tests/verify.sql); số liệu này phụ thuộc mốc `first_at/change_at/rejoin_at` — [seed.sql L24–L26](../../script/seed.sql).
- Admin mock dùng "—" cho địa chỉ trống — [admin SampleData.java L60](../../src/admin/src/main/java/com/chatapp/admin/sample/SampleData.java).

Xung đột tương ứng: **XD-24, XD-25, XD-26, XD-11, XD-03**.

### Inferences
- Nếu thêm tài khoản demo `an.nguyen` vào `seed.sql` với `created_at` mặc định (thời điểm chạy, VD tháng 11/2026), kiểm tra ở verify.sql L171 (đúng 3 đăng ký trong tháng 11) có thể hỏng. Nên tách thành `seed_demo.sql` riêng, hoặc đặt `created_at` ngoài khoảng tháng 11/2026.
- Ký tự hiển thị thay thế như "—" (admin) không được ghi xuống DB; giá trị trống phải là NULL.
- Seed không có giá trị cho địa chỉ, ngày sinh, giới tính nên mọi CHECK mới thêm cho các cột này (XD-07, XD-09) sẽ chưa được kiểm thử. Cần thêm fixture và assertion vào verify.sql (XD-25).

### Gaps
- Không rõ nhóm có muốn seed dùng cho demo UI hay chỉ dùng cho kiểm thử DB. design-baseline.md L243 chỉ nói "dữ liệu giả dành cho kiểm thử DB".
