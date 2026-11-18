package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.Member;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.RadioButton;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.VBox;

/** D06 Chuyển quyền admin. V1: picking a member enables the confirm button; nothing is saved. */
public class TransferAdminController {

    @FXML
    private VBox memberBox;
    @FXML
    private Button cancelButton;
    @FXML
    private Button confirmButton;

    private final ToggleGroup choice = new ToggleGroup();

    @FXML
    private void initialize() {
        for (Member m : SampleData.GROUP_MEMBERS) {
            if (!m.me()) {
                RadioButton option = new RadioButton(m.name());
                option.setGraphic(ChatViews.avatar(m.initials(), m.online(), "sm"));
                option.setToggleGroup(choice);
                option.getStyleClass().add("radio-row");
                option.setMaxWidth(Double.MAX_VALUE);
                memberBox.getChildren().add(option);
            }
        }
        confirmButton.disableProperty().bind(choice.selectedToggleProperty().isNull());
    }

    @FXML
    private void onClose() {
        Navigator.close(cancelButton);
    }

    @FXML
    private void onConfirm() {
        Navigator.close(cancelButton);
        Navigator.showMain("ChatView");
    }
}
