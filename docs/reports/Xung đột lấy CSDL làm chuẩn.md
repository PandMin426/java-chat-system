# Xung đột màn hình – CSDL cho bản nộp V1

Bản này điều chỉnh báo cáo [lấy CSDL làm chuẩn](Xung%20đột%20lấy%20CSDL%20làm%20chuẩn%20-%20đầy%20đủ%20V2.md) theo **phạm vi Phiên bản 1**. Chỉ giữ những xung đột ảnh hưởng tới các thứ phải nộp, phần còn lại chuyển sang V2.

## Phạm vi và tiêu chí

**Yêu cầu V1 theo đề** (`docs/Final_Project_He_Thong_Chat_Chi_Tiet.md:370-412`, viết tắt `PDF`):

- Phạm vi là "Giao diện và cơ sở dữ liệu". **Chưa cần lập trình sự kiện** cho các màn hình (`PDF:376`).
- Cần nộp: `src/` (mã nguồn màn hình của cả hai phân hệ), `script/` (script tạo CSDL) và file báo cáo. Đề cũng yêu cầu thư mục `git/` (ảnh commit của từng thành viên, `PDF:394`). Sai cấu trúc file nén bị **0 điểm** (`PDF:338,351`).
- Báo cáo phải có đủ 5 nội dung: thông tin nhóm; công việc của từng thành viên; bảng đóng góp tổng bằng 100; **thiết kế CSDL**; **danh sách màn hình kèm hình chụp** (`PDF:398-404`). Thiếu nội dung thì **0 điểm** (`PDF:344`).
- Hạn nộp: Chủ nhật 22/11/2026 (`README.md:12`).

**Nguyên tắc** giữ nguyên như bản trước: lấy CSDL làm chuẩn (`schema.sql`, `seed.sql`, `verify.sql`, `design-baseline.md`), chỗ nào lệch thì sửa phía còn lại. Ngoại lệ là đề bài đứng trên CSDL.

**Một xung đột được tính cho V1 khi rơi vào một trong ba trường hợp:**

1. **Script**: chạy không được, sai so với chính thiết kế, hoặc chưa đáp ứng chức năng đề đòi.
2. **Màn hình**: **nội dung hiển thị** (cột, trường, nhãn, lựa chọn, dữ liệu mẫu) mâu thuẫn với những gì DB lưu được; hoặc thiếu giao diện cho một chức năng đề bắt buộc.
3. **Báo cáo**: thiếu nội dung bắt buộc, hoặc phần thiết kế CSDL và ảnh chụp mâu thuẫn với script và code.

**Không tính cho V1**: handler, `fx:id` dùng để nối sự kiện, validation, server, socket, DTO, múi giờ khi tính toán, BCrypt, phân trang/sắp xếp ở server, và mọi logic chạy thật. Các mục này nằm ở **Phụ lục: hoãn sang V2**.

## Tóm tắt

Trong 85 mục việc của bản trước, **34 mục ảnh hưởng tới bản nộp V1**. Phần lớn là **bỏ khỏi màn hình những thứ DB không lưu** và **làm cho báo cáo nhất quán**. Ở V1 không cần thêm bảng nào vào DB, trừ khi giảng viên xác nhận RR-01.

| Nhóm | Phía | Cao | Trung bình | Thấp | Tổng |
|---|---|---|---|---|---|
| **SC** — Script CSDL | BE (script) | 0 | 1 | 3 | **4** |
| **MH** — Màn hình | FE (code màn hình) | 2 | 8 | 12 | **22** |
| **BC** — Báo cáo và cấu trúc nộp | Báo cáo / cả hai | 3 | 3 | 2 | **8** |
| **Tổng** | | **5** | **12** | **17** | **34** |
| **RR** — Rủi ro so với đề | | | | | **5** |

**Năm việc Cao phải làm trước 22/11:**

| # | Mã | Việc |
|---|---|---|
| 1 | BC-01 | Thư mục `git/` đang **trống**; cần ảnh commit của từng thành viên |
| 2 | BC-02 | Viết file báo cáo đủ 5 nội dung (chưa có trong repo; mẫu ở `../dumpDocs/BaoCao_V1_Mau.docx`) |
| 3 | BC-04 + MH-01 | Chốt **E2EE** theo DB, rồi sửa mọi chuỗi "server giữ khóa / mã hóa khi lưu" trên màn hình và trong báo cáo |
| 4 | MH-15 | S14 bỏ cột Lý do, cột Trạng thái, nút "Bỏ qua", bộ lọc trạng thái và badge |
| 5 | BC-05 | Chụp lại ảnh các màn hình đã sửa và bổ sung ảnh D04 |

