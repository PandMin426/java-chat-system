package com.chatapp.user.controller;

import com.chatapp.common.DateFields;
import com.chatapp.common.GenderFields;
import com.chatapp.user.Navigator;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;

/** S02 Đăng ký. V1: navigation only; validation and saving come with the auth feature. */
public class RegisterController {

    @FXML
    private TextField usernameField;
    @FXML
    private TextField fullNameField;
    @FXML
    private TextField emailField;
    @FXML
    private PasswordField passwordField;
    @FXML
    private PasswordField confirmPasswordField;
    @FXML
    private DatePicker birthDatePicker;
    @FXML
    private ComboBox<String> genderBox;
    @FXML
    private TextField addressField;
    @FXML
    private Label usernameError;
    @FXML
    private Label emailError;
    @FXML
    private Label confirmPasswordError;

    @FXML
    private void initialize() {
        DateFields.useDayMonthYear(birthDatePicker);
        GenderFields.setup(genderBox);
    }

    @FXML
    private void onRegister() {
        Navigator.showAuth("LoginView");
    }

    @FXML
    private void onBack() {
        Navigator.showAuth("LoginView");
    }
}
