package com.chatapp.user;

import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.image.PixelReader;
import javafx.scene.image.WritableImage;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.function.Supplier;

/**
 * Saves a PNG of every user screen for the V1 report. Not part of the normal test run; start it with
 * {@code .\mvnw.cmd -pl src/user test -Dtest=ScreenshotTool}. Output: {@code docs/screens/user/}.
 */
class ScreenshotTool {

    @BeforeAll
    static void startToolkit() {
        FxTestSupport.startToolkit();
    }

    @Test
    void saveAllScreens() throws Exception {
        Path out = Path.of(System.getProperty("screens.dir", "../../docs/screens/user"));
        Files.createDirectories(out);

        Map<String, Supplier<Parent>> windows = new LinkedHashMap<>();
        windows.put("S01-dang-nhap", () -> Navigator.load("LoginView"));
        windows.put("S02-dang-ky", () -> Navigator.load("RegisterView"));
        windows.put("S03-quen-mat-khau", () -> Navigator.load("ForgotPasswordView"));
        windows.put("S04-tro-chuyen", () -> Navigator.buildMain("ChatView"));
        windows.put("S05-nhom-chat", () -> Navigator.buildMain("GroupChatView"));
        windows.put("S06-ban-be", () -> Navigator.buildMain("FriendsView"));
        windows.put("S07-tim-nguoi-dung", () -> Navigator.buildMain("SearchUsersView"));
        windows.put("S08-tim-tin-nhan", () -> Navigator.buildMain("SearchMessagesView"));
        windows.put("S09-ho-so", () -> Navigator.buildMain("ProfileView"));
        for (Map.Entry<String, Supplier<Parent>> e : windows.entrySet()) {
            save(e.getValue(), Navigator.WIDTH, Navigator.HEIGHT, out.resolve(e.getKey() + ".png"));
        }

        save(() -> Navigator.load("CreateGroupDialog"), -1, -1, out.resolve("D01-tao-nhom.png"));
        save(() -> Navigator.load("ReportSpamDialog"), -1, -1, out.resolve("D02-bao-cao-spam.png"));
        save(() -> Navigator.buildConfirm("Xóa toàn bộ lịch sử chat?",
                "Toàn bộ tin nhắn với Trần Thị Bích sẽ bị xóa ở phía bạn. Người kia vẫn xem được cuộc trò chuyện.",
                "Không thể hoàn tác.", "Xóa lịch sử"), -1, -1, out.resolve("D03-xoa-lich-su.png"));
        save(() -> Navigator.buildConfirm("Chặn kevin.tran?",
                "Người này sẽ bị xóa khỏi danh sách bạn bè và lời mời, không tìm thấy bạn, "
                        + "không gửi lời mời kết bạn và không nhắn tin 1-1 được với bạn.",
                "Bạn có thể bỏ chặn trong Bạn bè › Đã chặn.", "Chặn"), -1, -1, out.resolve("D05-chan.png"));
        System.out.println("Screenshots saved to " + out.toAbsolutePath().normalize());
    }

    private static void save(Supplier<Parent> view, double width, double height, Path file) throws Exception {
        BufferedImage image = FxTestSupport.onFx(() -> {
            Scene scene = Navigator.scene(view.get(), width, height);
            // The first pass lets list cells created during layout get their CSS, like a second pulse on screen.
            scene.snapshot(null);
            return toBufferedImage(scene.snapshot(null));
        });
        ImageIO.write(image, "png", file.toFile());
    }

    private static BufferedImage toBufferedImage(WritableImage fx) {
        int w = (int) fx.getWidth();
        int h = (int) fx.getHeight();
        BufferedImage image = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
        PixelReader reader = fx.getPixelReader();
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                image.setRGB(x, y, reader.getArgb(x, y));
            }
        }
        return image;
    }
}
