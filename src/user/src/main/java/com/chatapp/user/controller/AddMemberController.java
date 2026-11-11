package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.VBox;

/** D04 Thêm thành viên. V1: same picking as D01 over people not in the group yet; nothing is saved. */
public class AddMemberController {

    @FXML
    private Label memberLabel;
    @FXML
    private FlowPane chipPane;
    @FXML
    private VBox suggestionBox;
    @FXML
    private Button addButton;

    @FXML
    private void initialize() {
        new MemberPicker(memberLabel, "Thành viên mới", chipPane, suggestionBox, addButton,
                SampleData.ADD_MEMBER_PICKED, SampleData.ADD_MEMBER_SUGGESTIONS);
    }

    @FXML
    private void onClose() {
        Navigator.close(addButton);
    }
}
