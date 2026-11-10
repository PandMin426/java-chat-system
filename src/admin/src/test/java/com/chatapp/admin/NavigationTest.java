package com.chatapp.admin;

import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.chart.BarChart;
import javafx.scene.chart.XYChart;
import javafx.scene.control.ButtonBase;
import javafx.scene.control.Labeled;
import javafx.scene.control.ScrollPane;
import javafx.scene.control.TabPane;
import javafx.stage.Stage;
import javafx.stage.Window;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** Clicks through the admin navigation: every screen and dialog of the inventory must be reachable. */
class NavigationTest {

    private Stage stage;

    @BeforeAll
    static void startToolkit() {
        FxTestSupport.startToolkit();
    }

    @BeforeEach
    void openLogin() throws Exception {
        stage = FxTestSupport.onFx(() -> {
            Stage s = new Stage();
            AdminNavigator.init(s);
            s.setScene(AdminNavigator.scene(AdminNavigator.load("AdminLoginView"), AdminNavigator.WIDTH, AdminNavigator.HEIGHT));
            return s;
        });
    }

    @AfterEach
    void closeWindows() throws Exception {
        FxTestSupport.onFx(() -> {
            for (Window w : List.copyOf(Window.getWindows())) {
                if (w instanceof Stage s) {
                    s.close();
                }
            }
            return null;
        });
    }

    @Test
    void navigationReachesEveryScreen() throws Exception {
        click("Đăng nhập");
        assertShows("Đặt lại mật khẩu");
        click("Nhật ký đăng nhập");
        assertShows("1.932 lượt đăng nhập");
        click("Nhóm chat");
        assertShows("86 nhóm");
        click("Báo cáo spam");
        // Row buttons live in table cells, which exist only once the table is skinned; check the page text.
        assertShows("Mỗi dòng là một lần báo cáo. Khóa tài khoản sẽ ngắt kết nối người đó ngay nếu đang online.");
        click("Đăng ký mới");
        assertShows("Người dùng đăng ký mới");
        click("Số lượng bạn bè");
        assertShows("4 người phù hợp");
        click("Người dùng hoạt động");
        assertShows("Lượt mở ứng dụng");
        click("Người dùng");
        assertShows("Thêm người dùng");
        click("Đăng xuất");
        assertShows("Đăng nhập quản trị hệ thống");
    }

    @Test
    void userScreenOpensEveryDialog() throws Exception {
        click("Đăng nhập");
        click("Thêm người dùng");
        assertDialog("Thêm người dùng");
        click("Sửa");
        assertDialog("Sửa thông tin người dùng");
        click("Đặt lại mật khẩu");
        assertDialog("Đặt lại mật khẩu");
    }

    @Test
    void chartsShowTwelveMonthsAndSwitchYear() throws Exception {
        click("Đăng nhập");
        click("Đăng ký mới");
        assertEquals(11, barCount(), "2026 has data for T1–T11");
        click("2025");
        assertEquals(12, barCount(), "2025 has data for every month");
        click("Người dùng hoạt động");
        assertEquals(11, barCount());
    }

    private Parent root() {
        return stage.getScene().getRoot();
    }

    private void click(String text) throws Exception {
        FxTestSupport.onFx(() -> {
            ButtonBase button = all(root()).stream()
                    .filter(n -> n instanceof ButtonBase b && text.equals(b.getText()))
                    .map(n -> (ButtonBase) n)
                    .findFirst()
                    .orElseThrow(() -> new AssertionError("no button \"" + text + "\""));
            button.fire();
            return null;
        });
    }

    private int barCount() throws Exception {
        return FxTestSupport.onFx(() -> all(root()).stream()
                .filter(n -> n instanceof BarChart<?, ?>)
                .map(n -> (BarChart<?, ?>) n)
                .findFirst()
                .map(chart -> chart.getData().stream().mapToInt(s -> s.getData().size()).sum())
                .orElseThrow(() -> new AssertionError("no chart on screen")));
    }

    private void assertShows(String text) throws Exception {
        boolean found = FxTestSupport.onFx(() -> all(root()).stream()
                .anyMatch(n -> n instanceof Labeled l && text.equals(l.getText()))
                || all(root()).stream().anyMatch(n -> n instanceof TabPane t
                && t.getTabs().stream().anyMatch(tab -> text.equals(tab.getText()))));
        assertTrue(found, "current screen does not show \"" + text + "\"");
    }

    /** The last opened window must be a dialog with this title; it is closed afterwards. */
    private void assertDialog(String title) throws Exception {
        String shown = FxTestSupport.onFx(() -> {
            Stage dialog = (Stage) Window.getWindows().get(Window.getWindows().size() - 1);
            String t = dialog.getTitle();
            dialog.close();
            return t;
        });
        assertEquals(title, shown);
    }

    /** Every node, also inside ScrollPane and Tab content (no skins exist on a scene that was never shown). */
    private static List<Node> all(Node node) {
        java.util.ArrayList<Node> out = new java.util.ArrayList<>();
        collect(node, out);
        return out;
    }

    private static void collect(Node node, List<Node> out) {
        out.add(node);
        if (node instanceof ScrollPane scroll && scroll.getContent() != null) {
            collect(scroll.getContent(), out);
        }
        if (node instanceof TabPane tabs) {
            tabs.getTabs().stream().filter(t -> t.getContent() != null).forEach(t -> collect(t.getContent(), out));
        }
        if (node instanceof Labeled labeled && labeled.getGraphic() != null) {
            collect(labeled.getGraphic(), out);
        }
        if (node instanceof Parent parent && !(node instanceof XYChart<?, ?>)) {
            parent.getChildrenUnmodifiable().forEach(child -> collect(child, out));
        }
    }
}
