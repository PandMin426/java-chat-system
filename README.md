# Chat System — Final Project

Đồ án cuối kỳ môn **Lập trình ứng dụng Java**.

## 1. Thông tin nhóm

| Thành viên | Phụ trách        |
| ---------- | ---------------- |
| Minh       | Database — MySQL |
| Trang      | Frontend — React |

**Deadline lần 1:** 19:30, Chủ nhật, 18/10/2026.

**Yêu cầu lần 1:**

- Thiết kế giao diện cho cả Admin và User.
- Thiết kế cơ sở dữ liệu và cung cấp SQL script.
- Chưa yêu cầu xử lý sự kiện hay tích hợp đầy đủ chức năng.

## 2. Công nghệ

| Thành phần              | Công nghệ                        |
| ----------------------- | -------------------------------- |
| Frontend                | React                            |
| Database                | MySQL                            |
| Backend (giai đoạn sau) | Java — framework chưa thống nhất |
| Version Control         | Git + GitHub                     |

## 3. Cấu trúc thư mục dự kiến

```text
chat-system/
├── frontend/
│   ├── src/
│   │   ├── pages/
│   │   │   ├── admin/
│   │   │   └── user/
│   │   ├── components/    # Chứa những thành phần có thế tái sử dụng
│   │   └── assets/        # Chứa hình ảnh, biểu tượng,...
│   └── package.json       # file cấu hình
│
├── script/
│   ├── schema.sql
│   └── seed.sql
│
├── docs/                  # Tài nguyên chung
├── .gitignore
└── README.md
```

Không tự ý chỉnh sửa file thuộc phần việc của người còn lại.

## 4. Quy tắc Git & Branch

### 4.1. Nhánh chính

`main` là nhánh chính, chỉ chứa code đã được kiểm tra và thống nhất.

**Quy định:**

- main là nhánh chính, không push trực tiếp.
- Mỗi công việc tạo một nhánh riêng từ main mới nhất.
- Hoàn thành công việc phải tạo Pull Request (PR).
- Người còn lại review trước khi merge.
- Không force push lên main.

### 4.2. Quy tắc đặt tên nhánh

**Cú pháp:**

```text
feature/<ten-cong-viec>
fix/<ten-loi>
docs/<noi-dung>
```

**Ví dụ:**

```text
feature/database-schema
feature/admin-dashboard
feature/user-login-ui
fix/login-layout
docs/update-readme
```

**Quy định:**

- Tên nhánh viết thường, dùng dấu `-` để phân cách từ.
- Mỗi nhánh chỉ phụ trách một công việc cụ thể.

### 4.3. Tạo nhánh mới

**Bắt buộc cập nhật `main` trước khi tạo nhánh mới.**

```bash
git checkout main
git pull origin main
git checkout -b feature/ten-cong-viec
```

### 4.4. Trước mỗi lần bắt đầu code

**Trước mỗi lần tiếp tục làm cập nhật code mới nhất từ `main` và merge vào nhánh đang làm.**

```bash
git checkout main
git pull origin main
git checkout feature/ten-cong-viec
git merge main
```

**Quy định:**

- Commit hoặc stash thay đổi chưa lưu trước khi chuyển nhánh.
- Nếu có conflict, giải quyết trước khi tiếp tục code.
- Không tự ý xóa code người khác khi xử lý conflict.

### 4.5. Commit & Push

Sau khi hoàn thành một phần công việc:

```bash
git status
git add .      # hoặc thêm các file cần thiết
git commit -m "feat: add login UI"
git push -u origin feature/ten-cong-viec
```

**Quy định:**

- Lưu ý: Commit thường xuyên, đúng phần việc, không commit file thừa.

### 4.6. Pull Request

#### 1 - Sau khi pust code lên nhánh của mình sẽ thấy nút màu vàng Create pull request và được nhảu sang trang:
<img width="920" height="677" alt="image" src="https://github.com/user-attachments/assets/e76c386b-114d-4c9c-8a7b-18249477bbfc" />

#### 2 - đoạn Assignees nhấn chọn assign yourself:
<img width="303" height="74" alt="image" src="https://github.com/user-attachments/assets/b360c5e2-e192-4b93-84df-b67814461378" />

#### 3 -oạn Reviewers chọn thành viên sẽ review cho mình:
<img width="295" height="299" alt="image" src="https://github.com/user-attachments/assets/e0a46501-af42-47a3-85a2-b9f47c6afd2a" />

 #### 4 - Có thế viết sơ lược description:
<img width="571" height="389" alt="image" src="https://github.com/user-attachments/assets/612c6a55-a610-40a5-8bdb-37427fe63f91" />






---

**Quy trình chung:**

`Pull main → Create/Checkout feature branch → Merge main (nếu là nhánh đang làm) → Code → Commit → Push → Pull Request → Review → Merge vào main`


SAU KHI XONG CHỜ THÀNH VIÊN KIA ĐỒNG Ý THÌ CODE ĐƯỢC MERGE VÀO



## 5. Quy tắc Commit

Sử dụng commit message ngắn gọn, dễ hiểu.

| Prefix      | Ý nghĩa                            |
| ----------- | ---------------------------------- |
| `feat:`     | Thêm chức năng hoặc thành phần mới |
| `fix:`      | Sửa lỗi                            |
| `refactor:` | Chỉnh sửa cấu trúc code            |
| `docs:`     | Cập nhật tài liệu                  |
| `style:`    | Chỉnh sửa giao diện/định dạng      |
| `chore:`    | Cấu hình và công việc phụ trợ      |

Ví dụ:

```text
feat: create database schema
feat: add admin dashboard UI
fix: resolve navbar overflow
docs: update setup instructions
```

**Mỗi thành viên phải có commit bằng tài khoản GitHub của mình.**

Không gom toàn bộ công việc vào một commit cuối cùng.

## 7. Sử dụng AI

- Mỗi thành viên **tự quản lý AI log** của mình.
- Tự chịu trách nhiệm kiểm tra và hiểu code do AI hỗ trợ tạo ra.
- Không commit API key, token hoặc thông tin nhạy cảm từ công cụ AI.
- Không đưa AI log cá nhân vào repository nếu chưa thống nhất.

## 8. Checklist trước Deadline lần 1

- [ ] Hoàn thành giao diện Admin.
- [ ] Hoàn thành giao diện User.
- [ ] Hoàn thành thiết kế MySQL.
- [ ] Có SQL script tạo database.
- [ ] Có sơ đồ thiết kế cơ sở dữ liệu cho báo cáo.
- [ ] Có hình chụp các màn hình đã thiết kế.
- [ ] Cả Minh và Trang đều có commit trên GitHub.
- [ ] Các PR cần thiết đã merge vào `main`.
- [ ] Chuẩn bị ảnh lịch sử commit của từng thành viên.
- [ ] Chuẩn bị báo cáo và kiểm tra cấu trúc nộp bài.


