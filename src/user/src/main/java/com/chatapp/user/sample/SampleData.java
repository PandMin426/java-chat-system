package com.chatapp.user.sample;

import java.util.List;

/**
 * Hardcoded sample rows for V1 screenshots (same names as the prototype).
 * Delete this class when V2 loads real data from the server.
 */
public final class SampleData {

    private SampleData() {
    }

    public record Conversation(String initials, String name, String preview, String time,
                               boolean online, boolean group, boolean encrypted, int unread, String tag) {
    }

    public enum Kind { DAY, SYSTEM, IN, OUT }

    /** One line in a chat: a day separator, a system line, or an incoming/outgoing message. */
    public record Message(Kind kind, String sender, String initials, String text, String hit, String after,
                          String meta, boolean focus) {

        public static Message day(String text) {
            return new Message(Kind.DAY, null, null, text, null, null, null, false);
        }

        public static Message system(String text) {
            return new Message(Kind.SYSTEM, null, null, text, null, null, null, false);
        }

        public static Message in(String text, String meta) {
            return new Message(Kind.IN, null, null, text, null, null, meta, false);
        }

        public static Message out(String text, String meta) {
            return new Message(Kind.OUT, null, null, text, null, null, meta, false);
        }

        public static Message groupIn(String sender, String initials, String text, String meta) {
            return new Message(Kind.IN, sender, initials, text, null, null, meta, false);
        }

        public static Message hit(Kind kind, String text, String hit, String after, String meta, boolean focus) {
            return new Message(kind, null, null, text, hit, after, meta, focus);
        }
    }

    public record Person(String initials, String name, String username, String sub, boolean online) {
    }

    public enum Relation { NONE, SENT, INCOMING, FRIEND }

    public record SearchUser(String initials, String name, String username, String sub, Relation relation) {
    }

    public record Member(String initials, String name, boolean online, boolean admin, boolean me) {
    }

    public record SearchHit(String conversation, String initials, boolean group, String who,
                            String text, String hit, String after, String time) {
    }

    public static final List<Conversation> CONVERSATIONS = List.of(
            new Conversation("TB", "Trần Thị Bích", "Mình đẩy code lên nhánh feature/socket-client rồi.", "14:25", true, false, false, 0, null),
            new Conversation("ĐA", "Đồ án Java", "Minh: Ok mai họp lúc 8h", "13:02", false, true, true, 2, null),
            new Conversation("CL", "Lê Cẩm Ly", "Bạn gửi giúp mình tài liệu đồ án với", "11:15", true, false, false, 0, null),
            new Conversation("PD", "Phạm Quốc Dũng", "Bạn: Mai gửi bạn bản báo cáo nhé", "Hôm qua", false, false, false, 0, null),
            new Conversation("KT", "kevin.tran", "Nhận code hộ đồ án giá rẻ, inbox ngay", "06/11", false, false, false, 0, "Người lạ"),
            new Conversation("CG", "CLB Guitar K22", "Hà: Thứ 7 tập ở phòng C.201", "04/11", false, true, false, 0, null));

    public static final List<String> ONLINE_FRIENDS = List.of("TB", "CL", "VM", "ĐH");

    public static final List<Message> CHAT = List.of(
            Message.system("Cuộn lên để tải thêm tin cũ hơn"),
            Message.day("Hôm nay · 08/11/2026"),
            Message.in("Chào An, phần màn hình đăng nhập xong chưa?", "09:12"),
            Message.hit(Kind.OUT, "Xong rồi, mình đang chỉnh lại ", "giao diện", " phần đăng ký.", "09:14 · Đã nhận", false),
            Message.in("Ok, nhớ thêm thông báo lỗi khi trùng tên đăng nhập nhé.", "09:15"),
            Message.out("Đã thêm. Màn hình quên mật khẩu cũng có rồi.", "09:20 · Đã nhận"),
            Message.hit(Kind.IN, "Tối nay mình ghép ", "giao diện", " với socket server được không?", "14:22", true),
            Message.in("Mình đẩy code lên nhánh feature/socket-client rồi.", "14:25"));

    public static final List<String> AI_SUGGESTIONS = List.of(
            "Được nha, 8 giờ tối nay mình online ghép luôn.",
            "Ok, để mình pull nhánh feature/socket-client về chạy thử trước.",
            "Tối nay hơi bận, mai 7 giờ sáng được không?");

