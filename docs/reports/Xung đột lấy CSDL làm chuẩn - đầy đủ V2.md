# Xung đột màn hình – CSDL khi lấy CSDL làm chuẩn

Bản này trình bày lại báo cáo [Xung đột màn hình và CSDL](Xung%20đột%20màn%20hình%20và%20CSDL.md) theo một nguyên tắc duy nhất: **thiết kế CSDL hiện tại là nguồn sự thật**. Thiết kế gồm `script/schema.sql`, `script/seed.sql`, `script/tests/verify.sql` và `docs/database/design-baseline.md`. Mọi chỗ lệch được giải quyết bằng cách sửa phía còn lại: giao diện (FE), server (BE) hoặc tài liệu use case. Chỉ có hai ngoại lệ:

1. **Đề bài** (`docs/Final_Project_He_Thong_Chat_Chi_Tiet.md`) đứng trên CSDL. Chỗ nào CSDL không đáp ứng được đề thì ghi ở mục **Rủi ro so với đề**.
2. **Lỗi nội bộ của chính phía DB** vẫn phải sửa. Đó là các chỗ script lệch với design-baseline, seed không dùng được, hoặc verify kiểm sai. Sửa những chỗ này không đổi thiết kế.

## Tóm tắt

Lấy CSDL làm chuẩn thì **phần lớn xung đột được giải quyết bằng cách bỏ bớt trên UI và sửa use case**, không cần thêm bảng. Đề bài không đòi IP đăng nhập (`PDF:89-95`), không đòi trạng thái hay lý do báo cáo spam (`PDF:106-113`), không đòi trạng thái đã nhận/đã đọc, ngày kết bạn, người tạo nhóm hay "hoạt động lần cuối". Những thứ đó chỉ có trong use case và mock của nhóm, nên bỏ được.

Cái giá lớn nhất là **mã hóa nhóm**. CSDL đã chọn E2EE theo thiết bị (`schema:425-600`, `DBD:133-213`). Hướng này sát đề hơn, vì đề bảo "tham khảo nhóm chat mã hóa của Facebook" (`PDF:308`). Nhưng nó kéo theo phần việc nặng nhất của V2: client tự sinh khóa, mã hóa và giải mã, server chỉ chuyển gói khóa. Toàn bộ chuỗi UI "server giữ khóa" phải đổi. Ngoài ra, tìm tin nhóm và LLM trong nhóm phải làm ở client.

| Phân loại | Cao | Trung bình | Thấp | Tổng |
|---|---|---|---|---|
| **F** — chỉ sửa FE (JavaFX) | 2 | 23 | 17 | **42** |
| **B** — chỉ sửa BE (script DB hoặc server) | 3 | 12 | 7 | **22** |
| **C** — sửa cả FE và BE | 5 | 15 | 1 | **21** |
| **Tổng việc code** | **10** | **50** | **25** | **85** |
| **T** — chỉ sửa tài liệu use case/README/DBD | | | | **26** |
| **R** — rủi ro so với đề | | | | **7** |

Mã mới dùng tiền tố F/B/C/T/R để không trùng với FE-/BE-/FB- của báo cáo cũ. Cột "Mã cũ" giúp đối chiếu, và **Phụ lục** ở cuối ánh xạ đủ 105 mục cũ.

**Viết tắt** giữ như báo cáo cũ: `schema`, `seed`, `verify`, `DBD` (design-baseline), `UCS` (use-case-specification), `RA` (requirements-analysis), `WL` (work-log), `PDF` (bản chi tiết đề), `uv/` `uc/` `uSD` (view, controller, SampleData của user), `av/` `ac/` `aSD` (của admin).

## Mười việc chặn phải làm trước

| # | Mã | Việc | Vì sao chặn |
|---|---|---|---|
| 1 | T-07 | Ghi `DECISION` vào work-log: **chọn E2EE theo DB, hủy K4** | Hai hướng đang song song (`WL:98,111` ↔ `WL:172-173`); không chốt thì C-01..C-03, F-18, F-19, B-22 không làm được |
| 2 | B-10 | Dựng module server (JDBC, BCrypt, socket) | Mọi mục B-11..B-22 không có chỗ thực thi |
| 3 | C-19, C-20 | Module protocol thuần Java, DTO có `long id` + enum khớp CHECK | Mọi lệch kiểu giữa UI và DB sẽ hiện ra ở giao thức |
| 4 | C-01 | Thiết kế luồng E2EE phía client (khóa thiết bị, gói khóa, epoch) | DBD còn để ngỏ "bên tạo/phân phối khóa, định dạng ciphertext" (`DBD:208-213`) |
| 5 | B-01 | `seed_demo.sql` có hash BCrypt thật + tài khoản admin | Hiện không tài khoản seed nào đăng nhập được (`seed:2`) |
| 6 | C-15 | Áp dụng Asia/Ho_Chi_Minh ở server và UI | Seed đặt mốc 31/10 17:00 UTC; gom theo UTC sẽ lệch tháng ở S15/S17 |
| 7 | C-10 | UI xử lý tài khoản DELETED (trường NULL) | Seed đã có tài khoản xóa; S11 `initials()` sẽ ném NPE ngay lần nối DB đầu tiên |
| 8 | F-32, F-31 | Bỏ Lý do/Trạng thái/"Bỏ qua" khỏi S14 và D02 | DB không có cột này (`schema:182-188`) |
| 9 | F-34, F-35 | Bỏ cột IP; sửa chú thích S12 | DB không lưu IP; "mở ứng dụng" là bảng riêng `app_open_events` |
| 10 | R-01, R-02 | Hỏi giảng viên về xóa/tìm lịch sử **nhóm** | Đề có thể hiểu là áp dụng cho cả nhóm, trong khi DB chỉ hỗ trợ chat riêng |

## Các quyết định CSDL đã trả lời sẵn

Khi lấy CSDL làm chuẩn, những câu hỏi từng phải chốt ở báo cáo cũ (QĐ-01..QĐ-21) phần lớn đã có đáp án. Bảng dưới ghi đáp án theo DB và chỗ tài liệu phải sửa theo.

