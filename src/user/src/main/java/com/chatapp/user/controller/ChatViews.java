package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.Conversation;
import com.chatapp.user.sample.SampleData.Kind;
import com.chatapp.user.sample.SampleData.Message;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.control.ListCell;
import javafx.scene.control.ListView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.Region;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.scene.shape.Circle;
import javafx.scene.text.Text;
import javafx.scene.text.TextFlow;
import org.kordamp.ikonli.javafx.FontIcon;

import java.util.List;

/** Builders shared by the chat, group chat and message search views. */
final class ChatViews {

    private static final double BUBBLE_MAX_WIDTH = 520;

    private ChatViews() {
    }

    /** Avatar label; {@code online == null} hides the status dot. */
    static StackPane avatar(String initials, Boolean online, String... extraClasses) {
        Label label = new Label(initials);
        label.getStyleClass().add("avatar");
        label.getStyleClass().addAll(extraClasses);
        StackPane pane = new StackPane(label);
        if (online != null) {
            Circle dot = new Circle(4.5);
            dot.getStyleClass().add("status-dot");
            if (online) {
                dot.getStyleClass().add("online");
            }
            StackPane.setAlignment(dot, Pos.BOTTOM_RIGHT);
            pane.getChildren().add(dot);
        }
        return pane;
    }

    static Region spacer() {
        Region region = new Region();
        HBox.setHgrow(region, Priority.ALWAYS);
        return region;
    }

    static Node conversationCell(Conversation c) {
        Label name = new Label(c.name());
        name.getStyleClass().add("strong");
        HBox top = new HBox(4, name);
        top.setAlignment(Pos.CENTER_LEFT);
        if (c.group()) {
            FontIcon lock = new FontIcon("fth-lock");
            lock.getStyleClass().add("inline-icon");
            top.getChildren().add(lock);
        }
        if (c.tag() != null) {
            Label tag = new Label(c.tag());
            tag.getStyleClass().add("badge");
            top.getChildren().add(tag);
        }
        Label time = new Label(c.time());
        time.getStyleClass().addAll("mono", "xs", "muted");
        top.getChildren().addAll(spacer(), time);

        Label preview = new Label(c.preview());
        preview.getStyleClass().addAll("small", "muted");
        preview.setMinWidth(0);
        preview.setMaxWidth(Double.MAX_VALUE);
        VBox text = new VBox(2, top, preview);
        text.setMinWidth(0);
        HBox.setHgrow(text, Priority.ALWAYS);
        StackPane avatar = c.group() ? avatar(c.initials(), null, "group") : avatar(c.initials(), c.online());
        HBox row = new HBox(10, avatar, text);
        row.setAlignment(Pos.CENTER_LEFT);
        row.getStyleClass().add("conv-cell");
        return row;
    }

    /** Message text with an optional highlighted search hit in the middle. */
    static TextFlow bubble(String text, String hit, String after, boolean mine, boolean focus) {
        TextFlow flow = new TextFlow(text(text));
        if (hit != null) {
            Label highlight = new Label(hit);
            highlight.getStyleClass().add("hl");
            flow.getChildren().addAll(highlight, text(after));
        }
        flow.getStyleClass().add("bubble");
        if (mine) {
            flow.getStyleClass().add("me");
        }
        if (focus) {
            flow.getStyleClass().add("focus");
        }
        flow.setMaxWidth(BUBBLE_MAX_WIDTH);
        return flow;
    }

    /** A Text node with style class "text" (Text has no default style class, unlike a Label's inner text). */
    static Text text(String value) {
        Text text = new Text(value);
        text.getStyleClass().add("text");
        return text;
    }

    static Node messageLine(Message m) {
        if (m.kind() == Kind.DAY || m.kind() == Kind.SYSTEM) {
            Label label = new Label(m.text());
            label.getStyleClass().add(m.kind() == Kind.DAY ? "day-sep" : "sys");
            label.setWrapText(true);
            HBox row = new HBox(label);
            row.setAlignment(Pos.CENTER);
            return row;
        }
        boolean mine = m.kind() == Kind.OUT;
        VBox column = new VBox(3);
        column.setFillWidth(false);
        column.setAlignment(mine ? Pos.TOP_RIGHT : Pos.TOP_LEFT);
        if (m.sender() != null) {
            Label sender = new Label(m.sender());
            sender.getStyleClass().add("sender");
            column.getChildren().add(sender);
        }
        column.getChildren().add(bubble(m.text(), m.hit(), m.after(), mine, m.focus()));
        if (m.meta() != null) {
            Label meta = new Label(m.meta());
            meta.getStyleClass().add("meta");
            column.getChildren().add(meta);
        }
        HBox row = new HBox(10);
        row.setAlignment(mine ? Pos.TOP_RIGHT : Pos.TOP_LEFT);
        if (m.initials() != null) {
            row.getChildren().add(avatar(m.initials(), null, "sm"));
        }
        row.getChildren().add(column);
        return row;
    }

    static void fillMessages(VBox box, List<Message> messages) {
        box.getChildren().setAll(messages.stream().map(ChatViews::messageLine).toList());
    }

    /** Fills the conversation list, selects row {@code selected}; clicking a row opens that chat. */
    static void setupConversations(ListView<Conversation> list, int selected) {
        list.setCellFactory(view -> new ListCell<>() {
            @Override
            protected void updateItem(Conversation c, boolean empty) {
                super.updateItem(c, empty);
                setText(null);
                setPrefWidth(0);
                setGraphic(empty || c == null ? null : conversationCell(c));
            }
        });
        list.getItems().setAll(SampleData.CONVERSATIONS);
        list.getSelectionModel().select(selected);
        list.setOnMouseClicked(event -> {
            Conversation c = list.getSelectionModel().getSelectedItem();
            if (c != null) {
                Navigator.showMain(c.group() ? "GroupChatView" : "ChatView");
            }
        });
    }

    static void confirmClearHistory(String name) {
        Navigator.openConfirm("Xóa toàn bộ lịch sử chat?",
                "Toàn bộ tin nhắn với " + name + " sẽ bị xóa ở phía bạn. Người kia vẫn xem được cuộc trò chuyện.",
                "Không thể hoàn tác.", "Xóa lịch sử");
    }

    static void confirmDeleteSelected(int count) {
        Navigator.openConfirm("Xóa tin nhắn đã chọn?",
                count + " tin nhắn đã chọn sẽ bị xóa ở phía bạn. Người kia vẫn xem được các tin này.",
                "Không thể hoàn tác.", "Xóa");
    }

    static void confirmUnfriend(String name) {
        Navigator.openConfirm("Hủy kết bạn?",
                "Hủy kết bạn với " + name + "? Lịch sử chat vẫn được giữ.", "", "Hủy kết bạn");
    }

    static void confirmBlock(String name) {
        Navigator.openConfirm("Chặn " + name + "?",
                "Người này sẽ bị xóa khỏi danh sách bạn bè và lời mời, không tìm thấy bạn và không gửi lời mời "
                        + "kết bạn được. Hai bên cũng không nhắn tin 1-1 được với nhau.",
                "Bạn có thể bỏ chặn trong Bạn bè › Đã chặn.", "Chặn");
    }
}
