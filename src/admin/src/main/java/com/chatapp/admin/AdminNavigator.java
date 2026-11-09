package com.chatapp.admin;

import com.chatapp.admin.controller.AdminMainController;
import com.chatapp.admin.controller.UserFormController;
import com.chatapp.admin.sample.SampleData.UserRow;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.Locale;

/** Switches between the admin login, the main window and dialogs. V1: navigation only, no business logic. */
public final class AdminNavigator {

    public static final String VIEW_DIR = "/com/chatapp/admin/view/";
    public static final double WIDTH = 1280;
    public static final double HEIGHT = 800;
    /** Vietnamese locale so DatePicker shows dd/MM/yyyy and Vietnamese month names. */
    public static final Locale LOCALE = Locale.forLanguageTag("vi-VN");

    private static Stage stage;

    private AdminNavigator() {
    }

    public static void init(Stage primaryStage) {
        stage = primaryStage;
    }

    public static FXMLLoader loader(String view) {
        return new FXMLLoader(AdminNavigator.class.getResource(VIEW_DIR + view + ".fxml"));
    }

    public static Parent load(String view) {
        return load(loader(view));
    }

    public static Parent load(FXMLLoader loader) {
        try {
            return loader.load();
        } catch (IOException e) {
            throw new UncheckedIOException("Cannot load view " + loader.getLocation(), e);
        }
    }

    /** Creates a scene with the shared theme and the admin stylesheet. Width/height -1 = computed size. */
    public static Scene scene(Parent root, double width, double height) {
        Scene scene = new Scene(root, width, height);
        scene.getStylesheets().addAll(
                AdminNavigator.class.getResource("/com/chatapp/common/theme.css").toExternalForm(),
                AdminNavigator.class.getResource("/com/chatapp/admin/admin.css").toExternalForm());
        return scene;
    }

    /** Builds the main window with {@code view} in its content area; the controller is kept as the root's user data. */
    public static Parent buildMain(String view) {
        FXMLLoader loader = loader("AdminMainView");
        Parent root = load(loader);
        AdminMainController main = loader.getController();
        main.setContent(view);
        root.setUserData(main);
        return root;
    }

    public static void showLogin() {
        stage.getScene().setRoot(load("AdminLoginView"));
    }

    /** Swaps the content if the main window is on screen, otherwise replaces the login screen with it. */
    public static void showMain(String view) {
        if (stage.getScene().getRoot().getUserData() instanceof AdminMainController main) {
            main.setContent(view);
        } else {
            stage.getScene().setRoot(buildMain(view));
        }
    }

    /** Add form when {@code user} is null, edit form otherwise. */
    public static Parent buildUserForm(UserRow user) {
        FXMLLoader loader = loader("UserFormDialog");
        Parent root = load(loader);
        UserFormController controller = loader.getController();
        controller.setup(user);
        return root;
    }

    public static void openUserForm(UserRow user) {
        show(buildUserForm(user), user == null ? "Thêm người dùng" : "Sửa thông tin người dùng");
    }

    public static void openDialog(String view, String title) {
        show(load(view), title);
    }

    public static void close(Node node) {
        ((Stage) node.getScene().getWindow()).close();
    }

    private static void show(Parent root, String title) {
        Stage dialog = new Stage();
        dialog.initOwner(stage);
        dialog.initModality(Modality.WINDOW_MODAL);
        dialog.setTitle(title);
        dialog.setResizable(false);
        dialog.setScene(scene(root, -1, -1));
        dialog.show();
    }
}