| QĐ cũ | Đáp án theo CSDL | Căn cứ | Tài liệu phải sửa |
|---|---|---|---|
| QĐ-01 Mã hóa nhóm | **E2EE theo thiết bị**, mọi nhóm đều mã hóa, server không đọc nội dung | `schema:459-600`; `DBD:133-213` | T-07 |
| QĐ-02 "Mở ứng dụng" | Bảng riêng `app_open_events`, "kể cả khi dùng lại phiên"; S17 đếm từ bảng này | `schema:102-110`; `DBD:66,222` | T-04 |
| QĐ-03 IP | **Không lưu IP** | `schema:89-97` | T-03 |
| QĐ-04 Username | **Phân biệt hoa/thường**, không ràng buộc định dạng | `schema:8,38-39`; `DBD:73,225`; `verify:64-65` | T-01 |
| QĐ-05 Tìm kiếm | Họ tên, tên nhóm, nội dung chat riêng: không phân biệt hoa/thường nhưng **phân biệt dấu**; username phân biệt hoa/thường | `DBD:225`; `verify:181-186` | T-06 |
| QĐ-06 Múi giờ | **Asia/Ho_Chi_Minh**, khoảng nửa mở `[từ 00:00, đến+1 00:00)` | `schema:2-3`; `DBD:225` | T-05 |
| QĐ-07 Admin duy nhất bị xóa | **Đóng nhóm**, giữ lịch sử theo khoảng quyền | `DBD:203` | T-11 |
| QĐ-08 Thành viên mới xem lịch sử | **Không**: chỉ thấy tin từ lúc tham gia | `DBD:205`; `schema:527,587` | T-08 |
| QĐ-09 Quyền thêm/xóa thành viên | **Chỉ admin nhóm** thêm/xóa và cấp quyền admin | `DBD:203,212` | T-13 |
| QĐ-10 Báo cáo spam | **Mỗi lần báo cáo một bản ghi** (cho phép trùng); điều kiện là đã có ít nhất một tin riêng theo **bất kỳ chiều nào** | `DBD:124,131`; `schema:403-419`; `verify:116` | T-18 |
| QĐ-13 Đăng ký mới | Chỉ đếm `SELF_REGISTERED` | `DBD:220`; `verify:171` | T-21 |
| QĐ-14 Định nghĩa S17 | Đếm tin **gửi đi**: người nhận riêng phân biệt, nhóm có gửi tin phân biệt; **ngưỡng lọc dùng lượt mở app** | `DBD:222`; `verify:174-178` | T-21 |
| QĐ-15 M7/M12/M15 | M7: hợp bạn trực tiếp ∪ bạn của bạn, loại trùng và chính mình; M12: chặn cấm chat riêng hai chiều; M15: xóa lịch sử chỉ ẩn phía mình | `DBD:221,130`; `schema:176-180,366-369` | T-24 |
| QĐ-17 Đã nhận/đã đọc/last seen | **Không lưu**; online/offline chỉ nằm trong lớp kết nối | `DBD:223` | T-20 |
| QĐ-19 Seed | `seed.sql` là dữ liệu kiểm thử cho DB | `DBD:243` | (thêm `seed_demo.sql`, B-01) |

**Quyết định CSDL chưa trả lời, vẫn cần chốt:**

| Mã | Câu hỏi | Ảnh hưởng |
|---|---|---|
| Q-01 | Tập mã giới tính (DB là text tự do, `schema:14`) | C-07 |
| Q-02 | Độ dài tối đa họ tên/email/địa chỉ/tin nhắn/tên nhóm (DB không giới hạn) | C-05 |
| Q-03 | Tài khoản ADMIN có dùng `user.jar` không? Có tính vào S11, S15–S17 không? | C-11 |
| Q-04 | Có làm "ghi nhớ đăng nhập" không (DB đã chừa chỗ cho "dùng lại phiên")? Nếu không thì mỗi lần đăng nhập ghi đúng một `app_open_event` | B-14, F-35 |
| Q-05 | Ai được **đổi tên** nhóm (DBD chỉ nói thêm/xóa/cấp quyền)? | B-19, F-22 |
| Q-06 | Đóng nhóm thì có đóng luôn các membership đang mở không? | B-05, B-15 |
| Q-07 | Tài khoản LOCKED có được dùng "quên mật khẩu" không? | B-13 |
| Q-08 | Framework backend (`README.md:27` ghi chưa thống nhất, `WL:84` ghi Spring Boot) | B-10 |
| Q-09 | Định nghĩa M7 "bạn của bạn" cần giảng viên xác nhận (đề không định nghĩa, `PDF:148`) | R-04 |

## Rủi ro so với đề

Đây là những chỗ mà **lấy CSDL làm chuẩn có thể không đạt yêu cầu đề**. Cần hỏi giảng viên hoặc chấp nhận mở rộng DB.

| Mã | Rủi ro | Đề | CSDL | Đề xuất |
|---|---|---|---|---|
| R-01 | Xóa lịch sử chat **nhóm** (toàn bộ, một dòng, vài dòng) | Mục "Chat" chung, `PDF:271-274`, không loại trừ nhóm | Chỉ có `private_message_hides` (`schema:176-180`) | Hỏi giảng viên. Nếu phải làm cho nhóm thì thêm `group_message_hides(group_message_id, user_id)`; đây là ngoại lệ duy nhất cần thêm bảng |
| R-02 | Tìm chuỗi "với **tất cả mọi người**" có gồm tin nhóm không | `PDF:280-281` | DBD chỉ hỗ trợ tìm trong chat riêng (`DBD:129,225`); tin nhóm là `bytea` | Với E2EE, làm ở client: tải bản mã trong khoảng quyền, giải mã rồi lọc trong bộ nhớ (C-03). DB không cần đổi |
| R-03 | LLM gợi ý/chỉnh tin trong **nhóm** | `PDF:285-286` | Server không đọc được tin nhóm | Client chỉ gửi đoạn nháp người dùng chủ động chọn tới proxy LLM; UI ghi rõ nội dung sẽ rời thiết bị (C-03) |
| R-04 | Định nghĩa "bạn của bạn" | Đề không định nghĩa, `PDF:148` | Hợp và loại trùng (`DBD:221`) | Xin xác nhận (Q-09) |
| R-05 | "Số lượng hoạt động" dùng chỉ số nào để lọc | Đề không định nghĩa, `PDF:173,580` | Lượt mở app (`DBD:222`) | Ghi rõ trên S17 (F-40) |
| R-06 | Khối lượng E2EE trước hạn V2 | Đề chỉ nói "tham khảo Facebook" | 3 bảng khóa, epoch, trigger | Lên kế hoạch C-01 sớm. Nếu không kịp thì đây là điểm duy nhất nên cân nhắc quay lại K4 |
| R-07 | Username phân biệt hoa/thường cho phép tài khoản giả dạng (`An.Nguyen` ↔ `an.nguyen`) | Đề không quy định | `COLLATE "C"` | Rủi ro UX, không vi phạm đề; F-01 hiển thị cảnh báo khi đăng ký |

## Phần 1 — F: 42 mục chỉ sửa FE

Phần lớn là **bỏ khỏi UI những gì DB không lưu**, hoặc **thêm trạng thái mà DB đã có** nhưng UI chưa thể hiện.

### Tài khoản / Đăng nhập

