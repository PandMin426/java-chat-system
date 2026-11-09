package com.chatapp.user;

import com.chatapp.user.controller.ConfirmController;
import com.chatapp.user.controller.MainController;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.Locale;

/** Switches between the auth screens, the main window and dialogs. V1: navigation only, no business logic. */
public final class Navigator {

    public static final String VIEW_DIR = "/com/chatapp/user/view/";
    public static final double WIDTH = 1280;
    public static final double HEIGHT = 800;
    /** Vietnamese locale so DatePicker shows dd/MM/yyyy and Vietnamese month names. */
    public static final Locale LOCALE = Locale.forLanguageTag("vi-VN");

    private static Stage stage;

    private Navigator() {
    }

    public static void init(Stage primaryStage) {
        stage = primaryStage;
    }

    public static FXMLLoader loader(String view) {
        return new FXMLLoader(Navigator.class.getResource(VIEW_DIR + view + ".fxml"));
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

    /** Creates a scene with the shared theme and the user-app stylesheet. Width/height -1 = computed size. */
    public static Scene scene(Parent root, double width, double height) {
        Scene scene = new Scene(root, width, height);
        scene.getStylesheets().addAll(
                Navigator.class.getResource("/com/chatapp/common/theme.css").toExternalForm(),
                Navigator.class.getResource("/com/chatapp/user/user.css").toExternalForm());
        return scene;
    }

    /** Builds the main window with {@code view} in its content area; the controller is kept as the root's user data. */
    public static Parent buildMain(String view) {
        FXMLLoader loader = loader("MainView");
        Parent root = load(loader);
        MainController main = loader.getController();
        main.setContent(view);
        root.setUserData(main);
        return root;
    }

    public static void showAuth(String view) {
        stage.getScene().setRoot(load(view));
    }

    /** Swaps the content if the main window is on screen, otherwise replaces the auth screen with it. */
    public static void showMain(String view) {
        if (stage.getScene().getRoot().getUserData() instanceof MainController main) {
            main.setContent(view);
        } else {
            stage.getScene().setRoot(buildMain(view));
        }
    }

    public static void openDialog(String view, String title) {
        show(load(view), title);
    }

    public static Parent buildConfirm(String title, String message, String note, String confirmText) {
        FXMLLoader loader = loader("ConfirmDialog");
        Parent root = load(loader);
        ConfirmController controller = loader.getController();
        controller.setup(title, message, note, confirmText);
        return root;
    }

    public static void openConfirm(String title, String message, String note, String confirmText) {
        show(buildConfirm(title, message, note, confirmText), title);
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
