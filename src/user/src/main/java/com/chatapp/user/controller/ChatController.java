package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.Conversation;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

/** S04 Trò chuyện 1-1. V1: sample data and navigation only; messaging comes with the chat-1-1 feature. */
public class ChatController {

    private static final String PEER_NAME = "Trần Thị Bích";

    @FXML
    private HBox onlineStrip;
    @FXML
    private ListView<Conversation> conversationList;
    @FXML
    private VBox messageBox;
    @FXML
    private VBox suggestionBox;

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