| ID | Việc | Phân loại | Màn hình | Bằng chứng (UI ↔ DB) | Mã cũ |
|---|---|---|---|---|---|
| F-01 | Bỏ "chỉ chữ thường" khỏi hint username; không tự `toLowerCase` ở S01/S03; ghi "phân biệt chữ hoa/thường"; ô tìm username ở S07/S11 so khớp đúng hoa/thường | [Nghiệp vụ] · TB | S01, S02, S03, S07, S11 | `uv/RegisterView.fxml:38` ↔ `schema:8,38-39`; `verify:64-65`; `seed:29,32` | FB-01 |
| F-02 | Bỏ giá trị giới tính chọn sẵn ("Nam", "Nữ"); để trống thì gửi NULL | [Nghiệp vụ] · TB | S02, S09, S11a | `uv/RegisterView.fxml:73`; `uv/ProfileView.fxml:72`; `ac/UserFormController.java:58-59` ↔ `schema:14` (cho NULL) | FE-01 |
| F-03 | Nối nút "Gửi mật khẩu mới"; thêm trạng thái "Đã gửi tới ***@…" và thông báo chung khi không khớp | [Luồng] · TB | S03 | `uv/ForgotPasswordView.fxml:29` ↔ DB đủ (`schema:9-10`; `DBD:223`) | FE-02 |
| F-04 | Đặt `fx:id` cho 3 ô mật khẩu và nối handler tab Đổi mật khẩu | [Luồng] · TB | S09 | `uv/ProfileView.fxml:86-105` ↔ `schema:10` | FE-03 |
| F-05 | Đặt `fx:id` cho họ tên/email/giới tính/địa chỉ; nối Lưu/Hoàn tác | [Luồng] · TB | S09 | `uv/ProfileView.fxml:50-83` ↔ `schema:8-14` | FE-04 |
| F-06 | Đăng ký xong thì điền sẵn username ở S01 | [Luồng] · Thấp | S02→S01 | `uc/RegisterController.java:37-39` | FE-05 |
| F-07 | Đổi `text=` điền sẵn (`an.nguyen`/`matkhau123`, `admin`/`admin@2026`) thành promptText | [Lưu trữ] · Thấp | S01, S02, S03, S10 | `uv/LoginView.fxml:24,32`; `av/AdminLoginView.fxml:25,29` ↔ không có trong `seed:28-45` | FE-06, FB-09 (UI) |
| F-08 | "—" chỉ là nhãn hiển thị; form sửa phải gửi NULL, không gửi "—" | [Lưu trữ] · Thấp | S11, S11b | `aSD:60,62`; `ac/UserFormController.java:57` ↔ `schema:12-14` | FE-07 |
| F-09 | Hộp xác nhận xóa người dùng (gõ lại username) | [Luồng] · Thấp | S11 | `av/UsersView.fxml:102` ↔ xóa mềm `schema:44-54` | FE-08 |
| F-10 | Dialog đặt lại mật khẩu nhận `user_id` của dòng đang chọn | [Luồng] · Thấp | S11c | `av/ResetPasswordDialog.fxml:17,29` ↔ `schema:7` | FE-09 |
| F-11 | Bỏ "Hoạt động 2 giờ trước / hôm qua"; chỉ hiện Online/Offline | [Lưu trữ] · Thấp | S06 | `uSD:115-121` ↔ không có `last_seen_at`; `DBD:223` | FB-14 |

### Chat 1-1

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| F-12 | Làm chế độ "Chọn tin để xóa" (thanh "Đã chọn n tin · Xóa · Hủy"); mỗi tin chọn = một dòng ẩn | [Luồng] · TB | S04 | `uv/ChatView.fxml:77` ↔ `schema:176-180`; đề `PDF:273-274` | FE-10 |
| F-13 | Ô nhập có 2 trạng thái "Bạn đã chặn người này" / "Không thể gửi tin"; `kevin.tran` đã chặn thì không gắn nhãn "Người lạ" | [Luồng] · TB | S04 | `uv/ChatView.fxml:110-119`; `uSD:69,128-129` ↔ `schema:365-369` | FE-11 |
| F-14 | Ẩn chấm online với người không phải bạn | [Nghiệp vụ] · Thấp | S04 | `uc/ChatViews.java:92` ↔ `PDF:220` | FE-12 |
| F-15 | "Hủy kết bạn" chỉ hiện khi đang là bạn | [Luồng] · Thấp | S04 | `uv/ChatView.fxml:80` ↔ `schema:135-140` | FE-13 |
| F-16 | Thêm vào câu chữ D05: "Bạn cũng không nhắn được cho người này" | [Nghiệp vụ] · Thấp | D05 | `uc/ChatViews.java:194-198` ↔ `schema:366` | FE-14 |
| F-17 | Bỏ nhãn "Đã nhận" và huy hiệu số chưa đọc khỏi mock, ảnh chụp và danh sách hội thoại | [Lưu trữ] · TB | S04, S05 | `uSD:15,66,78,80`; ảnh `S04-tro-chuyen.png` ↔ `schema:163-169` (chỉ `sent_at`); `DBD:223` | FB-19 (UI) |

### Nhóm & mã hóa

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| F-18 | **Chuyển UI sang E2EE**: bỏ ô "Mã hóa nhóm" ở D01 (mọi nhóm đều mã hóa); bỏ chuỗi "mã hóa khi lưu trên máy chủ"; ổ khóa hiện ở mọi nhóm; cột "Mã hóa" ở S13 bỏ đi hoặc luôn là "E2EE" | [Lưu trữ][Luồng] · **Cao** | D01, S04, S05, S13 | `uv/CreateGroupDialog.fxml:34-35`; `uv/GroupChatView.fxml:90-92`; `av/GroupsView.fxml:43`; `aSD:24` ↔ `schema:544-546` (`encrypted_payload` NOT NULL); `DBD:133-213` | FB-22 (UI), FB-23 |
| F-19 | S05 ghi rõ "Bạn chỉ xem được tin từ lúc tham gia nhóm trên thiết bị này"; D04 cảnh báo thành viên mới không thấy tin cũ | [Nghiệp vụ] · TB | S05, D04 | `uv/GroupChatView.fxml` ↔ `DBD:205`; `schema:527,587` | FB-25 |
| F-20 | Bỏ các dòng hệ thống (tạo nhóm, đổi tên, thêm/xóa thành viên) khỏi mock S05, vì DB không lưu được | [Lưu trữ] · TB | S05 | `uSD:19,28-30,90-97` ↔ `schema:428,440-451` | BE-11 |
| F-21 | Bỏ "Tạo… bởi an.nguyen"; thay bằng ngày tạo và danh sách admin hiện tại | [Lưu trữ] · Thấp | S05, S13 | `uv/GroupChatView.fxml:87`; `ac/GroupsController.java:75` ↔ `schema:426-433` | BE-12 |
| F-22 | Tách D04 khỏi D01 (không có ô tên nhóm/mã hóa, lọc bỏ người đã là thành viên); ẩn "Thêm/Xóa thành viên" và "Cấp quyền admin" với thành viên thường | [Luồng] · TB | S05, D04 | `uc/GroupChatController.java:83-86`; `uv/CreateGroupDialog.fxml:17-39` ↔ `DBD:203,212`; `schema:453-454` | FE-15, FB-30 (UI) |
| F-23 | Tạo nhóm từ danh sách online: cho tích chọn nhiều người và truyền danh sách sang D01 | [Luồng] · Thấp | S06, D01 | `uc/FriendsController.java:48-49` ↔ `PDF:246` | FE-16 |
| F-24 | Trạng thái "Nhóm đã đóng – chỉ đọc" ở S05 và badge ở S13; tab "Admin · 0" không bị coi là lỗi | [Nghiệp vụ] · TB | S05, S13 | `av/GroupsView.fxml:41-44` ↔ `schema:430,568-574`; `DBD:203`; `seed:118-125` | FB-28 (UI) |
| F-25 | Người bị xóa khỏi nhóm vẫn thấy nhóm ở dạng chỉ đọc (lịch sử trong khoảng quyền), không biến mất | [Nghiệp vụ] · TB | S04, S05 | `uc/GroupChatController.java:62-66` ↔ `DBD:195-196,207` | FB-31 (UI) |

