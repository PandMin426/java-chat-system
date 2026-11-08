package com.chatapp.admin.sample;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Hardcoded sample rows and chart values for V1 screenshots (same names as the prototype).
 * Delete this class when V2 loads real data from the server.
 */
public final class SampleData {

    private SampleData() {
    }

    public record UserRow(String username, String fullName, LocalDate created, boolean online, boolean locked,
                          String email, String gender, LocalDate birthDate, String address) {
    }

    public record LoginRow(LocalDateTime time, String username, String fullName, String ip) {
    }

    public record GroupRow(String name, int members, boolean encrypted, LocalDate created, String creator, int admins) {
    }

    public record GroupMember(String initials, String fullName, String username, boolean admin) {
    }

    public record SpamRow(LocalDateTime time, String username, String fullName, String reporter, String reason, String status) {
    }

    public record NewUserRow(String username, String fullName, String email, LocalDateTime created) {
    }

    public record FriendStatRow(String username, String fullName, LocalDate created, int direct, int withFriendsOfFriends) {
    }

    public record ActiveRow(String username, String fullName, LocalDate created, int appOpens, int peopleChatted, int groupsChatted) {
    }

    /** The last month with data is drawn as the current (partial) month. */
    public static final LocalDate TODAY = LocalDate.of(2026, 11, 8);

    private static LocalDate d(int day, int month, int year) {
        return LocalDate.of(year, month, day);
    }

    private static LocalDateTime t(int day, int month, int hour, int minute) {
        return LocalDateTime.of(2026, month, day, hour, minute);
    }

    public static final List<UserRow> USERS = List.of(
            new UserRow("bich.tran", "Trần Thị Bích", d(12, 9, 2026), true, false, "bich.tran@gmail.com", "Nữ", d(21, 3, 2004), "Thủ Đức, TP.HCM"),
            new UserRow("an.nguyen", "Nguyễn Văn An", d(12, 9, 2026), true, false, "an.nguyen@gmail.com", "Nam", d(12, 5, 2004), "Quận 5, TP.HCM"),
            new UserRow("minh.vo", "Võ Minh", d(14, 9, 2026), true, false, "minh.vo@gmail.com", "Nam", d(2, 1, 2004), "Bình Thạnh, TP.HCM"),
            new UserRow("ha.do", "Đỗ Hà", d(20, 9, 2026), false, false, "ha.do@gmail.com", "Nữ", d(30, 8, 2004), "Gò Vấp, TP.HCM"),
            new UserRow("camly.le", "Lê Cẩm Ly", d(1, 10, 2026), true, false, "camly.le@gmail.com", "Nữ", d(11, 11, 2004), "Quận 7, TP.HCM"),
            new UserRow("dung.pham", "Phạm Quốc Dũng", d(5, 10, 2026), false, false, "dung.pham@gmail.com", "Nam", d(9, 9, 2003), "Biên Hòa, Đồng Nai"),
            new UserRow("kevin.tran", "Kevin Trần", d(28, 10, 2026), false, true, "kevin.t@mail.com", "Nam", d(1, 1, 2000), "—"),
            new UserRow("thu.huynh", "Huỳnh Thư", d(2, 11, 2026), false, false, "thu.huynh@gmail.com", "Nữ", d(17, 2, 2005), "Quận 10, TP.HCM"),
            new UserRow("spam.bot99", "Khuyến Mãi 99", d(4, 11, 2026), false, true, "km99@mail.com", "Khác", null, "—"),
            new UserRow("hoa.nguyen", "Nguyễn Thị Hoa", d(7, 11, 2026), false, false, "hoa.nguyen@gmail.com", "Nữ", d(25, 12, 2004), "Thủ Dầu Một, Bình Dương"));

    /** Login history and friends of the selected user in the detail pane (same rows for every user in V1). */
    public static final List<LoginRow> USER_LOGINS = List.of(
            new LoginRow(t(8, 11, 14, 1), "bich.tran", "Trần Thị Bích", "192.168.1.24"),
            new LoginRow(t(8, 11, 8, 12), "bich.tran", "Trần Thị Bích", "192.168.1.24"),
            new LoginRow(t(7, 11, 21, 30), "bich.tran", "Trần Thị Bích", "10.0.0.7"),
            new LoginRow(t(7, 11, 9, 5), "bich.tran", "Trần Thị Bích", "192.168.1.24"),
            new LoginRow(t(5, 11, 19, 44), "bich.tran", "Trần Thị Bích", "10.0.0.7"));

