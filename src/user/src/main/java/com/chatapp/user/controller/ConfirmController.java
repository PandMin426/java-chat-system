package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;

/** D03/D05 generic confirmation. V1: both buttons just close the dialog. */
public class ConfirmController {

    @FXML
    private Label titleLabel;
    @FXML
    private Label messageLabel;
    @FXML
    private Label noteLabel;
    @FXML
    private Button cancelButton;
    @FXML
    private Button confirmButton;

    public void setup(String title, String message, String note, String confirmText) {
        titleLabel.setText(title);
        messageLabel.setText(message);
        noteLabel.setText(note);
        noteLabel.setVisible(!note.isEmpty());
        noteLabel.setManaged(!note.isEmpty());
        confirmButton.setText(confirmText);
    }

    @FXML
    private void onClose() {
        Navigator.close(cancelButton);
    }
}
