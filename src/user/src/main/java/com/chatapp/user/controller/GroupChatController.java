package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.Conversation;
import com.chatapp.user.sample.SampleData.Member;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.MenuButton;
import javafx.scene.control.MenuItem;
import javafx.scene.control.SeparatorMenuItem;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import org.kordamp.ikonli.javafx.FontIcon;

/** S05 Nhóm chat, shown as seen by a group admin. V1: sample data and navigation only. */
public class GroupChatController {

    @FXML
    private ListView<Conversation> conversationList;
    @FXML
    private VBox messageBox;
    @FXML
    private VBox memberBox;

    @FXML
    private void initialize() {
        ChatViews.setupConversations(conversationList, 1);
        ChatViews.fillMessages(messageBox, SampleData.GROUP_CHAT);
        for (Member member : SampleData.GROUP_MEMBERS) {
            memberBox.getChildren().add(memberRow(member));
        }
    }

    private Node memberRow(Member m) {
        Label name = new Label(m.name());
        name.getStyleClass().add("small");
        name.setMaxWidth(Double.MAX_VALUE);
        HBox.setHgrow(name, Priority.ALWAYS);
        HBox row = new HBox(10, ChatViews.avatar(m.initials(), m.online(), "sm"), name);
        row.setAlignment(Pos.CENTER_LEFT);
        if (m.admin()) {
            Label badge = new Label("Admin");
            badge.getStyleClass().addAll("badge", "dark");
            row.getChildren().add(badge);
        }
        if (!m.me()) {
            row.getChildren().add(memberMenu(m));
        }
        return row;
    }

    /** Admin-only actions on a member (UC-25, UC-26). */
    private MenuButton memberMenu(Member m) {
        MenuItem message = new MenuItem("Nhắn tin riêng");
        message.setOnAction(e -> Navigator.showMain("ChatView"));
        MenuItem role = new MenuItem(m.admin() ? "Gỡ quyền admin" : "Đặt làm admin nhóm");
        MenuItem remove = new MenuItem("Xóa khỏi nhóm…");
        remove.getStyleClass().add("danger");
        remove.setOnAction(e -> Navigator.openConfirm("Xóa khỏi nhóm?",
                "Xóa " + m.name() + " khỏi nhóm “Đồ án Java”? Người này sẽ không nhận tin nhắn của nhóm nữa.",
                "", "Xóa khỏi nhóm"));
        MenuButton menu = new MenuButton(null, new FontIcon("fth-more-horizontal"),
                message, role, new SeparatorMenuItem(), remove);
        menu.getStyleClass().addAll("ghost", "sm", "icon");
        return menu;
    }

    @FXML
    private void onNewGroup() {
        Navigator.openDialog("CreateGroupDialog", "Tạo nhóm chat");
    }

    @FXML
    private void onSearchMessages() {
        Navigator.showMain("SearchMessagesView");
    }

    @FXML
    private void onAddMember() {
        Navigator.openDialog("CreateGroupDialog", "Thêm thành viên");
    }
}
