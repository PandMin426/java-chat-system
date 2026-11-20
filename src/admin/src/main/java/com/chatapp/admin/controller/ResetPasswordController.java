package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import javafx.fxml.FXML;
import javafx.scene.control.Button;

/** Reset password dialog (D10: the admin types the new password). V1: closes only; resetting comes with the admin-users feature. */
public class ResetPasswordController {

    @FXML
    private Button cancelButton;

    @FXML
    private void onClose() {
        AdminNavigator.close(cancelButton);
    }
}
