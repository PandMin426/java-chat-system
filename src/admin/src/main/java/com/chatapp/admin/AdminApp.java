package com.chatapp.admin;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;

/** Entry point of admin.jar. */
public class AdminApp extends Application {

    @Override
    public void start(Stage stage) {
        Scene scene = new Scene(new BorderPane(), 1280, 800);
        scene.getStylesheets().add(AdminApp.class.getResource("/com/chatapp/common/theme.css").toExternalForm());
        stage.setTitle("ChatApp — Quản trị");
        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