    public static final List<GroupMember> USER_FRIENDS = List.of(
            new GroupMember("VM", "Võ Minh", "minh.vo", false),
            new GroupMember("CL", "Lê Cẩm Ly", "camly.le", false),
            new GroupMember("ĐH", "Đỗ Hà", "ha.do", false),
            new GroupMember("AN", "Nguyễn Văn An", "an.nguyen", false));

    public static final List<LoginRow> LOGINS = List.of(
            new LoginRow(t(8, 11, 14, 1), "bich.tran", "Trần Thị Bích", "192.168.1.24"),
            new LoginRow(t(8, 11, 13, 47), "an.nguyen", "Nguyễn Văn An", "192.168.1.31"),
            new LoginRow(t(8, 11, 12, 55), "ha.do", "Đỗ Hà", "10.0.0.12"),
            new LoginRow(t(8, 11, 11, 2), "minh.vo", "Võ Minh", "192.168.1.40"),
            new LoginRow(t(8, 11, 9, 15), "camly.le", "Lê Cẩm Ly", "10.0.0.9"),
            new LoginRow(t(8, 11, 8, 12), "bich.tran", "Trần Thị Bích", "192.168.1.24"),
            new LoginRow(t(7, 11, 23, 1), "kevin.tran", "Kevin Trần", "172.16.4.2"),
            new LoginRow(t(7, 11, 21, 30), "bich.tran", "Trần Thị Bích", "10.0.0.7"),
            new LoginRow(t(7, 11, 20, 10), "dung.pham", "Phạm Quốc Dũng", "192.168.1.55"),
            new LoginRow(t(7, 11, 19, 58), "hoa.nguyen", "Nguyễn Thị Hoa", "10.0.0.15"),
            new LoginRow(t(7, 11, 18, 44), "an.nguyen", "Nguyễn Văn An", "192.168.1.31"),
            new LoginRow(t(7, 11, 9, 5), "bich.tran", "Trần Thị Bích", "192.168.1.24"));

    public static final List<GroupRow> GROUPS = List.of(
            new GroupRow("Đồ án Java", 4, true, d(2, 11, 2026), "an.nguyen", 2),
            new GroupRow("CLB Guitar K22", 18, false, d(21, 10, 2026), "ha.do", 3),
            new GroupRow("Lớp 22CTT3", 64, false, d(15, 9, 2026), "minh.vo", 2),
            new GroupRow("Ban cán sự khoa", 9, true, d(30, 9, 2026), "camly.le", 1),
            new GroupRow("Bóng đá thứ 7", 22, false, d(5, 11, 2026), "dung.pham", 1),
            new GroupRow("Nhóm học CTDL", 6, false, d(12, 10, 2026), "bich.tran", 2),
            new GroupRow("Gia đình", 5, true, d(18, 9, 2026), "an.nguyen", 1),
            new GroupRow("Ôn thi cuối kỳ", 31, false, d(7, 11, 2026), "thu.huynh", 2));

    public static final List<GroupMember> GROUP_MEMBERS = List.of(
            new GroupMember("AN", "Nguyễn Văn An", "an.nguyen", true),
            new GroupMember("VM", "Võ Minh", "minh.vo", true),
            new GroupMember("TB", "Trần Thị Bích", "bich.tran", false),
            new GroupMember("ĐH", "Đỗ Hà", "ha.do", false));

    public static final String PENDING = "Chờ xử lý";

    public static final List<SpamRow> SPAM_REPORTS = List.of(
            new SpamRow(t(8, 11, 10, 21), "kevin.tran", "Kevin Trần", "an.nguyen", "Quảng cáo, mời chào", PENDING),
            new SpamRow(t(7, 11, 22, 40), "kevin.tran", "Kevin Trần", "camly.le", "Quảng cáo, mời chào", PENDING),
            new SpamRow(t(7, 11, 15, 5), "spam.bot99", "Khuyến Mãi 99", "minh.vo", "Lừa đảo", PENDING),
            new SpamRow(t(6, 11, 19, 30), "spam.bot99", "Khuyến Mãi 99", "ha.do", "Lừa đảo", PENDING),
            new SpamRow(t(5, 11, 8, 12), "dung.pham", "Phạm Quốc Dũng", "thu.huynh", "Quấy rối, xúc phạm", "Đã khóa"),
            new SpamRow(t(3, 11, 21, 47), "hoa.nguyen", "Nguyễn Thị Hoa", "bich.tran", "Khác", "Bỏ qua"),
            new SpamRow(t(2, 11, 11, 30), "kevin.tran", "Kevin Trần", "minh.vo", "Quảng cáo, mời chào", "Đã khóa"));