### Bạn bè / Chặn / Tìm kiếm

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| F-26 | Sửa mẫu S07 ("nguyen" không còn ra "Nguyễn"); placeholder ghi "gõ đúng dấu" | [Nghiệp vụ] · TB | S07, S06 (lọc bạn) | `uv/SearchUsersView.fxml:22`; `uSD:131-135` ↔ `DBD:225`; `verify:181-186` | FB-21 |
| F-27 | Kết quả tìm có thêm "Nhắn tin" (kể cả người lạ) và "Thêm vào nhóm mới" | [Luồng] · TB | S07 | `uc/SearchUsersController.java:42-55` ↔ `schema:153-159`; `PDF:253-254` | FE-17 |
| F-28 | Trạng thái "Bạn đã chặn người này" ở S07, có nút "Bỏ chặn" thay cho "Kết bạn" | [Nghiệp vụ] · TB | S07 | `uc/SearchUsersController.java:42-55` ↔ `schema:144-151` | FB-33 (UI) |
| F-29 | Bỏ "Đã chặn ngày 06/11" và cột ngày kết bạn ở tab Bạn bè S11 | [Lưu trữ] · TB | S06, S11 | `uSD:128-129`; `ac/UsersController.java:110-119` ↔ `schema:113-149` (không có cột thời điểm) | FB-34 |
| F-30 | Không phân biệt "tự rút" với "bị hủy": hiện chung "Lời mời không còn hiệu lực" | [Lưu trữ] · Thấp | S06, S07 | `uc/SearchUsersController.java:57-69` ↔ `schema:121` (`CANCELLED`) | BE-17 |

### Spam

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| F-31 | D02 bỏ ô lý do và ghi chú; còn câu xác nhận và ô tích "Chặn luôn người này" | [Lưu trữ] · TB | D02 | `uv/ReportSpamDialog.fxml:16-35` ↔ `schema:182-188` | FB-36 (D02) |
| F-32 | **S14 bỏ** cột Lý do, cột Trạng thái, bộ lọc trạng thái, nút "Bỏ qua" và badge "4". Nếu cần hiện "Đã khóa" thì suy từ `users.account_status` hiện tại và ghi rõ "trạng thái tài khoản hiện tại" | [Lưu trữ] · **Cao** | S14, thanh điều hướng admin | `av/SpamView.fxml:22,35-45,54-56`; `ac/SpamController.java:53-54,68-88`; `av/AdminMainView.fxml:36` ↔ `schema:182-188`; `DBD:131` | FB-36 (S14), FE-21 (badge) |
| F-33 | Placeholder ô lọc: "Tên đăng nhập người bị báo cáo" | [Nghiệp vụ] · Thấp | S14 | `av/SpamView.fxml:32` ↔ `DBD:131` | FE-19 |

### Admin & thống kê

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| F-34 | Bỏ cột IP ở S12 và tab Lịch sử đăng nhập ở S11 | [Lưu trữ] · TB | S11, S12 | `av/LoginLogView.fxml:44`; `ac/LoginLogController.java:39`; `av/UsersView.fxml:124-131` ↔ `schema:89-97`; đề `PDF:93-95` không đòi IP | FB-11 |
| F-35 | Sửa chú thích S12: "mỗi dòng là một lần đăng nhập thành công", bỏ "= 1 lần mở ứng dụng" | [Nghiệp vụ] · TB | S12 | `av/LoginLogView.fxml:21-22` ↔ `schema:89-110`; `DBD:65-66` | FB-12 (UI) |
| F-36 | S11 phân trang 10 dòng/trang (sửa UC-31) hoặc 50; giữ khung chi tiết | [Nghiệp vụ] · Thấp | S11 | `av/UsersView.fxml:76,79` ↔ UC-31 `UCS:441-442` | FE-20 |
| F-37 | Bỏ các số ghi cứng ("1.284 tài khoản", "37 đang online", "1.932 lượt", "Bạn bè · 12"…), lấy từ server | [Luồng] · Thấp | S11, S12, S15b | `av/UsersView.fxml:31,133`; `av/LoginLogView.fxml:35`; `av/NewUsersView.fxml:73` | FE-21 |
| F-38 | Danh sách năm lấy từ dữ liệu; "hôm nay" do server cấp; xử lý năm rỗng; báo lỗi khi "Từ > Đến" | [Luồng] · TB | S15, S17 | `av/NewUsersView.fxml:40-42,50`; `ac/MonthlyChart.java:35-69` | FE-22 |
| F-39 | Chú thích S15: "chỉ tính tài khoản tự đăng ký" | [Nghiệp vụ] · TB | S15a/b | `av/NewUsersView.fxml:30,54` ↔ `DBD:220`; `verify:171` | FB-40 |
| F-40 | Chú thích S17: "chat với n người = số người khác nhau bạn đã gửi tin riêng"; "nhóm = số nhóm có gửi tin"; bộ lọc ngưỡng chỉ dùng **Mở ứng dụng** | [Nghiệp vụ] · TB | S17a | `av/ActiveUsersView.fxml:34,53-65,77-78` ↔ `DBD:222`; `verify:174-178` | FB-41 |

### Dữ liệu mẫu / chú thích

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| F-41 | Sửa mock tự mâu thuẫn (`khang.ngo`/`nguyenkhang`; "Kevin Trần"/`kevin.tran`) | [Lưu trữ] · Thấp | S06, S07, D02, D05, S16 | `uSD:69,120,129,135`; `aSD:143` ↔ `schema:73-76` | FE-23 |
| F-42 | Sửa mã UC trong comment FXML cho khớp UCS | [Luồng] · Thấp | D02, S12–S17 | `uv/ReportSpamDialog.fxml:12`; `av/*View.fxml` | FE-24 |

**F-18 và F-32 (Cao).** Đây là hai màn hình mà UI hiện đang **đi ngược trực tiếp** với DB. F-18 đổi khái niệm: không còn "nhóm thường" và "nhóm mã hóa", mọi nhóm đều E2EE. F-32 bỏ 2 trên 6 cột và 1 trên 2 hành động của S14. Đề chỉ yêu cầu S14 xem, lọc, sắp theo thời gian và tên đăng nhập, rồi khóa tài khoản (`PDF:106-113`). Phần còn lại DB đáp ứng đủ.

## Phần 2 — B: 22 mục chỉ sửa BE

### B-DB: sửa script CSDL mà không đổi thiết kế

