package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import javafx.fxml.FXML;
import javafx.scene.control.Button;

/** Reset password dialog. V1: closes only; resetting and emailing come with the admin-users feature. */
public class ResetPasswordController {

    @FXML
    private Button cancelButton;

    @FXML
    private void onClose() {
        AdminNavigator.close(cancelButton);
    }
}
