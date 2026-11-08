package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import javafx.fxml.FXML;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;

/** S01 Đăng nhập. V1: navigation only; authentication comes with the auth feature. */
public class LoginController {

    @FXML
    private TextField usernameField;
    @FXML
    private PasswordField passwordField;

    @FXML
    private void onLogin() {
        Navigator.showMain("ChatView");
    }

    @FXML
    private void onRegister() {
        Navigator.showAuth("RegisterView");
    }

    @FXML
    private void onForgotPassword() {
        Navigator.showAuth("ForgotPasswordView");
    }
}
