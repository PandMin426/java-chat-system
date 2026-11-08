package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.Person;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.MenuButton;
import javafx.scene.control.MenuItem;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import org.kordamp.ikonli.javafx.FontIcon;

/** S06 Bạn bè. V1: sample rows and navigation only; friend actions come with the friends feature. */
public class FriendsController {

    @FXML
    private VBox allBox;
    @FXML
    private VBox onlineBox;
    @FXML
    private VBox requestBox;
    @FXML
    private VBox blockedBox;

    @FXML
    private void initialize() {
        for (Person p : SampleData.FRIENDS) {
            allBox.getChildren().add(friendRow(p));
            if (p.online()) {
                onlineBox.getChildren().add(friendRow(p));
            }
        }
        for (Person p : SampleData.FRIEND_REQUESTS) {
            requestBox.getChildren().add(row(p, false, button("Từ chối", "sm"), button("Chấp nhận", "sm", "primary")));
        }
        for (Person p : SampleData.BLOCKED) {
            blockedBox.getChildren().add(row(p, false, button("Bỏ chặn", "sm")));
        }
    }

    private Node friendRow(Person p) {
        Button chat = button("Nhắn tin", "sm");
        chat.setOnAction(e -> Navigator.showMain("ChatView"));
        Button group = button("Tạo nhóm", "sm");
        group.setOnAction(e -> Navigator.openDialog("CreateGroupDialog", "Tạo nhóm chat"));
        MenuItem unfriend = new MenuItem("Hủy kết bạn");
        unfriend.setOnAction(e -> ChatViews.confirmUnfriend(p.name()));
        MenuItem report = new MenuItem("Báo cáo spam…");
        report.getStyleClass().add("danger");
        report.setOnAction(e -> Navigator.openDialog("ReportSpamDialog", "Báo cáo spam"));
        MenuItem block = new MenuItem("Chặn…");
        block.getStyleClass().add("danger");
        block.setOnAction(e -> ChatViews.confirmBlock(p.name()));
        MenuButton more = new MenuButton(null, new FontIcon("fth-more-horizontal"), unfriend, report, block);
        more.getStyleClass().addAll("ghost", "sm", "icon");
        return row(p, true, chat, group, more);
    }

    private Node row(Person p, boolean showStatus, Node... actions) {
        Label name = new Label(p.name());
        name.getStyleClass().add("strong");
        Label username = new Label(p.username());
        username.getStyleClass().addAll("mono", "small", "muted");
        HBox title = new HBox(8, name, username);
        Label sub = new Label(p.sub());
        sub.getStyleClass().addAll("small", "muted");
        VBox text = new VBox(2, title, sub);
        HBox.setHgrow(text, Priority.ALWAYS);
        HBox row = new HBox(12, ChatViews.avatar(p.initials(), showStatus ? p.online() : null), text);
        row.getChildren().addAll(actions);
        row.getStyleClass().add("person-row");
        return row;
    }

    private static Button button(String text, String... classes) {
        Button button = new Button(text);
        button.getStyleClass().addAll(classes);
        return button;
    }

    @FXML
    private void onFindPeople() {
        Navigator.showMain("SearchUsersView");
    }
}
