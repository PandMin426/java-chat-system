package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import javafx.fxml.FXML;
import javafx.scene.control.Button;

/** D02 Báo cáo spam. V1: closes the dialog; sending the report comes with the report-spam feature. */
public class ReportSpamController {

    @FXML
    private Button cancelButton;

    @FXML
    private void onClose() {
        Navigator.close(cancelButton);
    }
}