**Viết tắt:** `schema` = `script/schema.sql`; `seed` = `script/seed.sql`; `verify` = `script/tests/verify.sql`; `DBD` = `docs/database/design-baseline.md`; `UCS` = `docs/ai/requirements-analysis/use-case-specification.md`; `uv/`, `uc/`, `uSD` = view, controller, SampleData của user; `av/`, `ac/`, `aSD` = view, controller, SampleData của admin. Cột "Mã bản trước" trỏ tới F-/B-/C-/T- trong [bản đầy đủ V2](Xung%20đột%20lấy%20CSDL%20làm%20chuẩn%20-%20đầy%20đủ%20V2.md).

## Phần 1 — SC: Script CSDL (BE)

Thiết kế schema được giữ nguyên. Các mục dưới đây chỉ làm cho script **chạy đúng và khớp với chính thiết kế**.

| ID | Vấn đề | Mức | Bằng chứng | Hướng sửa | Mã bản trước |
|---|---|---|---|---|---|
| SC-01 | Script không tạo database và không đặt encoding: `seed.sql` giả định DB `java_chat_v1_test` đã có sẵn; không có `client_encoding`. Người chấm chạy `psql` trên Windows có thể bị lỗi hoặc hỏng dữ liệu tiếng Việt | **TB** | `seed:1`; `DBD:243-248`; chỉ từng chạy trên Docker (`docs/ai/work-log.md:144,149`) | Thêm `script/create_database.sql` (`CREATE DATABASE … ENCODING 'UTF8' TEMPLATE template0`) và `SET client_encoding = 'UTF8';` ở đầu mỗi script. Ghi thứ tự chạy create → schema → seed → verify vào README và báo cáo | B-02 |
| SC-02 | Tin nhóm chưa được bảo vệ chỉ-ghi-thêm (vẫn UPDATE `encrypted_payload` hoặc DELETE được), trong khi DBD nói giữ nguyên tin đã ghi và tin riêng đã có trigger này | Thấp | `schema:598-600` ↔ `schema:346-349,375-377`; `DBD:206` | Thêm trigger chặn UPDATE/DELETE giống tin riêng | B-04 |
| SC-03 | Seed "Nhóm lưu trữ" đã đóng nhưng `binh` vẫn còn membership mở và nhóm không còn admin nào. Ảnh S13 chụp từ dữ liệu thật sẽ thấy "Admin · 0" | Thấp | `seed:118-125` ↔ `DBD:203` | Đóng luôn membership của `binh` khi đóng nhóm, hoặc ghi rõ trong thiết kế rằng nhóm đã đóng giữ membership để đọc | B-05 |
| SC-04 | Ca kiểm thử "bạn của bạn" chạy **sau** hai lệnh chặn, nên số bạn trực tiếp và số tính cả bạn của bạn luôn bằng nhau, tức không kiểm được công thức | Thấp | `verify:102,121` chạy trước `verify:163-170` | Dời assertion lên trước khi chặn (ví dụ Minh: trực tiếp = 1, tính cả bạn của bạn = 2) | B-03 |

## Phần 2 — MH: Màn hình (FE)

Ở V1 chỉ xét **những gì màn hình hiển thị**. Nếu màn hình hiện một thông tin mà DB không lưu được thì bỏ thông tin đó đi. Nếu đề đòi một chức năng thì màn hình phải có giao diện cho chức năng đó.

### Phân hệ người dùng