| ID | Việc | Phân loại | Bằng chứng | Mã cũ |
|---|---|---|---|---|
| B-01 | Thêm `seed_demo.sql`: hash BCrypt thật cho mật khẩu demo công bố, tài khoản admin để đăng nhập S10, nhân vật trùng với mock (C-17); `created_at` đặt ngoài tháng 11/2026 để `verify:171` không vỡ | [Lưu trữ] · **Cao** | `seed:2` (`'fixture-only'`); `seed:44` (`demo_admin`); `DBD:243` | FB-09, FB-10, FB-43 (DB) |
| B-02 | Thêm script tạo DB: `ENCODING 'UTF8' LOCALE_PROVIDER icu ICU_LOCALE 'vi-VN' TEMPLATE template0`; `SET client_encoding='UTF8'`; collation `vi` cho ORDER BY; reset được để chạy lại | [Lưu trữ] · TB | `seed:1`; `DBD:243-248`; `verify:181-185` | BE-25, BE-28, FB-39 (collation) |
| B-03 | Sửa verify: chạy ca "bạn của bạn" **trước** các lệnh chặn (hiện direct = expanded); thêm assertion gom tháng theo giờ VN, danh sách S12/S13/S14, lọc vai trò/trạng thái | [Lưu trữ] · TB | `verify:102,121` chạy trước `:163-170`; `verify:58-61,171-173` | BE-24, FB-42 (test) |
| B-04 | Tin nhóm chỉ-ghi-thêm như tin riêng (chặn UPDATE `encrypted_payload` và DELETE); chặn DELETE trên bảng nhật ký | [Lưu trữ] · Thấp | `schema:598-600` ↔ `schema:346-349,375-377`; `DBD:206` ("giữ nguyên tin đã ghi") | BE-13 |
| B-05 | Seed "Nhóm lưu trữ" đã đóng nhưng `binh` vẫn còn membership mở và nhóm không có admin; sửa theo Q-06 | [Nghiệp vụ] · Thấp | `seed:118-125` ↔ `DBD:203` | FB-28 (seed) |
| B-06 | *(Tùy chọn)* `registration_source DEFAULT 'SELF_REGISTERED'` | [Luồng] · Thấp | `schema:17` | BE-01 |
| B-07 | *(Tùy chọn)* Trigger từ chối kết bạn, lời mời, membership khi một bên không ACTIVE; nếu không làm thì B-16 làm ở server | [Nghiệp vụ] · Thấp | `schema:227-289,440-457` | BE-06 (DB) |
| B-08 | *(Tùy chọn)* Index `pg_trgm` cho tìm chuỗi con, index `users(created_at)` | [Lưu trữ] · Thấp | `schema:38-42,171-174` | BE-10 |
| B-09 | *(Tùy chọn)* Cấm DELETE trên `private_message_hides` để "không thể hoàn tác" ở D03 đúng cả ở tầng DB | [Nghiệp vụ] · Thấp | `schema:399-401` ↔ `uc/ChatViews.java:186` | BE-08 |

### B-SV: logic server mà DB giao cho backend

| ID | Việc | Phân loại | Bằng chứng | Mã cũ |
|---|---|---|---|---|
| B-10 | **Dựng server**: module `src/server`, driver PostgreSQL, pool, BCrypt, `ServerSocket` | [Luồng] · **Cao** | `pom.xml:13-17`; `WL:274-285`; `README.md:31` | BE-26 |
| B-11 | Hợp đồng DAO: luôn READ COMMITTED; gọi `lock_social_pair` trước luồng nhiều câu lệnh; ánh xạ SQLSTATE 23505/23514 thành mã lỗi giao thức (đúng trường, đúng lý do chặn) | [Luồng] · TB | `schema:201-204,365`; `DBD:78` | BE-27, FE-11 (server) |
| B-12 | Đăng ký: tự gán `registration_source`, `system_role='USER'`, không nhận role/status từ client. Đăng nhập: chỉ ACTIVE; kiểm username đúng hoa/thường; email qua `lower()` | [Nghiệp vụ] · TB | `schema:15-22,38-42`; `DBD:73-74` | BE-01 (server), FB-13 (server) |
| B-13 | Quên mật khẩu: sinh mật khẩu ngẫu nhiên, BCrypt, gửi email; giới hạn tần suất trong bộ nhớ; chốt Q-07 | [Nghiệp vụ] · TB | `DBD:223`; `PDF:198-204` | BE-02 |
| B-14 | Mỗi lần đăng nhập `user.jar` thành công thì ghi `login_events` **và** `app_open_events` trong một giao dịch; `admin.jar` không ghi (UC-30); "dùng lại phiên" theo Q-04 | [Nghiệp vụ] · TB | `schema:89-110`; `DBD:65-66`; `UCS:437` | BE-04, FB-12 (server) |
| B-15 | Giao dịch xóa mềm: ẩn danh, đóng friendships/lời mời/membership/thiết bị E2EE; nếu là admin cuối của nhóm thì đóng nhóm | [Nghiệp vụ] · TB | `schema:44-87`; `DBD:74,203` | BE-05, FB-28 (server) |
| B-16 | Từ chối kết bạn hoặc thêm vào nhóm người LOCKED/DELETED (nếu không làm B-07) | [Nghiệp vụ] · TB | `schema:227-289,440-457` | BE-06 (server) |
| B-17 | Tin offline: client đăng nhập thì kéo lịch sử (pull), không cần `delivered_at`; realtime khi online qua socket | [Luồng] · TB | `DBD:223` ("tin offline đọc từ lịch sử") | FB-19 (server) |
| B-18 | Tìm kiếm: loại chính mình, LOCKED/DELETED và người đã chặn mình; tìm tin riêng lọc tin đã ẩn; DTO kết quả có `conversationType` + id | [Nghiệp vụ] · TB | `DBD:75-76,129`; `schema:541-545` | BE-09, BE-19 |
| B-19 | Quy tắc nhóm: tạo nhóm với ≥2 thành viên trong một giao dịch; chỉ admin thêm/xóa/cấp quyền; admin cuối phải chuyển quyền trước khi rời; kiểm quan hệ chặn khi thêm; quyền đổi tên theo Q-05 | [Nghiệp vụ] · TB | `DBD:203,211-212`; `schema:438-457` | BE-14, BE-15, BE-16, FB-30 (server) |
| B-20 | Lời mời: hai người gửi cho nhau thì chuyển thành chấp nhận; **người chặn không được gửi lời mời cho người mình chặn** (DB chỉ chặn chiều ngược lại, `schema:251-257`, nên nếu cho gửi, lời mời sẽ treo mãi vì không chấp nhận được) | [Nghiệp vụ] · TB | `schema:131-133,251-262`; `DBD:75-76` | BE-18, FB-33 (server) |
| B-21 | D02 "Báo cáo + chặn luôn": một giao dịch, chèn báo cáo **trước** khi chặn | [Luồng] · Thấp | `schema:403-419,291-317` | BE-20 |
| B-22 | **Phía server của E2EE**: lưu khóa công khai thiết bị; chỉ trả gói khóa và tin trong khoảng quyền; xoay epoch khi tập thành viên hoặc thiết bị đổi, **trước** khi cho gửi tin; khóa bản ghi nhóm khi ghi | [Luồng] · **Cao** | `DBD:200-213`; `schema:459-539` | FB-22 (server) |

