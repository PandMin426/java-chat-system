# 🗺️ ROADMAP ĐỒ ÁN CUỐI KỲ — HỆ THỐNG CHAT JAVA
> **Môn:** Lập trình ứng dụng Java | **Nhóm:** 2 người: TM1 = Minh (CSDL + Backend), TM2 = Trang (Frontend + AdminApp)
> **V1 (20%):** ✅ đã nộp 22/11 | **Hoàn thành toàn bộ V2:** **10/12** | **Nộp V2 (80%):** 12/12 (T7)
> *Cập nhật lần cuối: 26/11/2026 (bản 3: sau review PM, đối chiếu repo `main` @ `f415ecc`). Bản này thay toàn bộ phần Phase 2 cũ.*

**Mục lục:** [Thay đổi](#-thay-đổi-so-với-roadmap-cũ) · [Kiến trúc](#️-kiến-trúc-chốt) · [**Cấu hình project — code ở đâu**](#-cấu-hình-project--code-ở-đâu) · [Phân công](#-phân-công-phase-2) · [Quyết định cần chốt](#-quyết-định-cần-chốt) · [Hợp đồng tích hợp](#-hợp-đồng-tích-hợp) · [Timeline](#️-timeline-phase-2-2611--1012) · [Definition of Done](#-definition-of-done) · [Kịch bản demo](#-kịch-bản-demo-chuẩn-k1k8) · [Cắt giảm](#️-cắt-giảm-khi-trễ) · [File nộp](#-cấu-trúc-file-nộp-v2-checklist) · [AI docs](#-ai-documentation-theo-feature) · [Risk](#️-risk--mitigation) · [Tracking](#-tracking-v2)

## 🏗️ KIẾN TRÚC CHỐT

```
 user.jar (JavaFX) ──TCP/JSON lines──►  server.jar (Spring Boot, không web)  ──JdbcTemplate──►  PostgreSQL 17
                                           │  ├─ ChatServer (ServerSocket + ExecutorService)
 admin.jar (JavaFX) ──JDBC (HikariCP)───────┼────────────────────────────────────────────────►  PostgreSQL 17
        └──── ADMIN_KICK + adminToken (TCP) ►│  ├─ SMTP (Spring Mail / Jakarta Mail, Gmail App Password)
                                           │  └─ LLM API (java.net.http.HttpClient)
```

Thứ tự chạy: PostgreSQL → `server.jar` → `admin.jar` / `user.jar`.

---

## 🧭 CẤU HÌNH PROJECT — CODE Ở ĐÂU

> Mục này là **bản đồ chốt**: ai code gì, ở file nào, theo package nào. Việc nào đã có chỗ ở đây thì **cứ tạo đúng chỗ đó, không cần hỏi lại**. Muốn thêm file ngoài bản đồ: nếu nằm trong module của mình thì tự thêm; nếu là **file chung** (mục 1) thì mở PR và tag người kia.

### 1. Quy ước chung

| Quy ước | Nội dung |
|---|---|
| Ký hiệu chủ sở hữu | **[M]** = Minh (TM1) · **[T]** = Trang (TM2) · **[C]** = file chung: ai sửa cũng phải PR + người kia duyệt |
| Package gốc | `com.chatapp.common` · `com.chatapp.server` · `com.chatapp.user` · `com.chatapp.admin` (giữ như V1) |
| File chung [C] | `pom.xml` (parent), `.gitignore`, `config.example.properties`, `src/common/**`, `docs/backend/protocol.md`, `docs/ai/work-log.md`, `script/schema.sql` |
| Kiểu dữ liệu trong DTO | ID = `long`; thời điểm = `java.time.Instant` (JSON ISO-8601, nhờ `jackson-datatype-jsr310`); client hiển thị theo `Asia/Ho_Chi_Minh`; khóa/ciphertext = `byte[]` (Jackson tự mã hóa Base64) |
| DTO | Java `record`, gom theo miền trong 1 file, ví dụ `AuthDto.LoginRequest`, `AuthDto.LoginResult` |
| Lỗi | Server trả `error = {code, message}`; `code` lấy từ enum `ErrorCode` trong `common` (`UNAUTHENTICATED`, `FORBIDDEN`, `NOT_FOUND`, `VALIDATION`, `CONFLICT`, `BLOCKED`, `LOCKED`, `RATE_LIMITED`, `UNAVAILABLE`, `INTERNAL`). Client đổi `code` → câu tiếng Việt |
| Luồng (thread) server | 1 thread/ client lấy từ `ExecutorService`; ghi xuống socket của 1 session phải `synchronized`; push gửi qua `SessionRegistry` |
| Luồng client | **Không bao giờ chặn FX thread**: `ServerConnection` có thread đọc riêng; kết quả `CompletableFuture` → `Platform.runLater(...)` |
| SQL | Chỉ nằm trong `repository/` (server) hoặc `dao/` (admin), viết bằng text block `"""…"""`, luôn dùng tham số `?`. Ghi nhiều bảng thì 1 transaction (`@Transactional` ở `service/` phía server; `Db.inTransaction(...)` phía admin), khóa theo thứ tự **user → conversation** |
| Mật khẩu | `common/security/Passwords` (jBCrypt) dùng cho cả server và admin, để 2 bên băm giống nhau |

### 2. Cây thư mục đích V2

```
code/                                   ← gốc repo
├── pom.xml                       [C]   + <module>src/server</module>, import BOM Spring Boot (mục 4)
├── config.example.properties     [C]   MỚI 26/11 [M]: mẫu config, commit lên Git
├── config.properties                   bản thật trên máy mỗi người, thêm vào .gitignore (26/11 [M])
│
├── src/common/                   [C]   com.chatapp.common
│   ├── DateFields.java, GenderFields.java        (có sẵn, JavaFX)
│   ├── config/AppConfig.java              [T] 26/11  đọc config.properties (mục 5)
│   ├── protocol/
│   │   ├── MessageType.java               [M] enum mọi command + push (thêm theo từng đợt)
│   │   ├── Request.java · Response.java · Push.java · ErrorInfo.java   [M] 26/11
│   │   ├── ErrorCode.java                 [M] 26/11
│   │   ├── JsonCodec.java                 [M] 26/11  ObjectMapper dùng chung, encode/decode 1 dòng
│   │   └── dto/                           [M] AuthDto, FriendDto, ChatDto, SpamDto, LlmDto, GroupDto, E2eeDto, AdminDto
│   ├── security/Passwords.java            [M] 27/11  hash()/matches() bằng jBCrypt
│   └── crypto/CryptoUtil.java             [T] 02/12  RSA-OAEP 2048 + AES-256-GCM, chỉ dùng JDK (javax.crypto)
│   (resources: com/chatapp/common/theme.css có sẵn)
│
├── src/server/                   [M]   MỚI · com.chatapp.server
│   ├── pom.xml                                     (mục 4)
│   ├── src/main/java/com/chatapp/server/
│   │   ├── ServerApp.java                           @SpringBootApplication, main()
│   │   ├── config/ChatProperties.java               chat.port, admin.token, llm.* (@ConfigurationProperties)
│   │   ├── net/
│   │   │   ├── ChatServer.java                      ServerSocket + accept loop, khởi động sau khi Spring sẵn sàng
│   │   │   ├── ClientSession.java                   1 socket: vòng đọc, send(), userId, deviceId
│   │   │   ├── SessionRegistry.java                 onlineMap userId → session, kick(), push()
│   │   │   ├── Dispatcher.java                      MessageType → handler; bắt lỗi → Response lỗi
│   │   │   └── CommandHandler.java                  interface
│   │   ├── handler/   AuthHandler · ProfileHandler · FriendHandler · ChatHandler · LlmHandler
│   │   │              SpamHandler · GroupHandler · E2eeHandler · AdminControlHandler
│   │   ├── service/   AuthService · FriendService · ChatService · LlmService · MailService
│   │   │              SpamService · GroupService · E2eeService · PushService
│   │   ├── repository/  UserRepository · LoginHistoryRepository · FriendRepository · BlockRepository
│   │   │                ConversationRepository · MessageRepository · GroupRepository
│   │   │                E2eeRepository · SpamRepository · AuditRepository
│   │   ├── model/       record ánh xạ dòng CSDL (UserRow, MessageRow…), không lộ ra ngoài server
│   │   └── error/AppException.java                  mang ErrorCode
│   ├── src/main/resources/application.properties    (mục 5)
│   └── src/test/java/com/chatapp/server/
│       ├── TestClient.java                          client TCP giả để test command, dùng protocol của common
│       └── <Miền>FlowTest.java                      mỗi feature 1 test luồng chính + 1 case bị từ chối
│
├── src/user/                     [T]   com.chatapp.user (đã có V1)
│   ├── UserApp.java, Navigator.java              (có sẵn)
│   ├── UserLauncher.java                    09/12  main() không kế thừa Application, dùng cho fat-jar
│   ├── AppSession.java                      26/11  giữ ServerConnection, user đang đăng nhập, deviceId
│   ├── net/
│   │   ├── ServerConnection.java            26/11  interface: send(type, payload) → CompletableFuture, onPush(type, listener)
│   │   ├── TcpServerConnection.java         26/11  bản thật: socket, thread đọc, map reqId → future
│   │   └── MockServerConnection.java        26/11  bản giả, trả dữ liệu từ sample/SampleData (bật bằng chat.mock=true)
│   ├── api/  AuthApi · FriendApi · ChatApi · LlmApi · SpamApi · GroupApi · E2eeApi
│   │                                         lớp mỏng: dựng DTO, gọi ServerConnection; controller chỉ gọi api/
│   ├── crypto/
│   │   ├── DeviceKeyStore.java              05/12  lưu khóa riêng ở ${user.home}/.chatapp/<username>/
│   │   └── GroupKeyCache.java               06/12  khóa nhóm theo epoch đã mở trong phiên
│   ├── controller/  (có sẵn, gắn sự kiện thật, xem mục 6)
│   └── sample/SampleData.java               (có sẵn) giữ cho MockServerConnection và test
│   (resources: view/*.fxml, user.css có sẵn; test: FxmlLoadTest, NavigationTest, ScreenshotTool có sẵn)
│
├── src/admin/                    [T]   com.chatapp.admin (đã có V1)
│   ├── AdminApp.java, AdminNavigator.java        (có sẵn)
│   ├── AdminLauncher.java                   09/12
│   ├── AdminSession.java                    03/12  admin đang đăng nhập, Db, KickClient
│   ├── db/Db.java                           03/12  HikariDataSource từ db.*, inTransaction(...)
│   ├── dao/  AdminAuthDao · UserDao · LoginHistoryDao · GroupDao · SpamDao · StatsDao · AuditDao
│   │                                         SQL lấy từ script/queries.sql (Q02–Q07, Q09) khi có sẵn
│   ├── net/KickClient.java                  04/12  nối ChatServer, gửi ADMIN_KICK + admin.token, chờ ACK
│   ├── model/                               03/12  chuyển các record UserRow, LoginRow, GroupRow, SpamRow,
│   │                                         NewUserRow, FriendStatRow, ActiveRow… từ sample/SampleData sang đây,
│   │                                         DAO trả về đúng các record này để controller sửa ít nhất
│   └── controller/  (có sẵn, xem mục 6)
│
├── script/                       [M]
│   ├── schema.sql · seed.sql · queries.sql · tests/  (có sẵn)
│   ├── demo_data.sql                        27/11 bản tối thiểu (1 admin + 3 user) · 06/12 bản đầy đủ
│   └── create_db.sql                        06/12 = schema.sql + demo_data.sql (file nộp)
├── release/                                 09/12 3 jar + config.properties
├── git/                                     10/12 ảnh commit
└── docs/
    ├── backend/protocol.md       [C]   MỚI 26/11: hợp đồng giao thức (mục 3 của Hợp đồng tích hợp)
    ├── backend/ai/<feature>/     [M]
    ├── frontend/ai/<feature>/    [T]
    ├── database/ai/demo-data/    [M]
    └── ai/protocol/ · work-log.md  [C]
```

### 3. Công thức thêm 1 command (làm đúng thứ tự)

| Bước | Ai | File | Việc |
|---|---|---|---|
| 1 | người cần command | `docs/backend/protocol.md` | Thêm mục: tên, request JSON mẫu, response JSON mẫu, các `ErrorCode` có thể trả, push kèm theo. Người kia duyệt trong PR |
| 2 | [M] | `common/protocol/MessageType.java` + `common/protocol/dto/<Miền>Dto.java` | Thêm hằng + record request/result |
| 3 | [M] | `server/repository/…` → `server/service/…` → `server/handler/…` | SQL → transaction + kiểm tra quyền/chặn/vai trò → handler; đăng ký trong `Dispatcher` |
| 4 | [M] | `server/src/test/…/<Miền>FlowTest.java` | Test bằng `TestClient`: 1 luồng đúng + 1 case bị từ chối. Xong thì đánh dấu ✅ trong `protocol.md` |
| 5 | [T] | `user/api/<Miền>Api.java` + `user/net/MockServerConnection.java` | Thêm hàm gọi; mock trả dữ liệu giả để làm UI trước |
| 6 | [T] | `user/controller/<Màn hình>Controller.java` | Gọi `api/`, cập nhật UI trong `Platform.runLater`; chạy lại với server thật |

Bước 2–4 và 5–6 chạy song song sau khi bước 1 đã merge.

### 4. Cấu hình Maven

**Parent `pom.xml` [C]** (làm 26/11, [M] mở PR):
```xml
<modules>
    <module>src/common</module>
    <module>src/user</module>
    <module>src/admin</module>
    <module>src/server</module>          <!-- MỚI -->
</modules>

<properties>
    <!-- giữ các property đang có (Java 21, JavaFX 21.0.6, Ikonli 12.3.1, JUnit 5.11.4) -->
    <spring-boot.version>3.4.1</spring-boot.version>
</properties>

<dependencyManagement>
    <dependencies>
        <!-- giữ các mục đang có, thêm: -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>         <!-- quản lý version Jackson, HikariCP, PostgreSQL driver cho mọi module -->
        </dependency>
        <dependency>
            <groupId>org.mindrot</groupId>
            <artifactId>jbcrypt</artifactId>
            <version>0.4</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

| Module | Thêm dependency | Ghi chú |
|---|---|---|
| `src/common` [C] | `jackson-databind`, `jackson-datatype-jsr310`, `jbcrypt` | Đổi `javafx-controls` thành `<optional>true</optional>` để `server.jar` không kéo JavaFX theo. `user`/`admin` đã tự khai báo JavaFX nên không ảnh hưởng |
| `src/server` [M] | `common`, `spring-boot-starter-jdbc` (có sẵn HikariCP), `postgresql`, `spring-boot-starter-mail`, `spring-boot-starter-test` (test) | Plugin `spring-boot-maven-plugin` (repackage → `server.jar`). Không dùng `spring-boot-starter-web`, không dùng JPA |
| `src/user` [T] | (đã có) `common`, JavaFX, Ikonli | 09/12 thêm `maven-shade-plugin`, `mainClass = com.chatapp.user.UserLauncher` |
| `src/admin` [T] | `HikariCP`, `postgresql` | 09/12 thêm `maven-shade-plugin`, `mainClass = com.chatapp.admin.AdminLauncher` |

> Version ghi ở đây là gợi ý; ngày 26/11 build thử `mvnw -q verify` xanh thì chốt luôn, không đổi giữa chừng.

### 5. File cấu hình

**`config.example.properties` [C]** (cả 3 jar đọc chung, D6):
```properties
# --- CSDL: server.jar và admin.jar ---
db.url=jdbc:postgresql://localhost:5432/chatdb
db.user=postgres
db.password=doi_mat_khau
# --- ChatServer: cả 3 jar ---
# (không dùng "server.port" vì Spring hiểu đó là cổng web server)
chat.host=localhost
chat.port=9999
# Bí mật chung admin.jar ↔ server.jar cho ADMIN_KICK
admin.token=doi_chuoi_bi_mat
# --- Chỉ dùng khi dev giao diện: true = user.jar dùng MockServerConnection ---
chat.mock=false
# --- SMTP: chỉ server.jar ---
smtp.host=smtp.gmail.com
smtp.port=587
smtp.user=
smtp.password=
# --- LLM: chỉ server.jar ---
llm.base-url=
llm.api-key=
llm.model=
llm.timeout-ms=15000
```

**`AppConfig` (common) tìm file theo thứ tự:** (1) đường dẫn trong `-Dchat.config=<file>`; (2) `config.properties` cạnh file jar đang chạy; (3) `config.properties` trong thư mục làm việc hiện tại.

**`src/server/src/main/resources/application.properties` [M]:**
```properties
spring.main.web-application-type=none
spring.config.import=optional:file:${chat.config:./config.properties}
spring.datasource.url=${db.url}
spring.datasource.username=${db.user}
spring.datasource.password=${db.password}
spring.mail.host=${smtp.host}
spring.mail.port=${smtp.port}
spring.mail.username=${smtp.user}
spring.mail.password=${smtp.password}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```
Thầy chấm chỉ cần sửa `db.*` trong `config.properties` (và `smtp.*`, `llm.*` nếu muốn thử email/AI).

### 6. Màn hình → controller → command / DAO

**UserApp** (`src/user`, controller có sẵn từ V1):

| Màn hình | Controller | Command (api/) | Ngày |
|---|---|---|---|
| S01 Đăng nhập | `LoginController` | `LOGIN` (kết quả kèm hồ sơ + cờ `mustChangePassword`) | 27/11 |
| S02 Đăng ký | `RegisterController` | `REGISTER` | 27/11 |
| Cửa sổ chính | `MainController` | `GET_CONVERSATIONS`, `LOGOUT`; push `FORCE_LOGOUT`, `MESSAGE_NEW`, `FRIEND_STATUS`; banner D9 | 27/11, 29/11, 30/11 |
| S06 Bạn bè | `FriendsController` | `GET_FRIENDS`, `GET_FRIEND_REQUESTS`, `FRIEND_REQUEST_RESPOND`, `FRIEND_REMOVE`, `BLOCK_USER`, `UNBLOCK_USER`, `GET_BLOCKED` | 28/11 |
| S07 Tìm người | `SearchUsersController` | `SEARCH_USERS`, `FRIEND_REQUEST_SEND`, `OPEN_CONVERSATION` | 28/11 |
| D05 Xác nhận chặn | `ChatViews.confirmBlock` → `ConfirmController` | `BLOCK_USER` | 28/11 |
| S04 Trò chuyện 1-1 | `ChatController`, `ChatViews` | `OPEN_CONVERSATION`, `LOAD_HISTORY`, `SEND_MESSAGE`, `MARK_READ` | 29/11 |
| S09 Hồ sơ | `ProfileController` | `UPDATE_PROFILE`, `CHANGE_PASSWORD` | 30/11 |
| S04b Chọn tin để xóa, D03 Xóa lịch sử | `ChatController`, `ConfirmController` | `HIDE_MESSAGES`, `CLEAR_HISTORY`, `SEARCH_MESSAGES` (trong 1 hội thoại), `LOAD_AROUND` | 01/12 |
| S08 Tìm trong tất cả | `SearchMessagesController` | `SEARCH_MESSAGES` (mọi chat 1-1), `LOAD_AROUND` | 01/12 |
| S03 Quên mật khẩu | `ForgotPasswordController` | `RESET_PASSWORD` | 02/12 |
| Khung trợ lý AI (S04) | `ChatController` | `LLM_REWRITE`, `LLM_SUGGEST` | 02/12 |
| D02 Báo cáo spam | `ReportSpamController` | `REPORT_SPAM` | 02/12 |
| D01 Tạo nhóm | `CreateGroupController`, `MemberPicker` | `SEARCH_USERS`, `GROUP_CREATE` | 05/12 |
| S05 Nhóm chat | `GroupChatController` | `GET_GROUP_MEMBERS`, `GROUP_RENAME`, `GROUP_SET_ADMIN`, `GROUP_REMOVE_MEMBER`, `GROUP_LEAVE`, `SEND_MESSAGE` (GROUP), push `GROUP_*` | 05/12–06/12 |
| D04 Thêm thành viên | `AddMemberController`, `MemberPicker` | `GROUP_ADD_MEMBER` | 05/12 |
| D06 Chuyển quyền admin | `TransferAdminController` | `GROUP_SET_ADMIN` rồi `GROUP_LEAVE` | 05/12 |
| (không có màn hình) | `crypto/*`, `api/E2eeApi` | `UPLOAD_PUBLIC_KEY`, `GET_MEMBER_KEYS`, `UPLOAD_KEY_GRANTS`, `GET_KEY_GRANTS`; push `GROUP_KEY_ROTATED` | 05/12–06/12 |

**AdminApp** (`src/admin`, controller có sẵn từ V1, DAO mới):

| Màn hình | Controller | DAO / SQL | Ngày |
|---|---|---|---|
| S10 Đăng nhập | `AdminLoginController` | `AdminAuthDao.login` (`system_role=ADMIN`) + `AuditDao` LOGIN_SUCCESS | 03/12 |
| S11 Người dùng (+ tab lịch sử, tab bạn bè) | `UsersController` | `UserDao` (lọc, sắp xếp, khóa/mở, xóa mềm), `LoginHistoryDao` (Q03), `UserDao.friendsOf` | 03/12 |
| S11a/S11b Thêm/Sửa | `UserFormController` | `UserDao.create/update` + `Passwords.hash` | 03/12 |
| S11c Đặt lại mật khẩu | `ResetPasswordController` | `UserDao.setPassword` + audit PASSWORD_RESET | 03/12 |
| S12 Nhật ký đăng nhập | `LoginLogController` | `LoginHistoryDao` (Q03) | 03/12 |
| S13 Nhóm chat | `GroupsController` | `GroupDao` (Q09, cột Trạng thái từ `closed_at`) | 03/12 |
| S14 Báo cáo spam | `SpamController` | `SpamDao` (Q07, khóa → RESOLVED tất cả, Bỏ qua → DISMISSED) + `KickClient` | 04/12 |
| S15 Đăng ký mới (danh sách + biểu đồ) | `NewUsersController`, `MonthlyChart` | `StatsDao.newUsers` (Q06) | 04/12 |
| S16 Thống kê bạn bè | `FriendStatsController` | `StatsDao.friendCounts` (Q02) | 04/12 |
| S17 Người dùng hoạt động (danh sách + biểu đồ) | `ActiveUsersController`, `MonthlyChart` | `StatsDao.activity` (Q05), `activityMonthly` (Q04) | 04/12 |
| Bảng lọc dùng chung | `Tables` | — | 04/12 |

### 7. Dựng môi trường dev (mỗi người làm 1 lần)

1. Cài PostgreSQL 17, tạo DB dev: `createdb -U postgres chatdb`
2. Nạp schema và dữ liệu dev: `psql -U postgres -d chatdb -f script/schema.sql` rồi `-f script/demo_data.sql` (có từ 27/11). **Không** chạy `seed.sql` vào `chatdb`: file đó tự chặn nếu tên DB không phải `jcs_schema_test_*`.
3. Copy `config.example.properties` → `config.properties` ở gốc repo, sửa `db.*`.
4. Build 1 lần: `mvnw -q install -DskipTests`.
5. Chạy server: Run configuration của `ServerApp` với **Working directory = gốc repo** (hoặc VM option `-Dchat.config=<đường dẫn>/config.properties`).
6. Chạy app: `UserApp` / `AdminApp` cũng đặt Working directory = gốc repo. Muốn chạy 2–3 UserApp để test chat thì mở thêm run configuration (IntelliJ: *Allow multiple instances*).
7. Làm UI khi server chưa có command: đặt `chat.mock=true`.

> 26/11: Minh chạy thử đủ 7 bước trên máy mình, Trang chạy lại trên máy mình. Bước nào vướng thì sửa ngay mục này.

---

## 👥 PHÂN CÔNG PHASE 2

### 🔵 TM1 (Minh): Backend + CSDL
**Phạm vi:** mọi thứ chạy trong `server.jar` và mọi script CSDL.
- `src/common/protocol` + `security/Passwords` (DTO, MessageType, JsonCodec, ErrorCode)
- `src/server`: ChatServer, handler, service, repository (JdbcTemplate) cho toàn bộ command: Tài khoản, Bạn bè, Chat, LLM, Spam, Nhóm, E2EE phía server (epoch, grant), `ADMIN_KICK`
- Làm đủ các kiểm tra mà schema giao cho server (`database-schema.md`, dòng "ChatServer"): khóa theo thứ tự user → conversation, READ COMMITTED, kiểm tra lại quyền/chặn/vai trò/epoch trước khi ghi
- Ngoại vi: gửi email (U3), gọi LLM (U11.h)
- Viết sẵn SQL/transaction cho các thao tác khó phía admin để TM2 gắn vào DAO: khóa từ báo cáo (D38), xóa mềm user là admin cuối của nhóm (D33)
- `script/demo_data.sql`, `create_db.sql`; build `server.jar`
- Báo cáo: Thiết kế CSDL, Thiết kế hệ thống

### 🟠 TM2 (Trang): UserApp + AdminApp
**Phạm vi:** mọi thứ chạy trong `user.jar` và `admin.jar`.
- `src/common/config/AppConfig`, `crypto/CryptoUtil`
- `src/user`: `net/` (ServerConnection thật + mock), `api/`, `crypto/` (kho khóa thiết bị), gắn sự kiện cho S01–S09 + D01–D06
- `src/admin`: `db/`, `dao/` (dùng lại Q02–Q07, Q09), `net/KickClient`, gắn sự kiện cho S10–S17 + 2 dialog; biểu đồ A6, A9 (đã có `MonthlyChart`), bảng lọc dùng chung (đã có `Tables`)
- Build `user.jar`, `admin.jar` (fat-jar JavaFX)
- Báo cáo: Hướng dẫn sử dụng (ảnh), kịch bản video

### 🤝 Làm chung
Chốt giao thức (3 đợt), test tích hợp ở mỗi checkpoint theo kịch bản K1–K8, bug bash, báo cáo V2, video, báo cáo tự đánh giá.

> ⚠️ **Kiểm tra quyền làm ở server** (D32), không chỉ ẩn nút ở client. FE ẩn nút cho đẹp, BE vẫn phải chặn.
> ⚠️ README: không tự ý sửa file thuộc phần việc của người còn lại. Cần đổi thì nhắn người kia hoặc mở PR file chung [C].

### ⏱️ Giả định năng lực
Roadmap giả định **mỗi người khoảng 6 giờ/ngày, kể cả T7/CN**. Hai bạn cần xác nhận con số này ngày 26/11, vì còn môn khác chạy song song. Nếu thực tế ít hơn: dùng buffer nửa ngày (30/11, 05/12, 07/12) trước, rồi cắt giảm theo bảng Cắt giảm **từ Checkpoint 1**, không đợi tới cuối.

---

## ❓ QUYẾT ĐỊNH CẦN CHỐT

| # | Quyết định | Đề xuất | Ai chốt | Hạn |
|---|---|---|---|---|
| Q1 | Server dùng JdbcTemplate thay JPA | Đồng ý (lý do ở bảng Thay đổi) | Minh | 26/11 |
| Q2 | DAO admin chuyển sang TM2 | Đồng ý | Cả nhóm | 26/11 |
| Q3 | Số giờ làm mỗi ngày của từng người | ~6 giờ | Cả nhóm | 26/11 |
| Q4 | Nhà cung cấp LLM + API key (M17 còn mở) | Chọn 1 nhà cung cấp có gói miễn phí, gọi HTTP/JSON được | Cả nhóm | 29/11 |
| Q5 | Tài khoản Gmail + App Password cho SMTP | Tạo tài khoản Gmail riêng cho nhóm, bật xác minh 2 bước | Minh | 30/11 |
| Q6 | Lưu lý do báo cáo spam (diff.md A5) | Nối các nhãn bằng `"; "` vào cột `reason` | Cả nhóm | 30/11 |
| Q7 | Admin đặt lại mật khẩu có bật `must_change_password` không (diff.md A3) | Có | Cả nhóm | 02/12 |
| Q8 | Phạm vi "E2EE tối thiểu" cho Checkpoint 3 | Xem mục Cắt giảm | Cả nhóm | 03/12 |
| Q9 | `script/` trong zip: chỉ `create_db.sql` hay kèm `schema.sql`, `queries.sql`, `tests/` | Chỉ `create_db.sql` + `demo_data.sql` | Cả nhóm | 09/12 |

---

## 🔌 HỢP ĐỒNG TÍCH HỢP

1. **`docs/backend/protocol.md` chốt theo 3 đợt** (danh sách command ở bảng dưới). Command đã chốt muốn đổi thì phải báo người kia và cập nhật file trong cùng PR.
2. **FE không chờ BE**: buổi sáng FE gắn UI với `MockServerConnection`, buổi chiều chuyển sang server thật.
3. **BE merge PR vào `main` trước 14h** mỗi ngày, kèm dấu ✅ trong `protocol.md` cho command đã chạy được.
4. **Review PR trong vòng 2 giờ** kể từ khi được tag (trong giờ làm). Quá hạn mà không có góp ý thì người mở PR nhắn trực tiếp, không tự merge.
5. **Nhánh**: `feature/<tên-feature>` (trùng tên feature trong tài liệu AI) tạo từ `main` mới nhất → PR vào `main` → người kia review → merge. Không push thẳng, không force push lên `main`.
6. **`work-log.md`**: trước khi ghi thì `git pull`. Nếu PR conflict ở file này thì giữ cả 2 phần (log chỉ ghi thêm).

| Đợt | Hạn chốt | Command | Push |
|---|---|---|---|
| 1 | 26/11 | `REGISTER`, `LOGIN`, `LOGOUT`, `UPDATE_PROFILE`, `CHANGE_PASSWORD`, `GET_FRIENDS`, `SEARCH_USERS`, `FRIEND_REQUEST_SEND`, `FRIEND_REQUEST_RESPOND`, `GET_FRIEND_REQUESTS`, `FRIEND_REMOVE`, `BLOCK_USER`, `UNBLOCK_USER`, `GET_BLOCKED`, `GET_CONVERSATIONS`, `OPEN_CONVERSATION`, `SEND_MESSAGE` (PRIVATE), `MARK_READ`, `LOAD_HISTORY` | `FORCE_LOGOUT`, `FRIEND_STATUS`, `FRIEND_REQUEST_NEW`, `FRIEND_LIST_CHANGED`, `MESSAGE_NEW` |
| 2 | 30/11 | `HIDE_MESSAGES`, `CLEAR_HISTORY`, `SEARCH_MESSAGES`, `LOAD_AROUND`, `RESET_PASSWORD`, `LLM_REWRITE`, `LLM_SUGGEST`, `REPORT_SPAM`, `GROUP_CREATE`, `GET_GROUP_MEMBERS`, `GROUP_RENAME`, `GROUP_ADD_MEMBER`, `GROUP_SET_ADMIN`, `GROUP_REMOVE_MEMBER`, `GROUP_LEAVE`, `ADMIN_KICK` | `GROUP_UPDATED`, `GROUP_REMOVED_YOU`, `GROUP_CLOSED` |
| 3 | 03/12 | `UPLOAD_PUBLIC_KEY`, `GET_MEMBER_KEYS`, `UPLOAD_KEY_GRANTS`, `GET_KEY_GRANTS`, `SEND_MESSAGE` (GROUP: ciphertext, epoch, thiết bị) | `GROUP_KEY_ROTATED` |

Quy ước dòng: UTF-8, mỗi message 1 dòng kết thúc `\n`, `reqId` là số tăng dần do client tạo, push không có `reqId`.

---

## 🗓️ TIMELINE PHASE 2 (26/11 → 10/12)

> Bản 3 đổi so với bản trước: ngày 26/11 nhẹ đi (bỏ entity JPA, protocol chia đợt); DAO admin sang TM2; **E2EE phía server làm sớm từ 04/12** và quyết định có dùng phương án dự phòng vào **trưa 06/12**; có buffer nửa ngày; báo cáo viết dần từ 07/12. Tính tới 26/11, repo chưa có code V2 (chưa có `src/server`, chưa có `protocol.md`).

### Sprint 2.A — Nền tảng + Tài khoản + Bạn bè + Chat 1-1 (26/11 – 30/11)

| Ngày | 🔵 TM1 (Minh) | 🟠 TM2 (Trang) |
|---|---|---|
| **26/11** (T5) | *Chung:* chốt Q1–Q3, `protocol.md` đợt 1. Parent POM + module `src/server` (ServerApp, ChatServer nhận kết nối, Dispatcher, ClientSession), `config.example.properties`, `.gitignore`, gói `common/protocol` (Request/Response/Push, ErrorCode, JsonCodec). Server kết nối được DB (`SELECT 1`). Chạy thử mục 7 | *Chung:* `protocol.md` đợt 1. `common/config/AppConfig`, JavaFX `optional` trong `common`. `user/net`: `ServerConnection`, `TcpServerConnection`, `MockServerConnection`, `AppSession`. Chạy lại mục 7 trên máy mình |
| **27/11** (T6) | `REGISTER`, `LOGIN`, `LOGOUT` (BCrypt qua `Passwords`, tên đăng nhập không phân biệt hoa/thường, từ chối LOCKED/đã xóa, ghi `login_history` kèm snapshot), `SessionRegistry` 1 phiên/tài khoản + `FORCE_LOGOUT`. `TestClient`. `demo_data.sql` tối thiểu — **SD1, SD2** | S01, S02, cửa sổ chính, `AuthApi`. Xử lý `FORCE_LOGOUT`, mất kết nối |
| **28/11** (T7) | Bạn bè: `GET_FRIENDS`, `SEARCH_USERS` (Q08, D18), `FRIEND_REQUEST_SEND/RESPOND`, `GET_FRIEND_REQUESTS`, `FRIEND_REMOVE`, `BLOCK_USER` (hủy kết bạn + hủy lời mời + cấm chat 1-1 hai chiều, 1 transaction), `UNBLOCK_USER`, `GET_BLOCKED`. Push `FRIEND_STATUS`, `FRIEND_REQUEST_NEW`, `FRIEND_LIST_CHANGED` — **SD4, SD5** | S06 (Tất cả / Đang online với chấm xanh realtime / Lời mời / Đã chặn + Bỏ chặn), S07, D05 |
| **29/11** (CN) | Chat 1-1: `GET_CONVERSATIONS` (số tin chưa đọc), `OPEN_CONVERSATION`, `SEND_MESSAGE`, push `MESSAGE_NEW`, `MARK_READ`, `LOAD_HISTORY` (50 tin/lần, Q01) — **SD6**. Chốt Q4 | S04 khung chat, danh sách hội thoại, badge chưa đọc, cuộn lên để tải thêm |
| **30/11** (T2) | `UPDATE_PROFILE`, `CHANGE_PASSWORD` (tắt `must_change_password`). *Chung:* `protocol.md` đợt 2, chốt Q5, Q6. **Chiều: buffer** | S09, banner D9 ở MainView. Build thử `user.jar` (shade) 1 lần. **Chiều: buffer** |

> 📌 **Checkpoint 1 — 30/11 tối:** chạy K1–K3 với 2 UserApp từ IDE.

### Sprint 2.B — Chat nâng cao + Ngoại vi + Nhóm + Admin (01/12 – 05/12)

| Ngày | 🔵 TM1 (Minh) | 🟠 TM2 (Trang) |
|---|---|---|
| **01/12** (T3) | `HIDE_MESSAGES`, `CLEAR_HISTORY` (chỉ phía mình, D25), `SEARCH_MESSAGES` (chỉ chat 1-1, D26), `LOAD_AROUND` — **SD7** | S04b, D03, tìm trong hội thoại, S08, nhảy tới tin và tô sáng |
| **02/12** (T4) | `RESET_PASSWORD` (tên đăng nhập + email khớp, mật khẩu ngẫu nhiên 10 ký tự, gửi mail trước rồi mới ghi DB, bật `must_change_password`), `LLM_REWRITE`/`LLM_SUGGEST` (timeout, giới hạn số lần gọi), `REPORT_SPAM` (chỉ chat 1-1, đối phương đã gửi ≥ 1 tin, mỗi cặp 1 báo cáo PENDING) — **SD3, SD8, SD12 (nửa đầu)**. Chốt Q7 | S03, khung trợ lý AI, D02. **`CryptoUtil` + unit test** (bọc/mở khóa RSA-OAEP, mã hóa/giải mã AES-GCM) |
| **03/12** (T5) | Quản lý nhóm: `GROUP_CREATE` (người tạo + ≥ 2 người khác, không ai có quan hệ chặn với người tạo; D31, D20), `GET_GROUP_MEMBERS`, `GROUP_RENAME` / `GROUP_SET_ADMIN` / `GROUP_REMOVE_MEMBER` (chỉ admin nhóm), `GROUP_ADD_MEMBER` (mọi thành viên, D32), `GROUP_LEAVE`; push `GROUP_UPDATED`, `GROUP_REMOVED_YOU` — **SD9, SD10**. `ADMIN_KICK` (kiểm tra `admin.token`, trả ACK). *Chung:* `protocol.md` đợt 3, chốt Q8 | Admin A1–A3: `db/Db`, `model/`, `AdminAuthDao` + S10 (audit LOGIN_SUCCESS, không ghi `login_history`), `UserDao` + S11, S11a/b, S11c (admin tự gõ mật khẩu, D10), `LoginHistoryDao` + S12, `GroupDao` + S13 |
| **04/12** (T6) | **E2EE phía server**: `UPLOAD_PUBLIC_KEY` (1 thiết bị/tài khoản, máy mới thu hồi máy cũ), epoch PENDING → ACTIVE, `GET_MEMBER_KEYS`, `UPLOAD_KEY_GRANTS`, `GET_KEY_GRANTS`, `SEND_MESSAGE` GROUP (kiểm tra epoch ACTIVE, chỉ nhận ciphertext). Test bằng `TestClient` + `CryptoUtil` — **SD11**. Đưa TM2 SQL khóa từ báo cáo (D38) | Admin A4–A9: `SpamDao` + S14 (khóa → RESOLVED tất cả, Bỏ qua → DISMISSED), `KickClient` + audit CONTROL_* + `kickFailedNote` "Thử lại" ở S11/S14 (diff.md B1), `StatsDao` + S15, S16, S17, biểu đồ A6, A9 |
| **05/12** (T7) | Xoay khóa khi đổi thành viên, push `GROUP_KEY_ROTATED`. D33: admin cuối rời nhóm → chuyển quyền, hoặc **đóng nhóm** (`closed_at`) khi không còn ai đủ điều kiện, push `GROUP_CLOSED`. Đưa TM2 SQL xóa mềm user là admin cuối. **Chiều: buffer** | Nhóm: D01, D04, khung thông tin S05, D06; `DeviceKeyStore` + `UPLOAD_PUBLIC_KEY` khi đăng nhập. **Chiều: buffer** |

> 📌 **Checkpoint 2 — 05/12 tối:** chạy K1–K6 và K8 (U1–U11, A1–A9, email, LLM, khóa user đang online thì bị đá ra ngay).

### Sprint 2.C — Tích hợp E2EE + Ổn định (06/12 – 08/12) 🔴

| Ngày | 🔵 TM1 (Minh) | 🟠 TM2 (Trang) |
|---|---|---|
| **06/12** (CN) | *Chung sáng:* tích hợp E2EE với client. **12h: quyết định có dùng phương án dự phòng không** (tiêu chí: 2 client gửi và đọc được 1 tin nhóm mã hóa). Chiều: `demo_data.sql` đầy đủ + `create_db.sql` | Luồng khóa: nhận `GROUP_KEY_ROTATED` → lấy khóa thành viên → sinh khóa nhóm → bọc → upload; mở grant bằng khóa riêng (`GroupKeyCache`); mã hóa/giải mã trong S05. `closedNote` + khóa ô soạn tin, nhãn "Đã đóng" ở S13; gắn SQL xóa mềm admin cuối vào `UserDao` |
| **07/12** (T2) | **Buffer**: sửa E2EE hoặc làm phương án dự phòng. Viết phần **Thiết kế CSDL** cho báo cáo (từ `design-baseline.md`) | **Buffer**: sửa lỗi tích hợp. Dựng khung báo cáo, chụp ảnh màn hình đã ổn định cho Hướng dẫn sử dụng (`ScreenshotTool`) |
| **08/12** (T3) | *Chung:* bug bash theo K1–K8 và UC01–UC31. BE chốt `create_db.sql` | *Chung:* bug bash. FE chỉnh thông báo lỗi, CSS |

> 📌 **Checkpoint 3 — 06/12 tối:** chạy K7 (3 client chat nhóm realtime; DB chỉ thấy ciphertext; thành viên mới không đọc được tin cũ).

### Sprint 2.D — Release + Báo cáo (09/12 – 10/12)

| Ngày | 🔵 TM1 (Minh) | 🟠 TM2 (Trang) |
|---|---|---|
| **09/12** (T4) | Build `server.jar`; chạy thử trên máy sạch, chỉ sửa `db.*`. Viết phần **Thiết kế hệ thống** (kiến trúc 3 jar, giao thức, D1–D43, SD1–SD12) | Build `user.jar`, `admin.jar` (`UserLauncher`, `AdminLauncher`). Viết **Hướng dẫn sử dụng**, kịch bản video (lấy từ K1–K8) |
| **10/12** (T5) | *Chung:* quay video YouTube, ghép `BaoCao_V2.pdf`, `BaoCaoTuDanhGia.pdf` (**thiếu là 0đ**), bảng công việc + đóng góp (lấy từ bảng Tracking), ảnh commit, rà tài liệu AI | *Chung* |

> ✅ **10/12: xong toàn bộ.** 11/12 dự phòng + đóng zip, kiểm checklist 2 lần (mỗi người 1 lần). **12/12 nộp.**

---

## ✔️ DEFINITION OF DONE

Một feature chỉ được tick ✅ trong bảng Tracking khi:
1. Code đã merge vào `main` qua PR có người kia review.
2. Chạy với **server thật** (không phải mock), qua được bước tương ứng trong kịch bản K1–K8.
3. Phía server: có `<Miền>FlowTest` (1 luồng đúng + 1 case bị từ chối) và `protocol.md` đánh dấu ✅.
4. `mvnw test` xanh, kể cả `FxmlLoadTest`, `NavigationTest` có sẵn.
5. Có `plan.md`, `<feature>.md`, dòng `work-log.md` và tracker trong `work-log.md` đã cập nhật (Rule 1–5).

---

## 🎬 KỊCH BẢN DEMO CHUẨN (K1–K8)

Dùng cho cả 3 việc: test ở checkpoint, bug bash, và kịch bản quay video.

| # | Kịch bản | Dùng ở |
|---|---|---|
| K1 | User A, B đăng ký; A đăng nhập máy thứ 2 → máy 1 bị đá ra; admin đăng nhập AdminApp | CP1 |
| K2 | A tìm B, gửi lời mời; B chấp nhận; A thấy B online realtime; A chặn rồi bỏ chặn C | CP1 |
| K3 | A–B chat realtime; B đăng xuất, A gửi tiếp; B đăng nhập thấy tin + badge chưa đọc | CP1 |
| K4 | A xóa vài tin, xóa lịch sử phía mình (B vẫn thấy); tìm và nhảy tới tin; dùng trợ lý AI | CP2 |
| K5 | B quên mật khẩu → nhận email → đăng nhập → thấy banner đổi mật khẩu → đổi | CP2 |
| K6 | B báo cáo spam A; admin khóa A từ báo cáo → A bị đá ra ngay; báo cáo thành "Đã xử lý" | CP2 |
| K7 | A tạo nhóm với B, C; chat; mở DB chỉ thấy ciphertext; thêm D → D không đọc được tin cũ; A (admin cuối) rời nhóm → chuyển quyền | CP3 |
| K8 | Admin: lọc/sắp xếp người dùng, lịch sử đăng nhập, nhóm, A5–A9 và 2 biểu đồ trên dữ liệu demo | CP2 |

---

## ✂️ CẮT GIẢM KHI TRỄ (theo thứ tự, quyết định tại checkpoint)

| Khi nào | Nếu trễ | Làm gì |
|---|---|---|
| Checkpoint 1 | Chat 1-1 chưa chạy | Dời `UPDATE_PROFILE`/`CHANGE_PASSWORD` sang buffer 05/12; cả 2 dồn sức cho SD6 |
| Checkpoint 2 | Chưa xong Admin hoặc ngoại vi | LLM chỉ làm chế độ "Sửa câu"; 2 biểu đồ A6, A9 gộp chung 1 màn hình có combobox |
| 06/12 12h | E2EE chưa gửi/đọc được 1 tin nhóm | **Dự phòng**: server sinh khóa AES cho mỗi epoch nhóm, client mã hóa trước khi gửi. Không phải đổi schema, nhưng vẫn phải ghi đủ `e2ee_devices`, `group_key_epochs` (ACTIVE) và `group_key_grants` của người gửi, vì tin GROUP bắt buộc có `key_epoch_id`, `sender_device_id` và grant tương ứng (F22, F23). Ghi rõ trong báo cáo là "mã hóa lưu trữ, chưa đầu-cuối". Làm trong buffer 07/12 |
| Luôn luôn | — | Mục "Làm thêm" ("đang gõ…", SystemTray, gửi file…) **chỉ làm sau 08/12** nếu còn thời gian. Bỏ chặn **không** phải làm thêm: đã có trong UC-12 và tab Đã chặn ở S06 |

**E2EE tối thiểu (đề xuất cho Q8, mục tiêu của Checkpoint 3):**
- Mỗi tài khoản 1 thiết bị; thiết bị mới không nhận khóa của epoch cũ.
- Xoay khóa khi thêm, xóa, rời nhóm; thành viên mới không đọc được tin cũ.
- **Để sau nếu dư thời gian:** xoay khóa ngay khi một thành viên đổi thiết bị (bản tối thiểu: chỉ xoay ở lần thay đổi thành viên tiếp theo); xử lý epoch kẹt PENDING khi người đang sinh khóa bị mất kết nối giữa chừng.

---

## 📁 CẤU TRÚC FILE NỘP V2 (Checklist)

```
[MSSV1_MSSV2]_v2.zip
├── src/
│   ├── admin/                ← module src/admin (admin.jar)
│   ├── user/                 ← module src/user (user.jar)
│   ├── server/               ← module src/server (server.jar)
│   └── common/               ← module src/common (dùng chung)
├── release/
│   ├── server.jar            ← chạy trước
│   ├── admin.jar
│   ├── user.jar
│   └── config.properties     ← chỉ sửa file này là chạy được cả 3 jar
├── script/
│   └── create_db.sql         ← schema.sql (15 bảng) + demo_data.sql (Q9: có kèm file khác không)
├── git/
│   ├── 24127203_Minh.png     ← chụp lại cho V2 (bản V1 nằm ở nhánh docs/git-commit-history, chưa merge vào main)
│   └── 24127565_Trang.png
├── BaoCao_V2.pdf
│   ├── Thông tin nhóm
│   ├── Danh sách công việc từng thành viên
│   ├── Bảng đóng góp (tổng = 100)
│   ├── Chức năng nổi bật / làm thêm (E2EE, đá phiên realtime, nhảy tới tin nhắn…)
│   ├── Thiết kế hệ thống (kiến trúc 3 jar, giao thức, bảng D1–D43, SD1–SD12)
│   ├── Thiết kế CSDL
│   ├── Hướng dẫn sử dụng (có hình, ghi rõ thứ tự chạy: DB → server.jar → admin/user)
│   ├── Link YouTube demo
│   └── Link GitHub
└── BaoCaoTuDanhGia.pdf       ← theo mẫu, KHÔNG CÓ = 0đ
```

> ℹ️ Đề chỉ yêu cầu `src/` chứa mã nguồn chạy được của 2 phân hệ và **không quy định tên thư mục con** (`Final_Project_He_Thong_Chat_Chi_Tiet.md` §5.1.3, §5.2.2), nên để thêm `server/` và `common/` là được. Muốn chắc thì vẫn hỏi thầy (câu hỏi D1 trong Claude Doc).
> ⚠️ Khi đóng zip: **không** đưa `config.properties` có mật khẩu/API key thật vào `release/`; dùng bản đã xóa giá trị bí mật.

---

## 📂 AI DOCUMENTATION THEO FEATURE

Theo `.agent/rules/rule.md` Rule 6 và nguyên tắc **1 feature = 1 người phụ trách = 1 nhánh**, nên 2 người không sửa chung 1 `plan.md`. Tên thư mục = tên feature = tên nhánh `feature/<tên>` = scope của commit `feat(<tên>): …`. Các dòng tracker cũ trong `docs/ai/work-log.md` (`auth`, `chat-1-1`, `friend-system`…) chưa dùng, ghi chú "→ tách thành …" và thêm dòng mới theo tên dưới đây.

```
docs/
├── ai/
│   ├── work-log.md                 [C] log chung + bảng tracker
│   ├── _template/                  plan.template.md, feature.template.md
│   └── protocol/                   [C] Chung: các đợt chốt protocol.md
├── backend/
│   ├── protocol.md                 [C] hợp đồng giao thức (không phải tài liệu AI)
│   └── ai/
│       ├── socket-server/          [M] 26/11
│       ├── auth-server/            [M] 27/11, 30/11, 02/12 (đăng ký, đăng nhập, hồ sơ, đổi/reset mật khẩu)
│       ├── friend-server/          [M] 28/11
│       ├── chat-1-1-server/        [M] 29/11, 01/12 (gồm ẩn/xóa/tìm/nhảy tới tin)
│       ├── llm-server/             [M] 02/12
│       ├── spam-server/            [M] 02/12
│       ├── group-server/           [M] 03/12, 05/12 (gồm D33)
│       ├── admin-kick-server/      [M] 03/12
│       ├── e2ee-server/            [M] 04/12–06/12
│       └── release-server/         [M] 09/12
├── database/ai/
│   └── demo-data/                  [M] 27/11, 06/12 (demo_data.sql, create_db.sql)
└── frontend/ai/
    ├── socket-client/              [T] 26/11 (AppConfig, ServerConnection, mock)
    ├── auth-ui/                    [T] 27/11, 30/11, 02/12
    ├── friend-ui/                  [T] 28/11
    ├── chat-1-1-ui/                [T] 29/11, 01/12
    ├── llm-ui/                     [T] 02/12
    ├── spam-ui/                    [T] 02/12
    ├── e2ee-client/                [T] 02/12, 05/12–06/12 (CryptoUtil, DeviceKeyStore, luồng khóa)
    ├── group-ui/                   [T] 05/12–06/12
    ├── admin-user-mgmt/            [T] 03/12 (DAO + UI A1–A3)
    ├── admin-spam/                 [T] 04/12 (DAO + UI A4 + KickClient)
    ├── admin-stats/                [T] 04/12 (DAO + UI A5–A9)
    └── release-client/             [T] 09/12
    (mỗi thư mục: plan.md + <feature>.md)
```

Feature kéo dài nhiều ngày thì cứ commit nhỏ hằng ngày trên nhánh của feature đó; chỉ cần **không gộp 2 feature vào 1 commit** (Rule 4).

**Checklist mỗi lần dùng AI (Rule 0–5):** tạo `plan.md` từ `docs/ai/_template/plan.template.md` → người dùng duyệt plan (`PLAN_APPROVED`) → AI sinh code → review + test theo tiêu chí trong plan → đổi hướng thì thêm `[ITERATION X - DD/MM]` vào `plan.md` → viết `<feature>.md` từ `feature.template.md` → ghi `work-log.md` (chỉ ghi thêm, giờ thật, đúng loại action) + cập nhật tracker → commit `feat(<feature>): …`. Không dùng WebSocket (Rule 8). Thời gian cho phần tài liệu này đã tính trong khoảng 6 giờ/ngày.

---

## ⚠️ RISK & MITIGATION

| Risk | Mức độ | Xử lý |
|---|---|---|
| TM1 lần đầu làm backend, là đường găng của cả dự án | 🔴 HIGH | DAO admin đã chuyển sang TM2; ngày 26/11 chỉ dựng khung + chạy được 1 kết nối; `TestClient` để tự test không cần UI; Checkpoint 1 trễ là cắt giảm ngay |
| E2EE nhóm (epoch, grant, xoay khóa) | 🔴 HIGH | `CryptoUtil` có unit test từ 02/12; server làm từ 04/12; quyết định dự phòng trưa 06/12; có định nghĩa "E2EE tối thiểu" |
| Lệch giao thức giữa FE và BE | 🔴 HIGH | `protocol.md` chốt 3 đợt; `MockServerConnection`; merge vào `main` mỗi ngày; review trong 2 giờ |
| Thiếu thời gian vì môn khác chạy song song | 🔴 HIGH | Xác nhận Q3 ngày 26/11; 3 buffer nửa ngày; cắt giảm từ Checkpoint 1 |
| SQL viết tay thiếu kiểm tra quyền/khóa | 🟡 MEDIUM | Dùng lại Q01–Q09 đã test; mỗi feature server có test bị từ chối; bám bảng "ChatServer" trong `database-schema.md` |
| `src/common` kéo JavaFX vào `server.jar` | 🟡 MEDIUM | `javafx-controls` để `optional` trong `common` (26/11) |
| Fat-jar JavaFX không chạy | 🟡 MEDIUM | Build thử `user.jar` ngày 30/11, không đợi tới 09/12 |
| Gmail SMTP / API key LLM | 🟡 MEDIUM | Chốt Q4, Q5 trước 30/11; LLM lỗi thì báo "AI đang bận", không làm mất bản nháp; key chỉ nằm trong `config.properties`, không commit |
| Thống kê A7/A8/A9 sai định nghĩa | 🟡 MEDIUM | Bám D22, D39–D41 và Q02–Q06; đối chiếu bằng tay trên dữ liệu demo |
| Dữ liệu demo đăng nhập không được | 🟡 MEDIUM | `seed.sql` chỉ là fixture (hash giả, chỉ chạy trong DB test); dùng `demo_data.sql` có hash BCrypt thật từ 27/11 |
| Conflict ở file chung (`work-log.md`, `protocol.md`, POM) | 🟢 LOW | Pull trước khi sửa; file chung chỉ sửa qua PR; work-log giữ cả 2 phần khi conflict |
| Thiếu commit / zip sai / thiếu báo cáo tự đánh giá → 0đ | 🔴 HIGH | Commit theo feature mỗi ngày; báo cáo viết dần từ 07/12; 11/12 mỗi người kiểm checklist 1 lần |

---

## 📊 TRACKING V2

| Feature (tên thư mục / nhánh) | Mã | Người | Hạn | Trạng thái |
|---|---|---|---|---|
| protocol (đợt 1 / 2 / 3) | D2 | Chung | 26/11 · 30/11 · 03/12 | ⬜ ⬜ ⬜ |
| socket-server | — | Minh | 26/11 | ⬜ |
| socket-client | — | Trang | 26/11 | ⬜ |
| auth-server | U1–U5 · SD1–SD3 | Minh | 27/11 → 02/12 | ⬜ |
| auth-ui | U1–U5 | Trang | 27/11 → 02/12 | ⬜ |
| demo-data | — | Minh | 27/11 · 06/12 | ⬜ |
| friend-server | U6–U9 · SD4, SD5 | Minh | 28/11 | ⬜ |
| friend-ui | U6–U9 | Trang | 28/11 | ⬜ |
| chat-1-1-server | U11.a–g · SD6, SD7 | Minh | 29/11 · 01/12 | ⬜ |
| chat-1-1-ui | U11.a–g | Trang | 29/11 · 01/12 | ⬜ |
| llm-server / llm-ui | U11.h · SD8 | Minh / Trang | 02/12 | ⬜ / ⬜ |
| spam-server / spam-ui | U10 · SD12 | Minh / Trang | 02/12 | ⬜ / ⬜ |
| group-server | U12.a–e · SD9, SD10 · D33 | Minh | 03/12 · 05/12 | ⬜ |
| admin-kick-server | D12 | Minh | 03/12 | ⬜ |
| admin-user-mgmt | A1–A3 | Trang | 03/12 | ⬜ |
| admin-spam | A4 · SD12 | Trang | 04/12 | ⬜ |
| admin-stats | A5–A9 | Trang | 04/12 | ⬜ |
| e2ee-server | U12.f–g · SD11 | Minh | 04/12 → 06/12 | ⬜ |
| e2ee-client | U12.g | Trang | 02/12 → 06/12 | ⬜ |
| group-ui | U12.a–f · D33 | Trang | 05/12 → 06/12 | ⬜ |
| Bug bash K1–K8, UC01–UC31 | — | Chung | 08/12 | ⬜ |
| release-server / release-client | — | Minh / Trang | 09/12 | ⬜ / ⬜ |
| Báo cáo V2 + tự đánh giá + video | — | Chung | 10/12 | ⬜ |

Ký hiệu: ⬜ chưa làm · 🔄 đang làm · ✅ xong theo Definition of Done.

---

## ✅ PHASE 0 & PHASE 1 — ĐÃ XONG

- Repo GitHub, quy tắc nhánh `main` + `feature/` · `fix/` · `docs/` qua PR (README §4), bộ luật AI `.agent/rules/rule.md` + template `docs/ai/_template/`
- Tech stack (xem `../dumpDocs/framework_recommendations.md` + bảng Thay đổi ở trên), phân tích nghiệp vụ D1–D43, UC, SD
- Maven multi-module `src/common`, `src/user`, `src/admin` (Java 21, JavaFX 21.0.6)
- CSDL: `script/schema.sql` 15 bảng (đã chạy trên PostgreSQL 17.11), `seed.sql` (fixture), `queries.sql` Q01–Q09, `tests/verify.sql`, `tests/negative-cases.md`, `docs/database/design-baseline.md`
- Giao diện V1: User 9 màn hình (S01–S09) + 6 dialog (D01–D06), Admin 8 màn hình (S10–S17) + 2 dialog; ảnh chụp ở `docs/frontend/screens/`
- Đồng bộ CSDL ↔ giao diện ↔ D1–D43 (`docs/ai/db-fe-conflict-fix/`)
- Nộp V1 ngày 22/11

---

*Tài liệu này dựa trên: Final Project.pdf (`docs/Final_Project_He_Thong_Chat_Chi_Tiet.md`), `framework_recommendations.md`, Claude Doc Phân tích nghiệp vụ & Sequence Diagram (D1–D43), và hiện trạng repo ngày 26/11/2026.*