| ID | Vấn đề | Mức | Màn hình | Bằng chứng (UI ↔ DB/đề) | Hướng sửa | Mã bản trước |
|---|---|---|---|---|---|---|
| MH-01 | **Giao diện mã hóa theo K4, trong khi DB là E2EE**: D01 có ô "Mã hóa nhóm"; có chuỗi "mã hóa khi lưu trên máy chủ"; ổ khóa chỉ hiện ở một số nhóm; S13 có cột "Mã hóa Có/Không" | **Cao** | D01, S04, S05, S13 | `uv/CreateGroupDialog.fxml:34-35`; `uv/GroupChatView.fxml:90-92`; `av/GroupsView.fxml:43`; `aSD:24` ↔ `schema:544-546` (mọi tin nhóm là `encrypted_payload`); `DBD:133-213` | Bỏ ô mã hóa (mọi nhóm đều E2EE); đổi chuỗi thành "Mã hóa đầu cuối"; ổ khóa hiện ở mọi nhóm; S13 bỏ cột hoặc luôn hiện "E2EE" | F-18 |
| MH-02 | Nhãn "Đã nhận" và huy hiệu số tin chưa đọc, trong khi DB chỉ lưu `sent_at` | **TB** | S04, S05 | `uSD:15,66,78,80`; ảnh `S04-tro-chuyen.png`, `S05-nhom-chat.png` ↔ `schema:163-169`; `DBD:223` | Bỏ khỏi mock | F-17 |
| MH-03 | Dòng hệ thống của nhóm ("… đã đổi tên", "… đã thêm …") và "Tạo … bởi an.nguyen": DB không lưu sự kiện nhóm lẫn người tạo | **TB** | S05, S13 | `uSD:19,28-30,90-97`; `uv/GroupChatView.fxml:87`; `ac/GroupsController.java:75` ↔ `schema:426-451` | Bỏ dòng hệ thống; thay "bởi …" bằng ngày tạo và danh sách admin | F-20, F-21 |
| MH-04 | "Thêm thành viên" (D04) chỉ là D01 đổi tiêu đề: vẫn có ô tên nhóm, ô mã hóa, nút "Tạo nhóm", và chọn sẵn cả người đã là thành viên. Đề có yêu cầu thêm thành viên | **TB** | S05, D04 | `uc/GroupChatController.java:83-86`; `uv/CreateGroupDialog.fxml:17-39` ↔ `PDF:300`; `schema:453-454` | Tách FXML riêng cho D04: chỉ có danh sách chọn, không chọn sẵn thành viên hiện có, nút "Thêm" | F-22 |
| MH-05 | Kết quả tìm người thiếu nút "Nhắn tin" (kể cả với người lạ) và "Tạo nhóm", trong khi đề có yêu cầu | **TB** | S07 | `uc/SearchUsersController.java:42-55` ↔ `PDF:253-254`; `schema:153-159` | Thêm 2 nút trên mỗi dòng kết quả | F-27 |
| MH-06 | Đề yêu cầu xóa một hoặc vài dòng tin; S04 mới có mục menu "Chọn tin nhắn để xóa" nhưng chưa có giao diện ở chế độ chọn | **TB** | S04 | `uv/ChatView.fxml:77` ↔ `PDF:273-274`; `schema:176-180` | Thêm trạng thái giao diện: ô chọn ở mỗi tin + thanh "Đã chọn n tin · Xóa · Hủy" (chưa cần sự kiện) | F-12 |
| MH-07 | D02 có ô lý do và ghi chú, trong khi bảng `spam_reports` không có cột cho hai thứ này | **TB** | D02 | `uv/ReportSpamDialog.fxml:16-35` ↔ `schema:182-188` | Còn câu xác nhận và ô tích "Chặn luôn người này" | F-31 |
| MH-08 | Hint username ghi "chỉ chữ thường", trong khi DB phân biệt hoa/thường và seed có `Minh` | Thấp | S02 | `uv/RegisterView.fxml:38` ↔ `schema:8,38-39`; `seed:29` | Sửa hint: "phân biệt chữ hoa/thường, không đổi được về sau" | F-01 |
| MH-09 | "Hoạt động 2 giờ trước", "Đã chặn ngày 06/11" và ngày kết bạn ở tab Bạn bè của S11: DB không lưu các mốc này | Thấp | S06, S11 | `uSD:115-121,128-129`; `ac/UsersController.java:110-119` ↔ `schema:113-149`; `DBD:223` | Chỉ hiện Online/Offline; bỏ các ngày | F-11, F-29 |
| MH-10 | Mẫu S07 gõ "nguyen" ra "Nguyễn …", trong khi DB tìm có phân biệt dấu | Thấp | S07 | `uv/SearchUsersView.fxml:22`; `uSD:131-135` ↔ `DBD:225`; `verify:181-186` | Đổi mẫu thành "nguyễn" | F-26 |
| MH-11 | Giới tính: user app có 4 lựa chọn, admin app có 3; ô được chọn sẵn "Nam"/"Nữ" dù trường này không bắt buộc | Thấp | S02, S09, S11a/b | `uv/RegisterView.fxml:67-73`; `uv/ProfileView.fxml:66-72`; `av/UserFormDialog.fxml:46-54` ↔ `schema:14` (cho NULL) | Thống nhất một danh sách cho cả hai app; không chọn sẵn | F-02, C-07 (hiển thị) |
| MH-12 | Trạng thái mẫu trái quy tắc DB: `kevin.tran` đã bị chặn nhưng vẫn mang nhãn "Người lạ" và ô nhập vẫn bật; người lạ có chấm online; menu có "Hủy kết bạn" khi đang chat với người lạ; D05 chỉ nói người bị chặn không nhắn được, trong khi DB cấm cả hai chiều | Thấp | S04, D05 | `uSD:69,128-129`; `uv/ChatView.fxml:80,110-119`; `uc/ChatViews.java:92,194-198` ↔ `schema:135-140,365-369` | Sửa dữ liệu mẫu và câu chữ cho đúng quy tắc | F-13, F-14, F-15, F-16 |
| MH-13 | Các trạng thái lỗi mà tài liệu UI đã hứa nhưng giao diện chưa có: S01 "Tài khoản đã bị khóa", S02 nhãn lỗi dưới từng trường, S03 "Đã gửi tới ***@…" | Thấp | S01, S02, S03 | `docs/ai/ui-user-screens/ui-user-screens.md:106`; `docs/ai/ui-user-screens/plan.md:38` ↔ `schema:16,20,38-42` | Thêm Label hoặc trạng thái tĩnh, hoặc bỏ lời hứa khỏi tài liệu UI | C-08, C-06, F-03 (giao diện) |
| MH-14 | *(Tùy chọn)* S05 chưa thể hiện hai quy tắc của DB: nhóm đã đóng ở chế độ chỉ đọc, và thành viên mới chỉ thấy tin từ lúc tham gia | Thấp | S05 | `schema:430,527,587`; `DBD:203,205` | Thêm một dòng ghi chú hoặc badge | F-19, F-24 |