## Phần 3 — C: 21 mục sửa cả FE và BE

### Mã hóa nhóm (E2EE)

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| C-01 | **Luồng E2EE đầy đủ**: client sinh cặp khóa thiết bị và lưu khóa riêng cục bộ; đăng ký khóa công khai; người tạo nhóm hoặc người xoay epoch sinh khóa nhóm và bọc cho từng thiết bị thành viên; mã hóa/giải mã tin (ví dụ AES-GCM); chốt định dạng ciphertext và gói khóa | [Lưu trữ][Luồng] · **Cao** | S05, D01, D04 | `schema:459-600`; `DBD:208-213` (còn để ngỏ) | FB-22, FB-23 |
| C-02 | **Đổi thiết bị**: mỗi tài khoản chỉ có một thiết bị được cấp quyền; đăng nhập trên máy mới thì thu hồi máy cũ, và máy mới **không đọc được tin nhóm cũ**. S01 phải cảnh báo trước khi đăng ký thiết bị mới. Đặt lại/đổi mật khẩu **không** ảnh hưởng, vì khóa riêng nằm trên thiết bị chứ không gắn với mật khẩu | [Nghiệp vụ][Luồng] · **Cao** | S01, S05 | `schema:459-471`; `DBD:198,205` ↔ UC-02 2c `UCS:263` | FB-24 |
| C-03 | **Tìm tin nhóm và LLM trong nhóm ở client**: S08 "Chỉ nhóm" tải bản mã trong khoảng quyền, giải mã rồi lọc; S05 nút AI chỉ gửi đoạn người dùng chủ động chọn và có câu cảnh báo | [Nghiệp vụ][Luồng] · **Cao** | S05, S08 | `uv/SearchMessagesView.fxml:33-42`; `uv/GroupChatView.fxml:49-52,62-65` ↔ `DBD:129,225`; `schema:546` | FB-26 |
| C-04 | Xem trước tin cuối: chat riêng loại tin đã ẩn (server lọc); nhóm thì client giải mã tin cuối; hội thoại chưa có tin xếp cuối danh sách (DB không có `private_conversations.created_at`) | [Luồng] · TB | S04, S05 | `uSD:64-70` ↔ `schema:153-159,171-180,546` | FB-20 |

### Tài khoản và kiểm tra dữ liệu

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| C-05 | Kiểm tra dữ liệu ở FE (TextFormatter, nhãn lỗi) **và** server, vì DB không ràng buộc: trim họ tên/username; định dạng email; ngày sinh không ở tương lai và DatePicker báo lỗi khi gõ sai; mật khẩu ≥8 ký tự, có chữ và số, tối đa khoảng 64; độ dài các trường theo Q-02; tin nhắn không rỗng, ≤2000 ký tự; tên nhóm ≤50 ký tự | [Nghiệp vụ] · TB | S02, S04, S05, S09, S11a, D01 | `schema:9-14,26-29,167,431`; `DateFields:33-35` ↔ `uv/RegisterView.fxml:38-78` | FB-02, FB-03, FB-06, FB-07, FB-08, BE-07, FB-32 |
| C-06 | Lỗi trùng username/email hiện dưới đúng trường: server ánh xạ `users_live_username_uidx`/`users_live_email_uidx` thành mã lỗi; FE thêm Label `.error-text` | [Luồng] · TB | S02, S09, S11a/b | `schema:38-42` ↔ `uv/RegisterView.fxml:35-79`; `theme.css:47,112` | FB-04 |
| C-07 | Chốt tập mã giới tính (Q-01), ví dụ `MALE/FEMALE/OTHER` với NULL nghĩa là không nêu; enum dùng chung; user app và admin app có cùng danh sách; DB vẫn lưu text | [Lưu trữ] · TB | S02, S09, S11a/b | `uv/RegisterView.fxml:67-70`; `av/UserFormDialog.fxml:46-54` ↔ `schema:14` | FB-05 |
| C-08 | Tài khoản LOCKED: server từ chối và ngắt kết nối khi đang online; FE có nhãn lỗi và hộp thoại "Tài khoản đã bị khóa" | [Nghiệp vụ][Luồng] · TB | S01, S10 | `uv/LoginView.fxml:16-39` ↔ `schema:16,20`; `DBD:74` | FB-13 |
| C-09 | Đăng xuất đóng socket; server đánh dấu offline và báo bạn bè | [Luồng] · Thấp | S04–S09 | `uc/MainController.java:54-57` ↔ `DBD:223` | FB-15 |
| C-10 | **Tài khoản DELETED**: FE có enum 3 trạng thái, không giả định trường danh tính luôn có giá trị (`initials()` null-safe), ẩn Sửa/Khóa/Đặt lại MK; server trả nhãn ẩn danh "Người dùng đã xóa #id" | [Nghiệp vụ] · **Cao** | S06, S11, S12, S13, S14, S15b | `ac/UsersController.java:77-78,126-142`; `aSD:17-18` ↔ `schema:20,30-34`; `seed:48,79,124-125`; `DBD:74` | FB-17 |
| C-11 | Chốt Q-03; truy vấn S11/S15–S17 lọc `system_role='USER'`; chặn tự khóa/xóa chính mình và admin cuối | [Nghiệp vụ] · TB | S10, S11, S15–S17 | `aSD:60,153` ↔ `DBD:64`; `verify:163-178` | FB-18 |
| C-12 | Server trả cờ `canReport` (đã có ít nhất một tin riêng theo bất kỳ chiều nào); FE vô hiệu mục "Báo cáo spam…" theo cờ | [Luồng] · TB | S04, S06, D02 | `uc/FriendsController.java:52-54`; `uv/ChatView.fxml:81` ↔ `schema:403-419` | FE-18 |

### Admin & thống kê

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| C-13 | Lọc Online/Offline ở S11: server lấy danh sách online trong bộ nhớ rồi truyền `user_id = ANY(?)` vào SQL | [Luồng] · TB | S11 | `av/UsersView.fxml:53-62` ↔ `DBD:223` | FB-38 |
| C-14 | Sắp xếp và phân trang làm ở server (`sortKey/sortDir/page`, `ORDER BY … COLLATE vi`, keyset cho S12); TableView không tự sắp trong trang | [Nghiệp vụ][Luồng] · TB | S11–S14, S16, S17 | `ac/UsersController.java:74-75`; `ac/GroupsController.java:49` ↔ `schema:99-100`; B-02 | FB-39 |
| C-15 | **Múi giờ Asia/Ho_Chi_Minh**: server gom tháng bằng `date_trunc('month', ts AT TIME ZONE 'Asia/Ho_Chi_Minh')` và tự đổi khoảng ngày thành `[từ 00:00 VN, đến+1 00:00 VN)`; FE định dạng mọi thời điểm theo `ZoneId.of("Asia/Ho_Chi_Minh")` | [Nghiệp vụ] · **Cao** | S04, S05, S09, S11, S12, S15–S17 | `ac/MonthlyChart.java:24-58`; `ac/LoginLogController.java:33-35` ↔ `schema:2-3`; `DBD:225`; `seed:24-26` | FB-42 |
| C-16 | "Khóa tài khoản" từ S14: server UPDATE `users` và ngắt socket; FE ẩn nút khi người bị báo cáo đã DELETED (trigger cấm DELETED→LOCKED) | [Luồng] · TB | S11, S14 | `av/SpamView.fxml` ↔ `schema:16,20,68-71`; `DBD:131` | FB-37 |

