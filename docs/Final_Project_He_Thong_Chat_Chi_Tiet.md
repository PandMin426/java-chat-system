# ĐỒ ÁN CUỐI KỲ — HỆ THỐNG CHAT

> **Môn học:** Lập trình ứng dụng Java  
> **Đơn vị:** Bộ môn Công nghệ phần mềm – Khoa Công nghệ thông tin  
> **Nguồn:** `Final Project.pdf` (5 trang)  
> **Mục đích tài liệu:** Chuyển toàn bộ nội dung đề bài PDF sang Markdown có cấu trúc rõ ràng, đầy đủ và dễ đối chiếu khi triển khai.

---

## Hướng dẫn đọc tài liệu

- **Phần 1–5**: Nội dung yêu cầu của đề bài, được sắp xếp và trình bày lại; các mã `ADM-*`, `USR-*` chỉ là **mã tham chiếu thêm để tiện quản lý**, không phải mã do giảng viên quy định.
- **Phần 6**: Checklist tổng hợp từ các yêu cầu gốc, dùng để theo dõi tiến độ và rà soát khi nộp bài.
- **Phần 7**: Những điểm đề bài **chưa mô tả cụ thể**. Đây không phải chức năng hoặc quy tắc bắt buộc mới.
- Các tên chức năng và điều kiện trọng yếu được giữ sát với tài liệu gốc. Lỗi xuống dòng được chuẩn hóa để dễ đọc.
- Tên các công nghệ, giải pháp, cấu trúc cơ sở dữ liệu cụ thể **không được bổ sung thành yêu cầu bắt buộc** nếu PDF không nêu.

## Mục lục

