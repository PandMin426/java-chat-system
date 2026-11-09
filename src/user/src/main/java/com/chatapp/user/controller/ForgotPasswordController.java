package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import javafx.fxml.FXML;
import javafx.scene.control.TextField;

/** S03 Quên mật khẩu. V1: navigation only; sending the email comes with the email-reset-pw feature. */
public class ForgotPasswordController {

    @FXML
    private TextField usernameField;
    @FXML
    private TextField emailField;

    @FXML
    private void onBack() {
        Navigator.showAuth("LoginView");
    }
}