### Phân hệ quản trị

| ID | Vấn đề | Mức | Màn hình | Bằng chứng (UI ↔ DB/đề) | Hướng sửa | Mã bản trước |
|---|---|---|---|---|---|---|
| MH-15 | **S14 có cột Lý do, cột Trạng thái, bộ lọc trạng thái, nút "Bỏ qua" và badge "4"**, trong khi DB không lưu lý do hay trạng thái. Đề chỉ yêu cầu xem, lọc/sắp theo thời gian và tên đăng nhập, rồi khóa tài khoản | **Cao** | S14, thanh điều hướng admin | `av/SpamView.fxml:22,35-45,54-56`; `aSD:30,109-118`; `av/AdminMainView.fxml:36` ↔ `schema:182-188`; `PDF:106-113` | Bỏ các phần trên; còn các cột Thời gian · Người báo cáo · Người bị báo cáo và nút "Khóa tài khoản" | F-32 |
| MH-16 | Cột IP ở S12 và ở tab Lịch sử đăng nhập của S11: DB không lưu IP, đề cũng không đòi | **TB** | S11, S12 | `av/LoginLogView.fxml:44`; `av/UsersView.fxml:124-131`; `aSD:21` ↔ `schema:89-97`; `PDF:91-95` | Bỏ cột IP | F-34 |
| MH-17 | Chú thích S12 ghi "mỗi dòng được tính là 1 lần mở ứng dụng", trong khi DB lưu đăng nhập (`login_events`) và mở ứng dụng (`app_open_events`) ở hai bảng riêng | **TB** | S12 | `av/LoginLogView.fxml:21-22` ↔ `schema:89-110`; `DBD:65-66` | Đổi thành "mỗi dòng là một lần đăng nhập thành công" | F-35 |
| MH-18 | Bộ lọc trạng thái ở S11 chỉ có Hoạt động/Khóa, trong khi DB có thêm `DELETED` | Thấp | S11 | `av/UsersView.fxml:43-52` ↔ `schema:20` | Chọn một: thêm lựa chọn "Đã xóa", hoặc ghi rõ danh sách không hiện tài khoản đã xóa | C-10 (hiển thị) |
| MH-19 | Chú thích định nghĩa chưa khớp DB: S15 chỉ tính tài khoản **tự đăng ký**; S17 "chat với n người" chỉ tính tin **gửi đi**, và ngưỡng lọc dùng lượt mở ứng dụng | Thấp | S15a/b, S17a | `av/NewUsersView.fxml:30,54`; `av/ActiveUsersView.fxml:34,53-65` ↔ `DBD:220,222`; `verify:171,174-178` | Thêm dòng chú thích; bộ lọc S17 mặc định là "Mở ứng dụng" | F-39, F-40 |
| MH-20 | Ô lọc tên đăng nhập ở S14 không nói lọc theo người báo cáo hay người bị báo cáo | Thấp | S14 | `av/SpamView.fxml:32` ↔ `DBD:131` (người bị báo cáo) | Placeholder: "Tên đăng nhập người bị báo cáo" | F-33 |

