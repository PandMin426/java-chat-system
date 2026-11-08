package com.chatapp.admin;

import javafx.application.Application;
import javafx.stage.Stage;

import java.util.Locale;

/** Entry point of admin.jar. */
public class AdminApp extends Application {

    @Override
    public void start(Stage stage) {
        Locale.setDefault(AdminNavigator.LOCALE);
        AdminNavigator.init(stage);
        stage.setScene(AdminNavigator.scene(AdminNavigator.load("AdminLoginView"), AdminNavigator.WIDTH, AdminNavigator.HEIGHT));
        stage.setTitle("ChatApp — Quản trị");
        stage.setMinWidth(1100);
        stage.setMinHeight(700);
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
