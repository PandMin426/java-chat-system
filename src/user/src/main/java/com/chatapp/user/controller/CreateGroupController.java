package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;

/** D01 Tạo nhóm chat. V1: picking members moves them between the suggestion list and the chips; nothing is saved. */
public class CreateGroupController {

    @FXML
    private Label memberLabel;
    @FXML
    private FlowPane chipPane;
    @FXML
    private VBox suggestionBox;
    @FXML
    private Button createButton;

    @FXML
    private void initialize() {
        new MemberPicker(memberLabel, "Thành viên", chipPane, suggestionBox, createButton,
                SampleData.GROUP_PICKED, SampleData.GROUP_SUGGESTIONS);
    }

    @FXML
    private void onCancel() {
        Navigator.close(createButton);
    }

    @FXML
    private void onCreate() {
        Navigator.close(createButton);
        Navigator.showMain("GroupChatView");
    }
}
