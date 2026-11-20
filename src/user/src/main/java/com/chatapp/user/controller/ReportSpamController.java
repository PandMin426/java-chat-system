package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import javafx.beans.Observable;
import javafx.beans.binding.Bindings;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.layout.VBox;

import java.util.List;

/** D02 Báo cáo spam. V1: "Gửi báo cáo" is off until a reason is ticked (D37); sending comes with the report-spam feature. */
public class ReportSpamController {

    @FXML
    private VBox reasonBox;
    @FXML
    private Button cancelButton;
    @FXML
    private Button sendButton;

    @FXML
    private void initialize() {
        List<CheckBox> reasons = reasonBox.getChildren().stream().map(n -> (CheckBox) n).toList();
        sendButton.disableProperty().bind(Bindings.createBooleanBinding(
                () -> reasons.stream().noneMatch(CheckBox::isSelected),
                reasons.stream().map(CheckBox::selectedProperty).toArray(Observable[]::new)));
    }

    @FXML
    private void onClose() {
        Navigator.close(cancelButton);
    }
}
