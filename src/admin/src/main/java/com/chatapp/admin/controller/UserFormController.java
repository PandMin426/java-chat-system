package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import com.chatapp.admin.sample.SampleData.UserRow;
import com.chatapp.common.DateFields;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;

/** Add / edit user form. V1: fills the fields; saving and validation come with the admin-users feature. */
public class UserFormController {

    @FXML
    private Label titleLabel;
    @FXML
    private TextField usernameField;
    @FXML
    private Label usernameHint;
    @FXML
    private TextField fullNameField;
    @FXML
    private TextField emailField;
    @FXML
    private DatePicker birthDatePicker;
    @FXML
    private ComboBox<String> genderBox;
    @FXML
    private TextField addressField;
    @FXML
    private VBox passwordRow;
    @FXML
    private Button cancelButton;
    @FXML
    private Button saveButton;

    /** Add mode when {@code user} is null: empty fields and an initial password; edit mode locks the username. */
    public void setup(UserRow user) {
        DateFields.useDayMonthYear(birthDatePicker);
        boolean edit = user != null;
        titleLabel.setText(edit ? "Sửa thông tin người dùng" : "Thêm người dùng");
        saveButton.setText(edit ? "Lưu thay đổi" : "Tạo tài khoản");
        usernameField.setDisable(edit);
        usernameHint.setVisible(edit);
        usernameHint.setManaged(edit);
        passwordRow.setVisible(!edit);
        passwordRow.setManaged(!edit);
        if (edit) {
            usernameField.setText(user.username());
            fullNameField.setText(user.fullName());
            emailField.setText(user.email());
            birthDatePicker.setValue(user.birthDate());
            genderBox.setValue(user.gender());
            addressField.setText(user.address());
        } else {
            genderBox.setValue("Nữ");
        }
    }

    @FXML
    private void onClose() {
        AdminNavigator.close(cancelButton);
    }
}