1. [Tổng quan hệ thống](#1-tổng-quan-hệ-thống)
2. [Phân hệ dành cho người quản trị](#2-phân-hệ-dành-cho-người-quản-trị)
3. [Phân hệ dành cho người sử dụng](#3-phân-hệ-dành-cho-người-sử-dụng)
4. [Yêu cầu chung và các lưu ý về điểm số](#4-yêu-cầu-chung-và-các-lưu-ý-về-điểm-số)
5. [Các phiên bản bàn giao (Deadlines)](#5-các-phiên-bản-bàn-giao-deadlines)
6. [Checklist triển khai và nộp bài](#6-checklist-triển-khai-và-nộp-bài)
7. [Những điểm đề bài chưa quy định rõ](#7-những-điểm-đề-bài-chưa-quy-định-rõ)
8. [Bảng đối chiếu với PDF gốc](#8-bảng-đối-chiếu-với-pdf-gốc)

---

# 1. Tổng quan hệ thống

**Nguồn: Trang 1–2 của PDF.**

Đề tài của đồ án cuối kỳ môn **Lập trình ứng dụng Java** là xây dựng **Hệ thống chat**.

Hệ thống gồm **hai phân hệ**:

1. **Phân hệ dành cho người quản trị**: Quản lý người dùng, đăng nhập, nhóm chat, báo cáo spam và xem các thống kê/biểu đồ về người dùng.
2. **Phân hệ dành cho người sử dụng**: Đăng ký và quản lý tài khoản, quản lý bạn bè, nhắn tin, tìm kiếm, báo cáo spam, hỗ trợ LLM và quản lý nhóm chat.

Cả **hai phân hệ** đều thuộc phạm vi đồ án và đều phải được nộp mã nguồn.

## 1.1. Phạm vi chức năng theo đề

| Phân hệ | Số nhóm chức năng chính được liệt kê | Nội dung |
| --- | ---: | --- |
| Người quản trị | 9 | Quản lý người dùng; lịch sử đăng nhập; nhóm chat; báo cáo spam; người dùng mới; biểu đồ đăng ký; số lượng bạn bè; người dùng hoạt động; biểu đồ hoạt động. |
| Người sử dụng | 12 | Đăng ký; cập nhật tài khoản; khởi tạo lại mật khẩu; đổi mật khẩu; đăng nhập; bạn bè; lời mời kết bạn; bạn bè online; tìm người; báo cáo spam; chat; nhóm chat. |

> **Lưu ý:** Con số 9 và 12 là số nhóm chức năng đánh số trong tài liệu gốc; mỗi nhóm có thể chứa nhiều yêu cầu nhỏ.

---

# 2. Phân hệ dành cho người quản trị

**Nguồn: Trang 2 của PDF.**

## 2.1. `ADM-01` — Quản lý danh sách người dùng

### Thông tin người dùng cần quản lý

- Tên đăng nhập.
- Họ tên.
- Địa chỉ.
- Ngày sinh.
- Giới tính.
- Email.

### Chức năng yêu cầu

- [ ] **Xem danh sách người dùng.**
  - [ ] Lọc theo **tên**.
  - [ ] Lọc theo **tên đăng nhập**.
  - [ ] Lọc theo **trạng thái**.
  - [ ] Sắp xếp theo **tên**.
  - [ ] Sắp xếp theo **ngày tạo**.
- [ ] **Thêm** người dùng.
- [ ] **Cập nhật** thông tin người dùng.
- [ ] **Xóa** người dùng.
- [ ] **Khóa** tài khoản người dùng.
- [ ] **Mở khóa** tài khoản người dùng.
- [ ] **Cập nhật mật khẩu** người dùng.
- [ ] **Xem lịch sử đăng nhập** của người dùng.
- [ ] **Xem danh sách bạn bè** của người dùng.

**Ghi chú bám sát đề:** PDF liệt kê thao tác khóa/mở khóa và trường lọc trạng thái nhưng không đưa ra danh mục đầy đủ các trạng thái tài khoản.

## 2.2. `ADM-02` — Xem danh sách đăng nhập theo thời gian

- [ ] Xem danh sách các lần đăng nhập.
- [ ] Hiển thị danh sách theo **thứ tự thời gian**.
- [ ] Hiển thị **thời gian** của lần đăng nhập.
- [ ] Hiển thị **tên đăng nhập**.
- [ ] Hiển thị **họ tên**.

## 2.3. `ADM-03` — Xem danh sách các nhóm chat

- [ ] Xem danh sách các nhóm chat.
- [ ] Sắp xếp danh sách theo **tên nhóm**.
- [ ] Sắp xếp danh sách theo **thời gian tạo**.
- [ ] Lọc theo **tên nhóm**.
- [ ] Xem **danh sách thành viên** của một nhóm.
- [ ] Xem **danh sách admin** của một nhóm.

## 2.4. `ADM-04` — Xem danh sách báo cáo spam

- [ ] Xem danh sách các báo cáo spam.
- [ ] Sắp xếp theo **thời gian**.
- [ ] Sắp xếp theo **tên đăng nhập**.
- [ ] Lọc theo **thời gian**.
- [ ] Lọc theo **tên đăng nhập**.
- [ ] **Khóa tài khoản người dùng** từ chức năng quản lý báo cáo spam.

## 2.5. `ADM-05` — Xem danh sách người dùng đăng ký mới

- [ ] Cho phép **chọn khoảng thời gian**.
- [ ] Hiển thị danh sách **người dùng đăng ký mới** trong khoảng thời gian được chọn.
- [ ] Sắp xếp danh sách theo **tên**.
- [ ] Sắp xếp danh sách theo **thời gian tạo**.
- [ ] Lọc danh sách theo **tên**.

## 2.6. `ADM-06` — Biểu đồ số lượng người đăng ký mới theo năm

- [ ] Cho phép **chọn năm**.
- [ ] Hiển thị biểu đồ số lượng người đăng ký mới trong năm đã chọn.
- [ ] **Trục hoành (X)** biểu diễn **tháng**.
- [ ] **Trục tung (Y)** biểu diễn **số lượng người đăng ký mới**.

## 2.7. `ADM-07` — Thống kê số lượng bạn bè của người dùng

### Dữ liệu cần hiển thị

- [ ] Danh sách người dùng.
- [ ] Một cột thể hiện **số lượng bạn bè trực tiếp**.
- [ ] Một cột thể hiện **số lượng tính luôn bạn của bạn** (giữ nguyên cách diễn đạt của đề gốc).

### Lọc và sắp xếp

- [ ] Sắp xếp theo **tên**.
- [ ] Sắp xếp theo **thời gian tạo**.
- [ ] Lọc theo **tên**.
- [ ] Lọc số lượng **bạn bè trực tiếp** theo một số do người quản trị nhập:
  - [ ] **Bằng** số được nhập.
  - [ ] **Nhỏ hơn** số được nhập.
  - [ ] **Lớn hơn** số được nhập.

> **Điểm cần làm rõ:** Đề chưa định nghĩa chính xác cách đếm “bạn của bạn” (ví dụ có loại bỏ trùng lặp hay không). Không tự coi một cách tính là quy định gốc.

## 2.8. `ADM-08` — Xem danh sách người dùng hoạt động

### Chọn dữ liệu

- [ ] Cho phép **chọn khoảng thời gian**.
- [ ] Hiển thị danh sách người dùng **có hoạt động** trong khoảng thời gian đã chọn.

### Các số liệu hoạt động cần có

- [ ] Số liệu về việc **mở ứng dụng**.
- [ ] Số liệu **chat với bao nhiêu người**.
- [ ] Số liệu **chat bao nhiêu nhóm**.

### Lọc và sắp xếp

- [ ] Sắp xếp theo **tên**.
- [ ] Sắp xếp theo **thời gian tạo**.
- [ ] Lọc theo **tên**.
- [ ] Lọc theo **số lượng hoạt động**, với một số do người quản trị nhập:
  - [ ] **Bằng** số được nhập.
  - [ ] **Nhỏ hơn** số được nhập.
  - [ ] **Lớn hơn** số được nhập.

> **Điểm cần làm rõ:** Đề nêu “số lượng hoạt động” nhưng chưa định nghĩa đây là tổng số lần mở ứng dụng, số lần chat hay một chỉ số kết hợp.

## 2.9. `ADM-09` — Biểu đồ số lượng người hoạt động theo năm

- [ ] Cho phép **chọn năm**.
- [ ] Hiển thị biểu đồ số lượng người hoạt động theo năm đã chọn.
- [ ] **Trục hoành (X)** biểu diễn **tháng**.
- [ ] **Trục tung (Y)** biểu diễn **số lượng người có mở ứng dụng**.

---

# 3. Phân hệ dành cho người sử dụng

**Nguồn: Trang 3 của PDF.**

## 3.1. `USR-01` — Đăng ký tài khoản

- [ ] Người dùng có thể **đăng ký tài khoản**.

**Ghi chú:** Các trường bắt buộc của màn hình đăng ký, điều kiện kiểm tra dữ liệu và bước xác thực tài khoản không được PDF quy định riêng.

## 3.2. `USR-02` — Cập nhật thông tin tài khoản

- [ ] Người dùng có thể **cập nhật thông tin tài khoản** của mình.

## 3.3. `USR-03` — Khởi tạo lại mật khẩu

- [ ] Người dùng có thể yêu cầu **khởi tạo lại mật khẩu**.
- [ ] Mật khẩu mới được **tạo ngẫu nhiên (random)**.
- [ ] Mật khẩu được **gửi đến email** của người dùng.

> **Yêu cầu cụ thể từ PDF:** Mật khẩu được random và gửi tới email. Không thay yêu cầu này bằng quy trình khác rồi coi là tương đương nếu chưa được giảng viên chấp thuận.

## 3.4. `USR-04` — Cập nhật mật khẩu

- [ ] Người dùng có thể **cập nhật mật khẩu**.

## 3.5. `USR-05` — Đăng nhập

- [ ] Người dùng có thể **đăng nhập** vào ứng dụng.

## 3.6. `USR-06` — Danh sách bạn bè

### Hiển thị và tìm kiếm

- [ ] Hiển thị **danh sách bạn bè**.
- [ ] Cho phép **lọc theo tên**.
- [ ] Hiển thị trạng thái **online/offline** của bạn bè.

### Kết bạn và hủy kết bạn

- [ ] **Tìm người theo tên** để gửi yêu cầu kết bạn.
- [ ] **Gửi yêu cầu kết bạn**.
- [ ] **Hủy kết bạn**.

### Chặn tài khoản

- [ ] **Block** tài khoản người khác.
- [ ] Khi block, thực hiện **hủy kết bạn** với người đó.
- [ ] Người đã bị block **không thể gửi yêu cầu kết bạn lại** cho người chặn.

## 3.7. `USR-07` — Danh sách yêu cầu kết bạn

- [ ] Hiển thị **danh sách yêu cầu kết bạn**.
- [ ] Cho phép **lọc theo tên**.
- [ ] **Đồng ý** yêu cầu kết bạn.
- [ ] **Từ chối** yêu cầu kết bạn.

## 3.8. `USR-08` — Danh sách bạn bè đang online

- [ ] Hiển thị **danh sách bạn bè đang online**.
- [ ] Cho phép **lọc theo tên**.
- [ ] Có thể **chat** với bạn bè đang online.
- [ ] Có thể **tạo group** từ danh sách này.

## 3.9. `USR-09` — Tìm kiếm người dùng

- [ ] Tìm người bằng **tên đăng nhập**.
- [ ] Tìm người bằng **tên**.
- [ ] **Không hiển thị** những người đã **block mình** trong kết quả tìm kiếm.
- [ ] Sau khi tìm thấy người dùng, có thể **chat**.
- [ ] Sau khi tìm thấy người dùng, có thể **tạo group**.

## 3.10. `USR-10` — Báo cáo spam

- [ ] Có thể **báo cáo spam** đối với một người **đã chat với mình**, khi người dùng không thích các tin nhắn/cuộc trò chuyện đó.

**Ghi chú:** PDF không mô tả biểu mẫu báo cáo, danh sách lý do hay cơ chế xử lý sau khi báo cáo.

## 3.11. `USR-11` — Chat

### A. Gửi và nhận tin nhắn

- [ ] Khi người nhận **đang online**, có thể thấy **phản hồi thời gian thực**.
- [ ] Khi người nhận **đang offline**, vẫn có thể **gửi tin nhắn** để họ xem sau.

### B. Lịch sử chat

- [ ] **Xem lịch sử chat**.
- [ ] **Xóa toàn bộ lịch sử chat**.
- [ ] **Xóa một dòng tin nhắn** trong lịch sử chat.
- [ ] **Xóa một vài dòng tin nhắn** trong lịch sử chat.

### C. Tìm kiếm trong lịch sử chat

- [ ] **Tìm kiếm một chuỗi** trong lịch sử chat **với một người cụ thể**.
- [ ] Có thể **di chuyển đến đúng đoạn chat** chứa kết quả vừa tìm trong lịch sử chat với một người.
- [ ] **Tìm kiếm một chuỗi** trong lịch sử chat **với tất cả mọi người**.
- [ ] Có thể **di chuyển đến đoạn chat** tương ứng với kết quả tìm kiếm trên toàn bộ lịch sử.

### D. Hỗ trợ từ LLM

- [ ] Có chức năng **gọi LLM** để **chỉnh nội dung chat** cho người dùng.
- [ ] Hoặc có chức năng **gợi ý nội dung chat** cho người dùng.

> **Nguyên văn ý (h) của PDF:** “Gọi LLM để chỉnh hoặc gợi ý chat cho người dùng.” Từ **“hoặc”** được giữ đúng như đề; không tự biến thành yêu cầu phải triển khai cả hai chế độ.

## 3.12. `USR-12` — Nhóm chat

### A. Tạo và đổi tên nhóm

- [ ] **Tạo nhóm chat**.
- [ ] Khi tạo nhóm, cho phép thêm **tối thiểu một tên đăng nhập**.
- [ ] **Đổi tên nhóm chat**.

### B. Quản lý thành viên và quyền quản trị nhóm

- [ ] **Thêm thành viên** vào nhóm.
- [ ] **Gán quyền admin nhóm** cho thành viên.
- [ ] **Xóa thành viên** khỏi nhóm.
- [ ] Đảm bảo **chỉ admin nhóm** có quyền xóa thành viên.

### C. Chat nhóm và mã hóa

- [ ] **Chat** trong nhóm.
- [ ] **Mã hóa nhóm chat**; đề yêu cầu **tham khảo tính năng nhóm chat được mã hóa của Facebook**.

> **Điểm cần làm rõ:** PDF không chỉ định thuật toán mã hóa, cách trao đổi khóa, mô hình phân quyền khóa hay tiêu chí kỹ thuật để đánh giá tính năng mã hóa.

---

# 4. Yêu cầu chung và các lưu ý về điểm số

**Nguồn: Trang 4 của PDF.**

## 4.1. Quản lý mã nguồn bằng Git

- [ ] Nhóm sinh viên **phải sử dụng Git** để quản lý mã nguồn.
- [ ] **Mỗi thành viên** phải có **commit** trên Git.

**Quy định điểm:** Thành viên **không có commit sẽ bị 0 điểm**.

## 4.2. Nộp toàn bộ mã nguồn

- [ ] Nộp **tất cả mã nguồn** của **phân hệ người quản trị**.
- [ ] Nộp **tất cả mã nguồn** của **phân hệ người sử dụng**.

## 4.3. Nộp script cơ sở dữ liệu

- [ ] Nộp **script tạo cơ sở dữ liệu**.

## 4.4. Cấu trúc tập tin nén

- [ ] Chuẩn bị **tập tin nén** đúng các thư mục và thành phần nộp bài tương ứng với từng phiên bản.

**Quy định điểm:** **Cấu trúc tập tin nén không đúng sẽ bị 0 điểm.**

## 4.5. Tập tin báo cáo

- [ ] Nộp **tập tin báo cáo** có **đủ các nội dung** quy định cho phiên bản tương ứng.

**Quy định điểm:** **Tập tin báo cáo không đủ nội dung theo yêu cầu sẽ bị 0 điểm.**

## 4.6. Bảng tổng hợp các điều kiện có nguy cơ bị 0 điểm

| Điều kiện theo đề gốc | Hậu quả ghi trong đề |
| --- | --- |
| Thành viên không có commit Git | Thành viên đó **0 điểm**. |
| Cấu trúc tập tin nén không đúng | **0 điểm**. |
| Tập tin báo cáo không đủ nội dung yêu cầu | **0 điểm**. |
| Phiên bản 2 thiếu báo cáo tự đánh giá theo mẫu | **0 điểm**. |

---

# 5. Các phiên bản bàn giao (Deadlines)

**Nguồn: Trang 4–5 của PDF.**

Tài liệu chia việc bàn giao thành **hai phiên bản**:

| Phiên bản | Tỷ trọng ghi trong đề | Phạm vi |
| --- | ---: | --- |
| **Phiên bản 1** | **20%** | Giao diện và cơ sở dữ liệu. |
| **Phiên bản 2** | **80%** | Toàn bộ hệ thống. |

> PDF chỉ ghi tên phiên bản và tỷ trọng 20%/80%, **không nêu ngày tháng cụ thể** để nộp.

## 5.1. Phiên bản 1 — 20%

### 5.1.1. Phạm vi bàn giao

**Giao diện và cơ sở dữ liệu**.

- **Chưa cần lập trình sự kiện** cho các màn hình.
- Phải có **giao diện các màn hình của cả hai phân hệ**.
- Phải có **script tạo cơ sở dữ liệu**.

### 5.1.2. Các thành phần trong tập tin nén

#### Thư mục `src`

- [ ] Chứa **mã nguồn các màn hình của phân hệ người quản trị**.
- [ ] Chứa **mã nguồn các màn hình của phân hệ người sử dụng**.
- [ ] Các màn hình mới **chỉ cần giao diện**, **chưa cần lập trình sự kiện**.

#### Thư mục `script`

- [ ] Chứa **script tạo cơ sở dữ liệu**.

#### Thư mục `git`

- [ ] Chứa **hình ảnh các commit của từng thành viên**.

#### Tập tin báo cáo

Báo cáo **phải gồm đầy đủ**:

- [ ] **Thông tin nhóm**.
- [ ] **Danh sách công việc từng thành viên**.
- [ ] **Bảng đóng góp từng thành viên**, tổng mức đóng góp **bằng 100**.
- [ ] **Thiết kế cơ sở dữ liệu của hệ thống**.
- [ ] **Danh sách các màn hình đã thiết kế**, **có hình chụp**.

### 5.1.3. Sơ đồ thành phần nộp — minh họa từ yêu cầu

```text
<tap-tin-nen-phien-ban-1>/
├── src/                 # Mã nguồn giao diện của cả hai phân hệ
├── script/              # Script tạo cơ sở dữ liệu
├── git/                 # Ảnh commit của từng thành viên
└── <tap-tin-bao-cao>    # Báo cáo đủ 5 nội dung được liệt kê
```

**Quan trọng:** Đây chỉ là **cách trực quan hóa các thành phần được yêu cầu**. Đề không quy định tên tập tin nén, tên tập tin báo cáo, định dạng báo cáo hay tên thư mục con cụ thể.

## 5.2. Phiên bản 2 — 80%

### 5.2.1. Phạm vi bàn giao

**Toàn bộ hệ thống**.

- Mã nguồn phải **chạy được** ở cả **hai phân hệ**.
- Phải có các tập tin JAR dùng để chạy các phân hệ.
- Phải có tập tin cấu hình thông tin kết nối cơ sở dữ liệu.
- Phải nộp script cơ sở dữ liệu, ảnh commit Git và các tài liệu báo cáo cần thiết.

### 5.2.2. Các thành phần trong tập tin nén

#### Thư mục `src`

- [ ] Chứa **mã nguồn chạy được của phân hệ người quản trị**.
- [ ] Chứa **mã nguồn chạy được của phân hệ người sử dụng**.

#### Thư mục `release`

- [ ] Chứa **ít nhất hai tập tin `.jar`**:
  - [ ] Một tập tin JAR cho **phân hệ quản lý**.
  - [ ] Một tập tin JAR cho **phân hệ người dùng**.
- [ ] Chứa **ít nhất một tập tin cấu hình** theo yêu cầu nêu trong đề:
  - [ ] Tập tin cấu hình **lưu thông tin kết nối cơ sở dữ liệu**.
  - [ ] **Chỉ cần sửa thông tin trong tập tin cấu hình** là có thể **chạy được JAR**.

#### Thư mục `script`

- [ ] Chứa **script tạo cơ sở dữ liệu**.

#### Thư mục `git`

- [ ] Chứa **hình ảnh các commit của từng thành viên**.

#### Tập tin báo cáo

Báo cáo **phải gồm đầy đủ**:

- [ ] **Thông tin nhóm**.
- [ ] **Danh sách công việc từng thành viên**.
- [ ] **Bảng đóng góp từng thành viên**, tổng mức đóng góp **bằng 100**.
- [ ] **Các chức năng và kỹ thuật nhóm tự đánh giá là hay, nổi bật hoặc làm thêm ngoài yêu cầu**.
- [ ] **Thiết kế của hệ thống**.
- [ ] **Thiết kế cơ sở dữ liệu của hệ thống**.
- [ ] **Hướng dẫn sử dụng**, **có hình ảnh**.
- [ ] **Link YouTube demo chức năng**.
- [ ] **Link GitHub** (khi cần, giảng viên sẽ yêu cầu xem).

#### Báo cáo tự đánh giá

- [ ] Nộp **báo cáo tự đánh giá theo mẫu**.

**Quy định điểm:** **Không có báo cáo tự đánh giá theo mẫu sẽ bị 0 điểm.**

### 5.2.3. Sơ đồ thành phần nộp — minh họa từ yêu cầu

```text
<tap-tin-nen-phien-ban-2>/
├── src/                         # Mã nguồn chạy được của cả hai phân hệ
├── release/
│   ├── <quan-ly>.jar            # JAR phân hệ quản lý
│   ├── <nguoi-dung>.jar         # JAR phân hệ người dùng
│   └── <tap-tin-cau-hinh>       # Thông tin kết nối cơ sở dữ liệu
├── script/                      # Script tạo cơ sở dữ liệu
├── git/                         # Ảnh commit của từng thành viên
├── <tap-tin-bao-cao>            # Báo cáo đủ 9 nội dung được liệt kê
└── <bao-cao-tu-danh-gia>        # Báo cáo tự đánh giá theo mẫu
```

**Quan trọng:** Tên tập tin và cách bố trí của sơ đồ trên là **minh họa**, không phải tên được PDF ấn định. Tài liệu gốc không cung cấp mẫu báo cáo tự đánh giá.

---

# 6. Checklist triển khai và nộp bài

> Phần này **tổng hợp lại yêu cầu gốc để theo dõi công việc**; không thay thế các chi tiết ở Phần 2–5.

## 6.1. Checklist chức năng phân hệ người quản trị

- [ ] `ADM-01` — Quản lý người dùng: danh sách, lọc/sắp xếp, thêm/sửa/xóa, khóa/mở khóa, cập nhật mật khẩu, lịch sử đăng nhập, bạn bè.
- [ ] `ADM-02` — Danh sách đăng nhập: thứ tự thời gian; thời gian, tên đăng nhập, họ tên.
- [ ] `ADM-03` — Danh sách nhóm: lọc/sắp xếp, thành viên và admin nhóm.
- [ ] `ADM-04` — Báo cáo spam: lọc/sắp xếp và khóa tài khoản.
- [ ] `ADM-05` — Người dùng đăng ký mới: khoảng thời gian, lọc, sắp xếp.
- [ ] `ADM-06` — Biểu đồ người đăng ký mới: chọn năm, tháng và số lượng.
- [ ] `ADM-07` — Thống kê bạn bè: trực tiếp, bạn của bạn; lọc/sắp xếp.
- [ ] `ADM-08` — Người dùng hoạt động: khoảng thời gian, mở ứng dụng, số người chat, số nhóm chat, lọc/sắp xếp.
- [ ] `ADM-09` — Biểu đồ người dùng hoạt động: chọn năm, tháng và số người mở ứng dụng.

## 6.2. Checklist chức năng phân hệ người sử dụng

- [ ] `USR-01` — Đăng ký tài khoản.
- [ ] `USR-02` — Cập nhật thông tin tài khoản.
- [ ] `USR-03` — Khởi tạo lại mật khẩu ngẫu nhiên và gửi email.
- [ ] `USR-04` — Cập nhật mật khẩu.
- [ ] `USR-05` — Đăng nhập.
- [ ] `USR-06` — Quản lý bạn bè, online/offline, lời mời, hủy kết bạn, block.
- [ ] `USR-07` — Danh sách lời mời kết bạn, lọc, đồng ý/từ chối.
- [ ] `USR-08` — Bạn bè online, lọc, chat và tạo group.
- [ ] `USR-09` — Tìm người theo tên/tên đăng nhập, ẩn người đã block mình, chat/tạo group.
- [ ] `USR-10` — Báo cáo spam khi đã chat.
- [ ] `USR-11` — Chat thời gian thực/offline, lịch sử, xóa, tìm kiếm và hỗ trợ LLM.
- [ ] `USR-12` — Tạo/quản lý nhóm, phân quyền admin, chat nhóm và mã hóa nhóm.

## 6.3. Checklist trước khi nộp phiên bản 1 (20%)

- [ ] Có giao diện các màn hình thuộc **hai phân hệ** trong `src`.
- [ ] Có script tạo cơ sở dữ liệu trong `script`.
- [ ] Có ảnh commit của **từng thành viên** trong `git`.
- [ ] Có thông tin nhóm trong báo cáo.
- [ ] Có danh sách công việc của từng thành viên.
- [ ] Có bảng đóng góp với **tổng bằng 100**.
- [ ] Có thiết kế cơ sở dữ liệu trong báo cáo.
- [ ] Có danh sách màn hình **kèm hình chụp**.
- [ ] Kiểm tra cấu trúc tập tin nén.
- [ ] Kiểm tra **từng thành viên đều có commit Git**.

## 6.4. Checklist trước khi nộp phiên bản 2 (80%)

- [ ] Có mã nguồn **chạy được** của **hai phân hệ** trong `src`.
- [ ] Có **ít nhất hai JAR** tương ứng **quản lý** và **người dùng** trong `release`.
- [ ] Có tập tin cấu hình **kết nối cơ sở dữ liệu** trong `release`.
- [ ] Bảo đảm có thể **chỉnh cấu hình** để chạy JAR theo yêu cầu.
- [ ] Có script tạo cơ sở dữ liệu trong `script`.
- [ ] Có ảnh commit của **từng thành viên** trong `git`.
- [ ] Báo cáo có thông tin nhóm.
- [ ] Báo cáo có công việc từng thành viên.
- [ ] Báo cáo có bảng đóng góp tổng **bằng 100**.
- [ ] Báo cáo có mục trình bày **các chức năng và kỹ thuật nhóm tự đánh giá là hay, nổi bật hoặc làm thêm ngoài yêu cầu** (mục bắt buộc trong danh sách nội dung báo cáo).
- [ ] Báo cáo có thiết kế hệ thống.
- [ ] Báo cáo có thiết kế cơ sở dữ liệu.
- [ ] Báo cáo có hướng dẫn sử dụng **kèm hình**.
- [ ] Báo cáo có **link YouTube demo**.
- [ ] Báo cáo có **link GitHub**.
- [ ] Có **báo cáo tự đánh giá theo mẫu**.
- [ ] Kiểm tra cấu trúc tập tin nén.
- [ ] Kiểm tra **từng thành viên đều có commit Git**.

## 6.5. Các trường hợp cần đặc biệt tránh

- [ ] Xác minh **không có thành viên nào thiếu commit**.
- [ ] Xác minh tập tin nén **không sai cấu trúc** so với thành phần yêu cầu.
- [ ] Xác minh báo cáo **không thiếu nội dung bắt buộc**.
- [ ] Xác minh phiên bản 2 **có báo cáo tự đánh giá theo mẫu**.

---

# 7. Những điểm đề bài chưa quy định rõ

> Đây là danh sách **điểm chưa được PDF nói cụ thể**, để nhóm có thể hỏi giảng viên hoặc tự xác định thiết kế triển khai. **Không phải yêu cầu được bổ sung vào đề bài.**

| Chủ đề | Điều PDF đã nêu | Điều PDF chưa nêu chi tiết |
| --- | --- | --- |
| Công nghệ triển khai | Môn Lập trình ứng dụng Java, cần nộp JAR cho hai phân hệ. | Chưa chỉ định Swing, JavaFX, framework máy chủ, giao thức mạng hay kiến trúc ứng dụng. |
| Cơ sở dữ liệu | Cần script tạo cơ sở dữ liệu và tập tin cấu hình kết nối. | Chưa chỉ định hệ quản trị cơ sở dữ liệu hay thiết kế bảng/cột cụ thể. |
| Đăng ký, đăng nhập | Có đăng ký và đăng nhập; quản trị viên xem lịch sử đăng nhập. | Chưa quy định quy tắc xác thực, trường bắt buộc khi đăng ký hoặc cơ chế lưu phiên đăng nhập. |
| Trạng thái tài khoản | Quản trị viên được khóa/mở khóa, lọc theo trạng thái. | Chưa định nghĩa đầy đủ trạng thái và các chuyển trạng thái. |
| Block | Khi block thì hủy kết bạn; bên bị block không thể gửi lại lời mời; người tìm kiếm không thấy người đã block mình. | Chưa mô tả tất cả tác động khác của việc block lên chat cũ, chat mới hay nhóm chung. |
| Chat online/offline | Chat trực tiếp thời gian thực khi online; gửi và xem sau khi offline. | Chưa nêu giao thức, mức bảo đảm gửi/nhận, cơ chế thông báo hay dữ liệu đính kèm. |
| Xóa lịch sử | Có xóa toàn bộ hoặc một/vài dòng. | Chưa nêu xóa cho một phía hay cho cả hai phía. |
| Thống kê “bạn của bạn” | Phải có cột bạn bè trực tiếp và cột tính luôn bạn của bạn. | Chưa quy định thuật toán đếm, có loại trùng hay tính chính tài khoản gốc hay không. |
| “Số lượng hoạt động” | Có dữ liệu mở ứng dụng, số người chat, số nhóm chat; lọc bằng/nhỏ/lớn. | Chưa xác định chỉ số nào dùng để lọc “số lượng hoạt động”. |
| LLM | Gọi LLM để chỉnh **hoặc** gợi ý chat. | Chưa nêu nhà cung cấp, mô hình, API hay tiêu chí kiểm thử. |
| Mã hóa nhóm | Có yêu cầu mã hóa nhóm, tham khảo Facebook. | Chưa nêu mô hình mã hóa hay tiêu chí đạt. |
| Ngày nộp bài | Có phiên bản 1 (20%) và phiên bản 2 (80%). | Chưa có ngày/giờ nộp cụ thể trong PDF. |
| Tập tin nén và báo cáo | Có danh sách các thư mục và nội dung bắt buộc. | Chưa nêu tên file nén, định dạng báo cáo hoặc mẫu cấu trúc thư mục chi tiết. |
| Báo cáo tự đánh giá | Phiên bản 2 phải có báo cáo theo mẫu, nếu không có bị 0 điểm. | Mẫu tự đánh giá không được đính kèm trong PDF này. |

---

# 8. Bảng đối chiếu với PDF gốc

| Nội dung | Trang PDF | Phần Markdown tương ứng |
| --- | --- | --- |
| Trang bìa: Lập trình ứng dụng Java, Đồ án cuối kỳ, Hệ thống chat | Trang 1 | Tiêu đề, thông tin đầu tài liệu, phần 1 |
| Mô tả hệ thống và 9 nhóm chức năng quản trị | Trang 2 | Phần 1 và phần 2 |
| 12 nhóm chức năng người sử dụng | Trang 3 | Phần 3 |
| Yêu cầu chung và quy định 0 điểm | Trang 4 | Phần 4 |
| Phiên bản 1 — 20% | Trang 4 | Phần 5.1 |
| Phiên bản 2 — 80% | Trang 4–5 | Phần 5.2 |
| Báo cáo tự đánh giá theo mẫu | Trang 5 | Phần 5.2, phần 6.4 |

---

**Kết thúc tài liệu.**

*Tài liệu Markdown này là bản chuyển đổi, hệ thống hóa và lập checklist dựa trên `Final Project.pdf`, không phải bản đề bài sửa đổi. Khi một diễn giải cần quyết định kỹ thuật hoặc xác nhận từ giảng viên, nội dung đó được nêu riêng dưới dạng ghi chú/chỗ chưa rõ.*
