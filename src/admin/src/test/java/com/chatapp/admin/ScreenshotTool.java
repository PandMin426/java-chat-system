package com.chatapp.admin;

import com.chatapp.admin.sample.SampleData;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.TabPane;
import javafx.scene.image.PixelReader;
import javafx.scene.image.WritableImage;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.function.Supplier;

/**
 * Saves a PNG of every admin screen for the V1 report. Not part of the normal test run; start it with
 * {@code .\mvnw.cmd -pl src/admin test -Dtest=ScreenshotTool}. Output: {@code docs/screens/admin/}.
 */
class ScreenshotTool {

    @BeforeAll
    static void startToolkit() {
        FxTestSupport.startToolkit();
    }

    @Test
    void saveAllScreens() throws Exception {
        Path out = Path.of(System.getProperty("screens.dir", "../../docs/screens/admin"));
        Files.createDirectories(out);
        double w = AdminNavigator.WIDTH;
        double h = AdminNavigator.HEIGHT;

        save(() -> AdminNavigator.load("AdminLoginView"), w, h, out.resolve("S10-dang-nhap-quan-tri.png"));
        save(() -> AdminNavigator.buildMain("UsersView"), w, h, out.resolve("S11-nguoi-dung.png"));
        save(() -> AdminNavigator.buildUserForm(null), -1, -1, out.resolve("S11a-them-nguoi-dung.png"));
        save(() -> AdminNavigator.buildUserForm(SampleData.USERS.get(0)), -1, -1, out.resolve("S11b-sua-nguoi-dung.png"));
        save(() -> AdminNavigator.load("ResetPasswordDialog"), -1, -1, out.resolve("S11c-dat-lai-mat-khau.png"));
        save(() -> AdminNavigator.buildMain("LoginLogView"), w, h, out.resolve("S12-nhat-ky-dang-nhap.png"));
        save(() -> AdminNavigator.buildMain("GroupsView"), w, h, out.resolve("S13-nhom-chat.png"));
        save(() -> AdminNavigator.buildMain("SpamView"), w, h, out.resolve("S14-bao-cao-spam.png"));
        save(() -> AdminNavigator.buildMain("NewUsersView"), w, h, out.resolve("S15a-dang-ky-moi-bieu-do.png"));
        save(() -> withTab(AdminNavigator.buildMain("NewUsersView"), 1), w, h, out.resolve("S15b-dang-ky-moi-danh-sach.png"));
        save(() -> AdminNavigator.buildMain("FriendStatsView"), w, h, out.resolve("S16-so-luong-ban-be.png"));
        save(() -> AdminNavigator.buildMain("ActiveUsersView"), w, h, out.resolve("S17a-hoat-dong-danh-sach.png"));
        save(() -> withTab(AdminNavigator.buildMain("ActiveUsersView"), 1), w, h, out.resolve("S17b-hoat-dong-bieu-do.png"));
        System.out.println("Screenshots saved to " + out.toAbsolutePath().normalize());
    }

    /** Selects tab {@code index} of the first TabPane in the page (the page tabs, not the detail pane). */
    private static Parent withTab(Parent root, int index) {
        TabPane tabs = (TabPane) root.lookup(".page-tabs");
        tabs.getSelectionModel().select(index);
        return root;
    }

    private static void save(Supplier<Parent> view, double width, double height, Path file) throws Exception {
        BufferedImage image = FxTestSupport.onFx(() -> {
            Scene scene = AdminNavigator.scene(view.get(), width, height);
            // The first pass lets cells and chart bars created during layout get their CSS, like a second pulse on screen.
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