### Chung cho cả hai phân hệ

| ID | Vấn đề | Mức | Màn hình | Bằng chứng | Hướng sửa | Mã bản trước |
|---|---|---|---|---|---|---|
| MH-21 | Số liệu mẫu tự mâu thuẫn và sẽ lộ ra trong ảnh chụp: "Bạn bè · 12" nhưng danh sách chỉ có 4; cùng một người có 2 username (`khang.ngo`/`nguyenkhang`); nút năm S15 là 2024–2026 còn S17 là 2025–2026 | Thấp | S06, S07, S11, S15, S16, S17 | `aSD:65,73-77,143`; `uSD:120,135`; `av/NewUsersView.fxml:40-42`; `av/ActiveUsersView.fxml:83` | Sửa mock cho thống nhất | F-37, F-38, F-41 |
| MH-22 | Comment trong FXML ghi sai mã UC so với UCS | Thấp | D02, S12–S17 | `uv/ReportSpamDialog.fxml:12`; `av/*View.fxml` ↔ `UCS:98,127-134` | Sửa comment | F-42 |

**MH-01 và MH-15 (Cao).** Ở V1, người chấm sẽ đặt phần thiết kế CSDL cạnh ảnh chụp màn hình trong cùng một báo cáo. Đây là hai chỗ mâu thuẫn dễ thấy nhất:
- D01 cho chọn "có hoặc không mã hóa", trong khi CSDL buộc mọi tin nhóm là bản mã E2EE.
- S14 có cột Trạng thái và nút "Bỏ qua", trong khi bảng `spam_reports` chỉ có người báo cáo, người bị báo cáo và thời điểm.

Cả hai chỉ cần sửa FXML và mock, không cần sự kiện.

## Phần 3 — BC: Báo cáo và cấu trúc nộp