### Seed và kiến trúc

| ID | Việc | Phân loại | Màn hình | Bằng chứng | Mã cũ |
|---|---|---|---|---|---|
| C-17 | Mock UI và `seed_demo.sql` dùng cùng nhân vật, nhóm và mốc thời gian, và có đủ trường hồ sơ | [Lưu trữ] · TB | Tất cả | `uSD:64-145`; `aSD:53-160` ↔ `seed:28-125` | FB-43 |
| C-18 | Tách `server.properties` (mật khẩu DB, SMTP, API key LLM) khỏi `client.properties` (host/port); thêm vào `.gitignore` và commit bản `*.example`. Với E2EE không có master key, nhưng các bí mật khác vẫn không được đi theo `user.jar` | [Luồng] · TB | S10, toàn client | `UCS:20`; `README.md:31,47`; `.gitignore:69-71` | FB-44 |
| C-19 | Module `src/protocol` thuần Java cho DTO và message; `common` chỉ giữ phần JavaFX | [Luồng] · TB | Tất cả | `src/common/pom.xml:17-22` | FB-45 |
| C-20 | DTO mang `long id` và enum khớp CHECK (`AccountStatus`, `RequestStatus`, `GroupRole`, `Gender`); nhãn tiếng Việt chỉ map ở FE | [Lưu trữ] · TB | Tất cả | `aSD:17-40`; `ac/SpamController.java:69-78` ↔ `schema:7,19-21,449` | FB-46 |
| C-21 | Thời gian trong DTO dùng `Instant`; `birth_date` dùng `LocalDate`; helper định dạng chung đặt trong `common` | [Luồng] · TB | S04, S05, S11, S12, S15–S17 | `ac/Tables.java:17-18`; `uSD:15,65` ↔ `schema:13,18,93,106` | FB-47 |

**C-01 đến C-03 (Cao).** Đây là phần việc lớn nhất khi giữ thiết kế DB. Schema đã có đủ chỗ lưu cho E2EE, nhưng design-baseline còn để ngỏ ba điểm: ai sinh và phân phối khóa, chuyển epoch vào lúc nào, định dạng ciphertext ra sao (`DBD:208-213`). Phải viết một tài liệu thiết kế ngắn cho ba điểm này trước khi code C-01 và B-22. Có hai hệ quả người dùng sẽ thấy rõ, nên phải đưa vào UI và báo cáo: đổi máy thì mất lịch sử nhóm (C-02), và thành viên mới không thấy tin cũ (F-19).

**C-10 và C-15 (Cao).** Hai lỗi này hiện ra ngay khi nối DB, dù chỉ dùng seed hiện tại. Seed đã có tài khoản đã xóa với lịch sử đăng nhập, membership và báo cáo spam. Seed cũng đặt mốc dữ liệu đúng ranh giới tháng theo giờ Việt Nam.

## Phần 4 — T: 26 mục chỉ sửa tài liệu

Đây là các chỗ use case hoặc tài liệu đang nói khác DB. Khi lấy DB làm chuẩn thì **sửa tài liệu**, không sửa code.

| ID | Tài liệu | Sửa thành (theo DB) | Mã cũ |
|---|---|---|---|
| T-01 | BR-01 `UCS:212` | Username phân biệt hoa/thường, không giới hạn chữ thường | FB-01 |
| T-02 | BR-01, BR-02 `UCS:212-213` | "Duy nhất trong các tài khoản chưa xóa"; dùng lại được sau khi xóa mềm | BE-03 |
| T-03 | BR-05, UC-37, UC-39 `UCS:216,460,466`; `RA:46`; K6 `UCS:23` | Bỏ IP; đổi tên bảng `login_history` thành `login_events` | FB-11, FB-49 (tên bảng) |
| T-04 | M5, M9, BR-05 `UCS:33,37,216` | Mở ứng dụng được ghi ở `app_open_events`, tách khỏi đăng nhập | FB-12 |
| T-05 | BR-15 `UCS:226` | Hiển thị và báo cáo theo Asia/Ho_Chi_Minh | FB-42 |
| T-06 | UC-07 `UCS:297` | Tìm kiếm phân biệt dấu | FB-21 |
| T-07 | K4 `UCS:21`; UC-04/20/21/22/28 `UCS:281,375,385,395,422-432`; `RA:83,93`; `WL:172-173` | **E2EE theo thiết bị**; ghi `DECISION` hủy K4 | FB-22, FB-23, FB-26 |
| T-08 | UC-24, UC-28 `UCS:406,429` | Thành viên mới không đọc tin trước lúc tham gia | FB-25 |
| T-09 | UC-02 2c `UCS:263` | Đăng nhập máy khác thì máy mới không đọc được lịch sử nhóm cũ | FB-24 |
| T-10 | M15, UC-27 `UCS:43,420` | Xóa lịch sử chỉ áp dụng cho chat riêng (chờ R-01) | FB-27 |
| T-11 | M2 `UCS:30` | Admin duy nhất bị xóa thì đóng nhóm | FB-28 |
| T-12 | M20 `UCS:48` | Rời nhóm: DB hỗ trợ; ghi rõ làm hay không làm trong V2 | FB-29 |
| T-13 | BR-10, M18 `UCS:46,221,537` | Chỉ admin thêm/xóa thành viên; đổi tên theo Q-05 | FB-30 |
| T-14 | UC-26 `UCS:415` | Người bị xóa vẫn đọc được lịch sử trong khoảng đã tham gia | FB-31 |
| T-15 | UC-22, UC-23, UC-24, UC-26 `UCS:396-415` | Bỏ "người tạo" và các dòng hệ thống; tên nhóm 1–50 ký tự; sửa câu tự mâu thuẫn về tên rỗng ở UC-22 | BE-11, BE-12, FB-32 |
| T-16 | UC-09 `UCS:311`; UC-10 `UCS:316` | Rút lời mời và hủy do chặn đều là `CANCELLED`; từ chối thì giữ bản ghi `REJECTED`, không xóa | BE-17, FB-35 |
| T-17 | UC-38 `UCS:463` | Bỏ ngày kết bạn; bỏ ngày chặn | FB-34 |
| T-18 | M6, BR-11, UC-14, UC-41 `UCS:34,222-223,335-337,474` | Báo cáo không có lý do/trạng thái; cho phép báo cáo trùng; điều kiện là đã có tin theo bất kỳ chiều nào; "khóa" chỉ đổi `users` | BE-21, BE-22, FB-36 |
| T-19 | UC-35 `UCS:454` | Bỏ "lý do khóa" | FB-16 |
| T-20 | UC-15, UC-02 `UCS:258,348` | Bỏ "Đã gửi/Đã nhận" và số chưa đọc; tin offline được kéo từ lịch sử khi đăng nhập; bỏ "hoạt động lần cuối" | FB-19, FB-14 |
| T-21 | UC-42, UC-45, UC-46 `UCS:478,491` | Đăng ký mới chỉ tính tự đăng ký; định nghĩa S17 theo `DBD:222` | FB-40, FB-41 |
| T-22 | UC-30 `UCS:437`; M21 `UCS:49` | Admin chỉ tạo bằng seed/script (`INTERNAL`); không có cờ "bắt buộc đổi mật khẩu" | FB-10, BE-02 |
| T-23 | UC-31 `UCS:441-442` | Số dòng/trang và cột theo S11 hiện tại | FE-20 |
| T-24 | `UCS:532-538`; `WL:178` | Ghi `DECISION` cho M7/M12/M15 theo DB; M7 chờ giảng viên xác nhận (Q-09) | FB-48 |
| T-25 | `README.md:42,45`; `.agent/rules/rule.md:40,62,147,161`; `docs/ai/_template/feature.template.md:52` | `create_db.sql` thành `schema.sql` + `seed.sql`; sửa đường dẫn template; ghi `src/server` là "sẽ có" | FB-49 |
| T-26 | `DBD`; `WL:286-289` | Ghi các ràng buộc ẩn (username/`created_at`/nguồn bất biến, FK RESTRICT, `social_pair_is_blocked`); đưa Decision Log vào repo; chuyển DBD sang `docs/ai/database-design/` kèm plan; phân công các hạng mục V2 | BE-29, BE-30, BE-31, FB-50 |