    /** New registrations per month (index 0 = January); null = no data yet. */
    public static final Map<Integer, Integer[]> NEW_USERS_BY_MONTH = Map.of(
            2024, new Integer[]{12, 9, 15, 18, 14, 20, 25, 22, 64, 51, 30, 18},
            2025, new Integer[]{28, 24, 35, 40, 33, 45, 48, 41, 97, 88, 52, 31},
            2026, new Integer[]{42, 38, 55, 61, 47, 70, 66, 58, 132, 118, 49, null});

    public static final List<NewUserRow> NEW_USERS = List.of(
            new NewUserRow("hoa.nguyen", "Nguyễn Thị Hoa", "hoa.nguyen@gmail.com", t(7, 11, 19, 40)),
            new NewUserRow("thao.le", "Lê Phương Thảo", "thao.le@gmail.com", t(6, 11, 8, 2)),
            new NewUserRow("spam.bot99", "Khuyến Mãi 99", "km99@mail.com", t(4, 11, 2, 13)),
            new NewUserRow("quang.ho", "Hồ Đăng Quang", "quang.ho@gmail.com", t(3, 11, 15, 27)),
            new NewUserRow("thu.huynh", "Huỳnh Thư", "thu.huynh@gmail.com", t(2, 11, 10, 55)),
            new NewUserRow("bao.quach", "Quách Bảo", "bao.quach@gmail.com", t(1, 11, 21, 8)));

    public static final List<FriendStatRow> FRIEND_STATS = List.of(
            new FriendStatRow("bich.tran", "Trần Thị Bích", d(12, 9, 2026), 12, 58),
            new FriendStatRow("an.nguyen", "Nguyễn Văn An", d(12, 9, 2026), 9, 47),
            new FriendStatRow("minh.vo", "Võ Minh", d(14, 9, 2026), 15, 71),
            new FriendStatRow("ha.do", "Đỗ Hà", d(20, 9, 2026), 7, 39),
            new FriendStatRow("camly.le", "Lê Cẩm Ly", d(1, 10, 2026), 5, 33),
            new FriendStatRow("dung.pham", "Phạm Quốc Dũng", d(5, 10, 2026), 3, 21),
            new FriendStatRow("kevin.tran", "Kevin Trần", d(28, 10, 2026), 0, 0),
            new FriendStatRow("thu.huynh", "Huỳnh Thư", d(2, 11, 2026), 4, 26),
            new FriendStatRow("khang.ngo", "Ngô Khang", d(18, 9, 2026), 8, 44),
            new FriendStatRow("hoa.nguyen", "Nguyễn Thị Hoa", d(7, 11, 2026), 1, 9));

    public static final List<ActiveRow> ACTIVE_USERS = List.of(
            new ActiveRow("bich.tran", "Trần Thị Bích", d(12, 9, 2026), 14, 6, 3),
            new ActiveRow("an.nguyen", "Nguyễn Văn An", d(12, 9, 2026), 11, 5, 2),
            new ActiveRow("minh.vo", "Võ Minh", d(14, 9, 2026), 9, 4, 3),
            new ActiveRow("ha.do", "Đỗ Hà", d(20, 9, 2026), 6, 3, 2),
            new ActiveRow("camly.le", "Lê Cẩm Ly", d(1, 10, 2026), 5, 2, 1),
            new ActiveRow("dung.pham", "Phạm Quốc Dũng", d(5, 10, 2026), 3, 2, 0),
            new ActiveRow("kevin.tran", "Kevin Trần", d(28, 10, 2026), 7, 12, 0),
            new ActiveRow("thu.huynh", "Huỳnh Thư", d(2, 11, 2026), 4, 1, 1),
            new ActiveRow("hoa.nguyen", "Nguyễn Thị Hoa", d(7, 11, 2026), 2, 1, 0));

    /** Distinct users who opened the app per month. */
    public static final Map<Integer, Integer[]> ACTIVE_BY_MONTH = Map.of(
            2025, new Integer[]{180, 172, 210, 225, 198, 160, 140, 155, 390, 420, 410, 300},
            2026, new Integer[]{310, 295, 340, 362, 330, 270, 250, 280, 610, 655, 402, null});
}
