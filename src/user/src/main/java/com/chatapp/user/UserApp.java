package com.chatapp.user;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;

/** Entry point of user.jar. */
public class UserApp extends Application {

    @Override
    public void start(Stage stage) {
        Scene scene = new Scene(new BorderPane(), 1280, 800);
        scene.getStylesheets().add(UserApp.class.getResource("/com/chatapp/common/theme.css").toExternalForm());
        stage.setTitle("ChatApp");
        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