    public static final List<Message> GROUP_CHAT = List.of(
            Message.system("An đã tạo nhóm “Nhóm đồ án” · Tin nhắn trong nhóm được mã hóa khi lưu trữ"),
            Message.day("Hôm qua · 07/11/2026"),
            Message.system("Minh đã đổi tên nhóm thành “Đồ án Java”"),
            Message.groupIn("Võ Minh", "VM", "Script tạo database mình đẩy lên rồi, mọi người pull về chạy thử nhé.", "21:40"),
            Message.out("Ok, mình ghép thử với màn hình đăng ký.", "21:45"),
            Message.day("Hôm nay · 08/11/2026"),
            Message.system("An đã xóa Phạm Quốc Dũng khỏi nhóm"),
            Message.system("An đã thêm Đỗ Hà vào nhóm"),
            Message.groupIn("Đỗ Hà", "ĐH", "Chào cả nhóm, mình phụ trách phần biểu đồ thống kê.", "12:58"),
            Message.groupIn("Võ Minh", "VM", "Ok mai họp lúc 8h", "13:02"));

    public static final List<Member> GROUP_MEMBERS = List.of(
            new Member("AN", "Nguyễn Văn An (bạn)", true, true, true),
            new Member("VM", "Võ Minh", true, true, false),
            new Member("TB", "Trần Thị Bích", true, false, false),
            new Member("ĐH", "Đỗ Hà", false, false, false));

    public static final List<SearchHit> SEARCH_HITS = List.of(
            new SearchHit("Đồ án Java", "ĐA", true, "Minh: ", "Nhớ nộp ", "báo cáo", " V1 trước 19h30 nhé", "07/11 21:50"),
            new SearchHit("Đồ án Java", "ĐA", true, "Bạn: ", "Mình viết phần ", "báo cáo", " thiết kế CSDL", "05/11 10:02"),
            new SearchHit("Đồ án Java", "ĐA", true, "Hà: ", "Mẫu ", "báo cáo", " tự đánh giá ở đâu vậy?", "03/11 16:40"),
            new SearchHit("Phạm Quốc Dũng", "PD", false, "Bạn: ", "Mai gửi bạn bản ", "báo cáo", " nhé", "07/11 20:15"),
            new SearchHit("kevin.tran", "KT", false, "", "Viết hộ ", "báo cáo", " đồ án giá rẻ", "06/11 23:01"));

    public static final List<Person> FRIENDS = List.of(
            new Person("TB", "Trần Thị Bích", "bich.tran", "Đang online", true),
            new Person("CL", "Lê Cẩm Ly", "camly.le", "Đang online", true),
            new Person("VM", "Võ Minh", "minh.vo", "Đang online", true),
            new Person("ĐH", "Đỗ Hà", "ha.do", "Đang online", true),
            new Person("PD", "Phạm Quốc Dũng", "dung.pham", "Hoạt động 2 giờ trước", false),
            new Person("NK", "Ngô Khang", "khang.ngo", "Hoạt động hôm qua", false),
            new Person("HT", "Huỳnh Thư", "thu.huynh", "Hoạt động 05/11", false));

    public static final List<Person> FRIEND_REQUESTS = List.of(
            new Person("LP", "Lâm Phong", "phong.lam", "Gửi lúc 14:02 hôm nay", false),
            new Person("MT", "Mai Trâm", "tram.mai", "Gửi lúc 09:40 hôm nay", false),
            new Person("QB", "Quách Bảo", "bao.quach", "Gửi ngày 06/11", false));

    public static final List<Person> BLOCKED = List.of(
            new Person("KT", "Kevin Trần", "kevin.tran", "Đã chặn ngày 06/11", false));

    public static final List<SearchUser> SEARCH_USERS = List.of(
            new SearchUser("NH", "Nguyễn Thị Hoa", "hoa.nguyen", " · 2 bạn chung", Relation.NONE),
            new SearchUser("NT", "Nguyễn Minh Tuấn", "tuan.nguyen", "", Relation.SENT),
            new SearchUser("NL", "Nguyễn Gia Linh", "linh.ng", " · đã gửi lời mời cho bạn", Relation.INCOMING),
            new SearchUser("NK", "Ngô Khang", "nguyenkhang", "", Relation.FRIEND));

    /** Members already picked in the create-group dialog, then suggestions for the typed text "h". */
    public static final List<Person> GROUP_PICKED = List.of(
            new Person("VM", "Võ Minh", "minh.vo", "", true),
            new Person("TB", "Trần Thị Bích", "bich.tran", "", true));

    public static final List<Person> GROUP_SUGGESTIONS = List.of(
            new Person("ĐH", "Đỗ Hà", "ha.do", "Đang online", true),
            new Person("HT", "Huỳnh Thư", "thu.huynh", "", false),
            new Person("NH", "Nguyễn Thị Hoa", "hoa.nguyen", "Chưa là bạn", false));
}
