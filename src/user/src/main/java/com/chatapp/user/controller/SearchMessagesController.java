package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.Kind;
import com.chatapp.user.sample.SampleData.Message;
import com.chatapp.user.sample.SampleData.SearchHit;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import javafx.scene.text.TextFlow;

import java.util.List;

/** S08 Tìm tin nhắn. V1: sample results for the query "báo cáo"; searching comes with the chat features. */
public class SearchMessagesController {

    @FXML
    private VBox resultBox;
    @FXML
    private VBox previewBox;

    @FXML
    private void initialize() {
        String group = null;
        boolean first = true;
        for (SearchHit hit : SampleData.SEARCH_HITS) {
            if (!hit.conversation().equals(group)) {
                group = hit.conversation();
                resultBox.getChildren().add(groupHeader(hit));
            }
            resultBox.getChildren().add(result(hit, first));
            first = false;
        }
        ChatViews.fillMessages(previewBox, List.of(
                Message.day("07/11/2026"),
                Message.groupIn("Võ Minh", "VM", "Script tạo database mình đẩy lên rồi, mọi người pull về chạy thử nhé.", "21:40"),
                Message.out("Ok, mình ghép thử với màn hình đăng ký.", "21:45"),
                new Message(Kind.IN, "Võ Minh", "VM", "Nhớ nộp ", "báo cáo", " V1 trước 19h30 nhé", "21:50", true),
                Message.groupIn("Đỗ Hà", "ĐH", "Ok anh", "21:52")));
    }

    private Node groupHeader(SearchHit hit) {
        Label name = new Label(hit.conversation());
        name.getStyleClass().addAll("small", "strong");
        HBox header = new HBox(8, ChatViews.avatar(hit.initials(), null, "sm", hit.group() ? "group" : "plain"), name);
        header.getStyleClass().add("result-group");
        return header;
    }

    private Node result(SearchHit hit, boolean selected) {
        Text who = ChatViews.text(hit.who());
        who.getStyleClass().add("who");
        Label highlight = new Label(hit.hit());
        highlight.getStyleClass().add("hl");
        TextFlow text = new TextFlow(who, ChatViews.text(hit.text()), highlight, ChatViews.text(hit.after()));
        text.getStyleClass().add("result-text");
        Label time = new Label(hit.time());
        time.getStyleClass().addAll("mono", "xs", "muted");
        VBox box = new VBox(3, text, time);
        box.getStyleClass().add("result");
        if (selected) {
            box.getStyleClass().add("selected");
        }
        box.setAlignment(Pos.CENTER_LEFT);
        box.setOnMouseClicked(e -> {
            resultBox.getChildren().forEach(n -> n.getStyleClass().remove("selected"));
            box.getStyleClass().add("selected");
        });
        return box;
    }

    @FXML
    private void onBack() {
        Navigator.showMain("ChatView");
    }

    @FXML
    private void onOpenConversation() {
        Navigator.showMain("GroupChatView");
    }
}
