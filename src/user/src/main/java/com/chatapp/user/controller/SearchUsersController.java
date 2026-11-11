package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.SearchUser;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

/** S07 Tìm người dùng. V1: sample results for the query "nguyễn"; the relation button toggles locally. */
public class SearchUsersController {

    @FXML
    private VBox resultBox;

    @FXML
    private void initialize() {
        for (SearchUser u : SampleData.SEARCH_USERS) {
            resultBox.getChildren().add(row(u));
        }
    }

    private Node row(SearchUser u) {
        Label name = new Label(u.name());
        name.getStyleClass().add("strong");
        Label username = new Label(u.username());
        username.getStyleClass().addAll("mono", "small", "muted");
        Label sub = new Label(u.sub());
        sub.getStyleClass().addAll("small", "muted");
        VBox text = new VBox(2, name, new HBox(0, username, sub));
        HBox.setHgrow(text, Priority.ALWAYS);
        HBox row = new HBox(12, ChatViews.avatar(u.initials(), null), text);
        row.getChildren().addAll(actions(u));
        // Anyone found can be messaged or put in a new group, friend or not.
        Button chat = button("Nhắn tin", "sm");
        chat.setOnAction(e -> Navigator.showMain("ChatView"));
        Button group = button("Tạo nhóm", "sm");
        group.setOnAction(e -> Navigator.openDialog("CreateGroupDialog", "Tạo nhóm chat"));
        row.getChildren().addAll(chat, group);
        row.getStyleClass().add("person-row");
        return row;
    }

    private Node[] actions(SearchUser u) {
        return switch (u.relation()) {
            case NONE -> new Node[]{toggleRequest(false)};
            case SENT -> new Node[]{toggleRequest(true)};
            case INCOMING -> new Node[]{button("Từ chối", "sm"), button("Chấp nhận", "sm", "primary")};
            case FRIEND -> {
                Label friend = new Label("Bạn bè");
                friend.getStyleClass().addAll("badge", "ok");
                yield new Node[]{friend};
            }
        };
    }

    /** "Kết bạn" ↔ "Đã gửi lời mời · Hủy" (UC-09 send / cancel). */
    private Button toggleRequest(boolean sent) {
        Button button = button("", "sm");
        setRequestState(button, sent);
        button.setOnAction(e -> setRequestState(button, !button.getStyleClass().contains("sent")));
        return button;
    }

    private static void setRequestState(Button button, boolean sent) {
        button.setText(sent ? "Đã gửi lời mời · Hủy" : "Kết bạn");
        button.getStyleClass().removeAll("primary", "sent");
        button.getStyleClass().add(sent ? "sent" : "primary");
    }

    private static Button button(String text, String... classes) {
        Button button = new Button(text);
        button.getStyleClass().addAll(classes);
        return button;
    }
}