| ID | Vấn đề | Mức | Phía | Bằng chứng | Hướng sửa | Mã bản trước |
|---|---|---|---|---|---|---|
| BC-01 | Thư mục **`git/` đang trống**. Đề bắt buộc có ảnh commit của từng thành viên, sai cấu trúc file nén bị 0 điểm, và thành viên không có commit cũng bị 0 điểm | **Cao** | Nộp bài | `git/` (rỗng) ↔ `PDF:320-323,338,394` | Chụp `git log` hoặc trang commit của từng người, đặt vào `git/` | — |
| BC-02 | **File báo cáo V1 chưa có trong repo.** Phải có đủ 5 nội dung: thông tin nhóm, công việc của từng thành viên, bảng đóng góp tổng = 100, thiết kế CSDL, danh sách màn hình kèm ảnh | **Cao** | Báo cáo | `PDF:398-404`; mẫu `../dumpDocs/BaoCao_V1_Mau.docx` | Dựng theo mẫu. Phần CSDL lấy từ BC-03; phần màn hình lấy từ BC-05 | — |
| BC-03 | Phần thiết kế CSDL nếu chép từ DBD sẽ mang theo trạng thái nháp: "chờ review"; các tham chiếu tới Prompt 02/03, Decision Log, DL-16 không có trong repo; các câu "nhóm vẫn cần chốt bên tạo/phân phối khóa, định dạng ciphertext" | **TB** | Báo cáo | `DBD:3,5,213`; `DBD:208-213` | Viết bản chốt: ERD 3 cụm, bảng mô tả 16 bảng, các ràng buộc chính; ghi E2EE là thiết kế đã chọn; các điểm chưa chốt thì ghi "triển khai ở V2" | T-26, BE-30 |
| BC-04 | **Mâu thuẫn mã hóa ngay trong báo cáo**: phần CSDL là E2EE, còn phần màn hình hoặc đặc tả (nếu đưa vào) lại mô tả "server giữ khóa" (K4). Work-log có hai quyết định ngược nhau cùng ngày 08/11 | **Cao** | Cả hai (FE + báo cáo) | `UCS:21,422-432`; `docs/ai/work-log.md:172-173` ↔ `docs/ai/work-log.md:98,111,134`; `DBD:133-213` | Ghi `DECISION` chọn E2EE vào work-log; sửa màn hình theo MH-01; mô tả màn hình nhóm trong báo cáo theo E2EE | T-07 |
| BC-05 | Ảnh chụp màn hình: các ảnh của màn hình bị sửa (MH-01..MH-21) phải chụp lại; **chưa có ảnh D04** | **TB** | Cả hai (FE + báo cáo) | `docs/screens/user/` (13 ảnh, không có D04); `docs/screens/admin/` (13 ảnh) | Sau khi sửa thì chụp lại; thêm `D04-them-thanh-vien.png`; danh sách màn hình trong báo cáo khớp tên file | — |
| BC-06 | Nếu báo cáo có đưa đặc tả use case vào (đề không bắt buộc cho V1), các quy tắc trong đó đang trái DB: IP (BR-05, UC-37/39), username chữ thường (BR-01), báo cáo spam có trạng thái và không được trùng (M6, BR-11, UC-41), tìm kiếm không dấu (UC-07), múi giờ theo máy (BR-15), thành viên mới xem được lịch sử (UC-24), mọi thành viên được thêm người (BR-10), admin cuối bị xóa thì thăng chức người khác (M2), ngày kết bạn (UC-38) | **TB** | Báo cáo | `UCS:30,46,212,216,222-226,297,406,460-474` ↔ `DBD:73,124,131,203-205,220-225`; `schema:89-97,182-188` | Hoặc không đưa đặc tả vào báo cáo V1, hoặc sửa theo T-01..T-24 của bản đầy đủ | T-01..T-24 |
| BC-07 | README và rule ghi tên script là `script/create_db.sql`, trong khi thực tế là `schema.sql` + `seed.sql` + `tests/verify.sql`, và chưa có hướng dẫn chạy | Thấp | Báo cáo / README | `README.md:42,45`; `.agent/rules/rule.md:40,62,147,161` | Sửa tên file; thêm thứ tự chạy (gộp với SC-01) | T-25 |
| BC-08 | DBD chưa mô tả một số ràng buộc đã có trong schema: username, `created_at`, `registration_source` không đổi được; mọi FK là `ON DELETE RESTRICT` và cấm DELETE `users`; hàm `social_pair_is_blocked` | Thấp | Báo cáo | `schema:51-54,62-66,73-76,213-221` ↔ `DBD:73-74` | Bổ sung vào phần "Ràng buộc chính" của báo cáo | BE-29 |

## Rủi ro so với đề

Phần thiết kế CSDL **được chấm ngay ở V1**, nên những chỗ CSDL có thể chưa phủ đề cần được hỏi lại hoặc ghi rõ thành giả định trong báo cáo.

| ID | Rủi ro | Đề | CSDL | Đề xuất cho V1 |
|---|---|---|---|---|
| RR-01 | Xóa lịch sử chat **nhóm** (toàn bộ, một hoặc vài dòng) | Mục "Chat" chung, `PDF:271-274` | Chỉ có `private_message_hides` (`schema:176-180`) | Hỏi giảng viên. Nếu có áp dụng cho nhóm thì thêm `group_message_hides(group_message_id, user_id)` vào script, đây là thay đổi DB duy nhất cần cân nhắc ở V1. Nếu không thì ghi giả định "xóa lịch sử áp dụng cho chat riêng" |
| RR-02 | Tìm chuỗi "với **tất cả mọi người**" có bao gồm tin nhóm không | `PDF:280-281` | DB chỉ tìm được trong chat riêng; tin nhóm là bản mã (`DBD:129,225`) | Ghi trong báo cáo: tìm tin nhóm làm ở client sau khi giải mã (V2). DB không cần đổi |
| RR-03 | Định nghĩa "bạn của bạn" | Đề không định nghĩa, `PDF:148` | Hợp bạn trực tiếp với bạn của bạn, loại trùng và loại chính mình (`DBD:221`) | Ghi thành giả định trong báo cáo; xin giảng viên xác nhận |
| RR-04 | "Số lượng hoạt động" dùng chỉ số nào để lọc | Đề không định nghĩa, `PDF:173,580` | Lượt mở ứng dụng (`DBD:222`) | Ghi thành giả định; chú thích trên S17 (MH-19) |
| RR-05 | Khối lượng E2EE ở V2 (client tự sinh và phân phối khóa; LLM và tìm kiếm trong nhóm phải làm ở client) | "Tham khảo Facebook", `PDF:308` | 3 bảng khóa, epoch, trigger | Không ảnh hưởng V1. Đây là điểm duy nhất nên cân nhắc lại **trước khi nộp** nếu nhóm thấy V2 không kịp, vì sau V1 thiết kế CSDL đã nằm trong báo cáo |

