package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;

/** S03 Quên mật khẩu. V1: navigation only; sending the email comes with the email-reset-pw feature. */
public class ForgotPasswordController {

    @FXML
    private TextField usernameField;
    @FXML
    private TextField emailField;
    @FXML
    private Label errorLabel;
    @FXML
    private VBox sentNote;

    @FXML
    private void onBack() {
        Navigator.showAuth("LoginView");
    }
}
