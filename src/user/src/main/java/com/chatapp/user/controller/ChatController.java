package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.Conversation;
import com.chatapp.user.sample.SampleData.Kind;
import com.chatapp.user.sample.SampleData.Message;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

/** S04 Trò chuyện 1-1. V1: sample data and navigation only; messaging comes with the chat-1-1 feature. */
public class ChatController {

    private static final String PEER_NAME = "Trần Thị Bích";

    @FXML
    private HBox onlineStrip;
    @FXML
    private ListView<Conversation> conversationList;
    @FXML
    private HBox findBar;
    @FXML
    private HBox selectBar;
    @FXML
    private Label selectedLabel;
    @FXML
    private Button deleteSelectedButton;
    @FXML
    private VBox messageBox;
    @FXML
    private VBox suggestionBox;

    private int selectedCount;

    @FXML
    private void initialize() {
        // Avatars go before the "Xem tất cả" link already in the strip.
        int index = 0;
        for (String initials : SampleData.ONLINE_FRIENDS) {
            onlineStrip.getChildren().add(index++, ChatViews.avatar(initials, true));
        }
        ChatViews.setupConversations(conversationList, 0);
        ChatViews.fillMessages(messageBox, SampleData.CHAT);
        for (String suggestion : SampleData.AI_SUGGESTIONS) {
            Button card = new Button(suggestion);
            card.getStyleClass().add("ai-card");
            card.setWrapText(true);
            card.setMaxWidth(Double.MAX_VALUE);
            suggestionBox.getChildren().add(card);
        }
    }

    /** Swaps the find bar for the "Đã chọn n tin · Xóa · Hủy" bar and puts a check box before each message. */
    private void setSelecting(boolean selecting) {
        findBar.setVisible(!selecting);
        findBar.setManaged(!selecting);
        selectBar.setVisible(selecting);
        selectBar.setManaged(selecting);
        if (selecting) {
            selectedCount = 0;
            updateSelection();
            messageBox.getChildren().setAll(SampleData.CHAT.stream().map(this::selectableLine).toList());
        } else {
            ChatViews.fillMessages(messageBox, SampleData.CHAT);
        }
    }

    /** Day separators and system lines cannot be selected; they stay as they are. */
    private Node selectableLine(Message m) {
        Node line = ChatViews.messageLine(m);
        if (m.kind() == Kind.DAY || m.kind() == Kind.SYSTEM) {
            return line;
        }
        CheckBox check = new CheckBox();
        check.selectedProperty().addListener((obs, was, now) -> {
            selectedCount += now ? 1 : -1;
            updateSelection();
        });
        HBox.setHgrow(line, Priority.ALWAYS);
        HBox row = new HBox(10, check, line);
        row.setAlignment(Pos.CENTER_LEFT);
        return row;
    }

    private void updateSelection() {
        selectedLabel.setText("Đã chọn " + selectedCount + " tin");
        deleteSelectedButton.setDisable(selectedCount == 0);
    }

    @FXML
    private void onSelectMessages() {
        setSelecting(true);
    }

    @FXML
    private void onCancelSelect() {
        setSelecting(false);
    }

    @FXML
    private void onDeleteSelected() {
        ChatViews.confirmDeleteSelected(selectedCount);
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
    private void onAllFriends() {
        Navigator.showMain("FriendsView");
    }

    @FXML
    private void onClearHistory() {
        ChatViews.confirmClearHistory(PEER_NAME);
    }

    @FXML
    private void onUnfriend() {
        ChatViews.confirmUnfriend(PEER_NAME);
    }

    @FXML
    private void onReportSpam() {
        Navigator.openDialog("ReportSpamDialog", "Báo cáo spam");
    }

    @FXML
    private void onBlock() {
        ChatViews.confirmBlock(PEER_NAME);
    }
}