## Checklist nộp V1

| Thành phần | Trạng thái hiện tại | Việc cần làm |
|---|---|---|
| `src/` — màn hình 2 phân hệ | Có đủ màn hình S01–S17, D01–D05; chạy được bằng `javafx:run` | MH-01..MH-22 |
| `script/` — script tạo CSDL | Có `schema.sql`, `seed.sql`, `tests/verify.sql` | SC-01..SC-04; cân nhắc RR-01 |
| `git/` — ảnh commit | **Trống** | BC-01 |
| File báo cáo | **Chưa có** | BC-02..BC-08 |
| Thư mục thừa trong file nén | `research_notes/`, `reports/`, `docs/ai/`, `.agent/`, `release/`, `target/` | Không đưa vào file nén nếu không cần; chạy `.\mvnw.cmd clean` trước khi nén |

## Những gì đã khớp

Các mục sau đã khớp nên giữ nguyên:
- **Schema và DBD**: khớp về cấu trúc (16 bảng, 25 FK, 21 CHECK, 10 trigger). Seed thỏa mọi ràng buộc trên DB trống, verify có đủ 7 thông báo PASS.
- **Màn hình có trường khớp DB**: 4 trường bắt buộc khi đăng ký; username bị khóa ở S09/S11b; đủ 6 trường hồ sơ; D03 chỉ xóa phía mình; hiệu ứng chặn của D05; các tab bạn bè và lời mời của S06; S16 có hai cột bạn trực tiếp và tính cả bạn của bạn.
- **Màn hình admin đã có giao diện cho mọi chức năng ADM-01..ADM-09 mà đề yêu cầu**, trừ những phần thừa đã nêu ở MH-15..MH-17.

## Phụ lục — Hoãn sang V2

Các mục này không ảnh hưởng tới bản nộp V1, vì đều là sự kiện, logic hoặc dữ liệu chạy thật. Chi tiết xem [bản đầy đủ V2](Xung%20đột%20lấy%20CSDL%20làm%20chuẩn%20-%20đầy%20đủ%20V2.md).

| Nhóm | Mã bản trước | Lý do hoãn |
|---|---|---|
| Nối handler và `fx:id` cho sự kiện | F-03, F-04, F-05, F-06, F-09, F-10, F-23, F-25, F-28, F-30, F-22 (ẩn theo quyền) | V1 chưa cần lập trình sự kiện |
| Dữ liệu điền sẵn và số ghi cứng | F-07, F-08, F-36 | Dữ liệu mẫu cho giao diện là hợp lệ ở V1 |
| Kiểm tra dữ liệu nhập | C-05, C-06 (logic), C-07 (mã lưu) | Là logic xử lý |
| Server và giao thức | B-10..B-22, C-04, C-08 (logic), C-09, C-11..C-14, C-16 | Chưa có server ở V1 |
| E2EE triển khai | C-01, C-02, C-03, B-22 | Thiết kế đã có trong DB; phần triển khai thuộc V2 |
| Seed demo, hash BCrypt, tài khoản admin | B-01, C-17 | Chỉ cần khi đăng nhập thật |
| Gia cố DB tùy chọn | B-06, B-07, B-08, B-09 | Không đổi thiết kế, không ảnh hưởng chấm V1 |
| Múi giờ khi tính toán, tài khoản DELETED làm crash | C-15, C-10 (logic) | Chỉ xảy ra khi đọc dữ liệu thật |
| Cấu hình, module protocol, DTO, kiểu thời gian | C-18, C-19, C-20, C-21 | Yêu cầu của V2 (`PDF:418-442`) |
| Sửa use case | T-01..T-24 | Chỉ cần làm ở V1 nếu đặc tả được đưa vào báo cáo (BC-06) |