## Những gì đã khớp

Giữ nguyên như báo cáo cũ. Cấu trúc schema khớp design-baseline (16 bảng, 25 FK, 21 CHECK, 10 trigger), và seed thỏa mọi ràng buộc. Các luồng sau đã đúng với DB, không cần làm lại:
- 4 trường bắt buộc khi đăng ký
- username không đổi được
- email duy nhất không phân biệt hoa/thường
- xóa mềm
- D03 chỉ ẩn phía mình
- hiệu ứng chặn ở D05
- các tab bạn bè và lời mời
- định nghĩa S16
- mọi số liệu S15–S17 đều tính được

Ngoài ra, **khi lấy DB làm chuẩn, verify.sql không còn "khóa cứng hành vi sai"**. Báo cáo spam trùng, tìm kiếm phân biệt dấu và `Minh` ≠ `minh` giờ đều là hành vi đúng. Mục BE-23 cũ vì vậy không còn là xung đột.

## Khoảng trống

Vẫn là phân tích tĩnh: chưa chạy lại script SQL, chưa xem prototype HTML ngoài repo, không có ảnh D04. Ba điểm E2EE mà design-baseline còn để ngỏ (`DBD:208-213`) chưa có tài liệu nào trả lời. Đó là đầu vào bắt buộc cho C-01 và B-22.

## Phụ lục — Ánh xạ mã cũ sang mã mới

| Mã cũ | Mã mới | | Mã cũ | Mã mới | | Mã cũ | Mã mới |
|---|---|---|---|---|---|---|---|
| FE-01 | F-02 | | BE-01 | B-06, B-12 | | FB-01 | F-01, T-01 |
| FE-02 | F-03, B-13 | | BE-02 | B-13, T-22 | | FB-02 | C-05 |
| FE-03 | F-04 | | BE-03 | T-02 | | FB-03 | C-05 |
| FE-04 | F-05 | | BE-04 | B-14 | | FB-04 | C-06 |
| FE-05 | F-06 | | BE-05 | B-15 | | FB-05 | C-07 |
| FE-06 | F-07 | | BE-06 | B-07, B-16 | | FB-06 | C-05 |
| FE-07 | F-08 | | BE-07 | C-05 | | FB-07 | C-05 |
| FE-08 | F-09 | | BE-08 | B-09 | | FB-08 | C-05 |
| FE-09 | F-10 | | BE-09 | B-18 | | FB-09 | B-01, F-07 |
| FE-10 | F-12 | | BE-10 | B-08 | | FB-10 | B-01, T-22 |
| FE-11 | F-13, B-11 | | BE-11 | F-20, T-15 | | FB-11 | F-34, T-03 |
| FE-12 | F-14 | | BE-12 | F-21, T-15 | | FB-12 | F-35, B-14, T-04 |
| FE-13 | F-15 | | BE-13 | B-04 | | FB-13 | C-08, B-12 |
| FE-14 | F-16 | | BE-14 | B-19 | | FB-14 | F-11, T-20 |
| FE-15 | F-22 | | BE-15 | B-19 | | FB-15 | C-09 |
| FE-16 | F-23 | | BE-16 | B-19 | | FB-16 | T-19 |
| FE-17 | F-27 | | BE-17 | F-30, T-16 | | FB-17 | C-10 |
| FE-18 | C-12 | | BE-18 | B-20 | | FB-18 | C-11 |
| FE-19 | F-33 | | BE-19 | B-18 | | FB-19 | F-17, B-17, T-20 |
| FE-20 | F-36, T-23 | | BE-20 | B-21 | | FB-20 | C-04 |
| FE-21 | F-37, F-32 | | BE-21 | T-18 | | FB-21 | F-26, T-06 |
| FE-22 | F-38 | | BE-22 | T-18 | | FB-22 | C-01, F-18, B-22, T-07 |
| FE-23 | F-41 | | BE-23 | *hết xung đột* | | FB-23 | F-18, C-01 |
| FE-24 | F-42 | | BE-24 | B-03 | | FB-24 | C-02, T-09 |
| | | | BE-25 | B-02 | | FB-25 | F-19, T-08 |
| | | | BE-26 | B-10 | | FB-26 | C-03, T-07 |
| | | | BE-27 | B-11 | | FB-27 | T-10, R-01 |
| | | | BE-28 | B-02 | | FB-28 | F-24, B-05, B-15, T-11 |
| | | | BE-29 | T-26 | | FB-29 | T-12 |
| | | | BE-30 | T-26 | | FB-30 | F-22, B-19, T-13 |
| | | | BE-31 | T-26 | | FB-31 | F-25, T-14 |
| | | | | | | FB-32 | C-05, T-15 |
| | | | | | | FB-33 | F-28, B-20 |
| | | | | | | FB-34 | F-29, T-17 |
| | | | | | | FB-35 | T-16 |
| | | | | | | FB-36 | F-31, F-32, T-18 |
| | | | | | | FB-37 | C-16 |
| | | | | | | FB-38 | C-13 |
| | | | | | | FB-39 | C-14, B-02 |
| | | | | | | FB-40 | F-39, T-21 |
| | | | | | | FB-41 | F-40, T-21 |
| | | | | | | FB-42 | C-15, B-03, T-05 |
| | | | | | | FB-43 | C-17, B-01 |
| | | | | | | FB-44 | C-18 |
| | | | | | | FB-45 | C-19 |
| | | | | | | FB-46 | C-20 |
| | | | | | | FB-47 | C-21 |
| | | | | | | FB-48 | T-24 |
| | | | | | | FB-49 | T-25, T-03 |
| | | | | | | FB-50 | T-26 |
