package com.chatapp.user;

import javafx.application.Application;
import javafx.stage.Stage;

import java.util.Locale;

/** Entry point of user.jar. */
public class UserApp extends Application {

    @Override
    public void start(Stage stage) {
        Locale.setDefault(Navigator.LOCALE);
        Navigator.init(stage);
        stage.setScene(Navigator.scene(Navigator.load("LoginView"), Navigator.WIDTH, Navigator.HEIGHT));
        stage.setTitle("ChatApp");
        stage.setMinWidth(1100);
        stage.setMinHeight(700);
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
