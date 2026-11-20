package com.chatapp.user;

import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.control.ButtonBase;
import javafx.scene.control.CheckBox;
import javafx.scene.control.Labeled;
import javafx.scene.control.MenuButton;
import javafx.scene.control.MenuItem;
import javafx.scene.control.RadioButton;
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
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** Clicks through the V1 navigation: every screen and dialog of the inventory must be reachable. */
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
            Navigator.init(s);
            s.setScene(Navigator.scene(Navigator.load("LoginView"), Navigator.WIDTH, Navigator.HEIGHT));
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
            stage.close();
            return null;
        });
    }

    @Test
    void authScreensLinkToEachOther() throws Exception {
        click("Tạo tài khoản");
        assertShows("Tạo tài khoản");
        click("Quay lại đăng nhập");
        assertShows("Đăng nhập ChatApp");
        click("Quên mật khẩu?");
        assertShows("Khởi tạo lại mật khẩu");
        click("Quay lại đăng nhập");
        click("Đăng nhập");
        assertShows("Trợ lý AI");
    }

    @Test
    void railReachesEveryMainView() throws Exception {
        click("Đăng nhập");
        clickRail(1);
        assertShows("Tìm người để kết bạn");
        clickRail(2);
        assertShows("Tìm người dùng");
        clickRail(3);
        assertShows("Đổi mật khẩu");
        clickRail(0);
        assertShows("Trợ lý AI");
        click("Tìm tin nhắn trong mọi cuộc trò chuyện");
        assertShows("Mở cuộc trò chuyện");
        click("Mở cuộc trò chuyện");
        assertShows("Trợ lý AI");
        clickRail(4);
        assertShows("Đăng nhập ChatApp");
    }

    @Test
    void chatOpensEveryDialog() throws Exception {
        click("Đăng nhập");
        click("Nhóm mới");
        assertDialog("Tạo nhóm chat");
        menu("Xóa toàn bộ lịch sử…");
        assertDialog("Xóa toàn bộ lịch sử chat?");
        menu("Hủy kết bạn");
        assertDialog("Hủy kết bạn?");
        menu("Báo cáo spam…");
        assertDialog("Báo cáo spam");
        menu("Chặn người này…");
        assertDialog("Chặn Trần Thị Bích?");
    }

    @Test
    void chatMenuOpensSelectMode() throws Exception {
        click("Đăng nhập");
        // The count label is empty until select mode starts.
        menu("Chọn tin nhắn để xóa");
        assertShows("Đã chọn 0 tin");
        click("Hủy");
    }

    @Test
    void groupAdminMenuOpensConfirm() throws Exception {
        click("Đăng nhập");
        openGroup();
        click("Thêm thành viên");
        assertDialog("Thêm thành viên");
        menu("Xóa khỏi nhóm…");
        assertDialog("Xóa khỏi nhóm?");
    }

    /** D31: at least 3 people including the creator; the sample has exactly 2 others picked. */
    @Test
    void createGroupNeedsThreeMembers() throws Exception {
        click("Đăng nhập");
        click("Nhóm mới");
        assertFalse(dialogButton("Tạo nhóm").isDisabled());
        FxTestSupport.onFx(() -> {
            ((ButtonBase) dialogRoot().lookup(".chip .button")).fire();
            return null;
        });
        assertTrue(dialogButton("Tạo nhóm").isDisabled());
    }

    /** D33: the only admin leaving must pick a new admin first. */
    @Test
    void lastAdminLeavingPicksNewAdmin() throws Exception {
        click("Đăng nhập");
        openGroup();
        click("Rời nhóm");
        assertTrue(dialogButton("Chuyển quyền và rời nhóm").isDisabled());
        FxTestSupport.onFx(() -> {
            ((RadioButton) dialogRoot().lookup(".radio-button")).setSelected(true);
            return null;
        });
        assertFalse(dialogButton("Chuyển quyền và rời nhóm").isDisabled());
        assertDialog("Chuyển quyền admin");
    }

    /** D37: a report needs at least one reason and is only offered from a chat, not from the friend list. */
    @Test
    void spamReportNeedsReason() throws Exception {
        click("Đăng nhập");
        menu("Báo cáo spam…");
        assertFalse(dialogButton("Gửi báo cáo").isDisabled());
        FxTestSupport.onFx(() -> {
            dialogRoot().lookupAll(".check-box").stream()
                    .map(n -> (CheckBox) n)
                    .filter(c -> "Quảng cáo, bán hàng".equals(c.getText()))
                    .forEach(c -> c.setSelected(false));
            return null;
        });
        assertTrue(dialogButton("Gửi báo cáo").isDisabled());
        assertDialog("Báo cáo spam");

        boolean friendMenuReports = FxTestSupport.onFx(() -> {
            TabPane tabs = (TabPane) Navigator.load("FriendsView").lookup(".tab-pane");
            Node allBox = ((ScrollPane) tabs.getTabs().get(0).getContent()).getContent();
            return allBox.lookupAll(".menu-button").stream()
                    .flatMap(n -> ((MenuButton) n).getItems().stream())
                    .anyMatch(i -> i.getText().startsWith("Báo cáo spam"));
        });
        assertFalse(friendMenuReports);
    }

    private Parent root() {
        return stage.getScene().getRoot();
    }

    private void openGroup() throws Exception {
        FxTestSupport.onFx(() -> {
            Navigator.showMain("GroupChatView");
            return null;
        });
    }

    /** Root of the last opened window (a dialog). */
    private static Parent dialogRoot() {
        return Window.getWindows().get(Window.getWindows().size() - 1).getScene().getRoot();
    }

    private static ButtonBase dialogButton(String text) throws Exception {
        return FxTestSupport.onFx(() -> dialogRoot().lookupAll(".button").stream()
                .filter(n -> n instanceof ButtonBase b && text.equals(b.getText()))
                .map(n -> (ButtonBase) n)
                .findFirst()
                .orElseThrow(() -> new AssertionError("no dialog button \"" + text + "\"")));
    }

    private void click(String text) throws Exception {
        FxTestSupport.onFx(() -> {
            ButtonBase button = root().lookupAll("*").stream()
                    .filter(n -> n instanceof ButtonBase b && text.equals(b.getText()))
                    .map(n -> (ButtonBase) n)
                    .findFirst()
                    .orElseThrow(() -> new AssertionError("no button \"" + text + "\""));
            button.fire();
            return null;
        });
    }

    private void clickRail(int index) throws Exception {
        FxTestSupport.onFx(() -> {
            ((ButtonBase) List.copyOf(root().lookupAll(".rail-button")).get(index)).fire();
            return null;
        });
    }

    /** Fires the first menu item with this text in any MenuButton of the current window. */
    private void menu(String text) throws Exception {
        FxTestSupport.onFx(() -> {
            MenuItem item = root().lookupAll(".menu-button").stream()
                    .flatMap(n -> ((MenuButton) n).getItems().stream())
                    .filter(i -> text.equals(i.getText()))
                    .findFirst()
                    .orElseThrow(() -> new AssertionError("no menu item \"" + text + "\""));
            item.fire();
            return null;
        });
    }

    private void assertShows(String text) throws Exception {
        boolean found = FxTestSupport.onFx(() -> containsText(root(), text));
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

    private static boolean containsText(Node node, String text) {
        if (node instanceof Labeled l && text.equals(l.getText())) {
            return true;
        }
        if (node instanceof Parent p) {
            for (Node child : p.getChildrenUnmodifiable()) {
                if (containsText(child, text)) {
                    return true;
                }
            }
        }
        // Skins are not created on a scene that was never shown, so look into ScrollPane and Tab content directly.
        if (node instanceof javafx.scene.control.ScrollPane scroll && scroll.getContent() != null) {
            return containsText(scroll.getContent(), text);
        }
        if (node instanceof javafx.scene.control.TabPane tabs) {
            return tabs.getTabs().stream().anyMatch(t -> text.equals(t.getText())
                    || t.getContent() != null && containsText(t.getContent(), text));
        }
        return false;
    }
}
