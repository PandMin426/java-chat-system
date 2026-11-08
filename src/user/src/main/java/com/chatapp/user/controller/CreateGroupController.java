package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import com.chatapp.user.sample.SampleData;
import com.chatapp.user.sample.SampleData.Person;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.FlowPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import org.kordamp.ikonli.javafx.FontIcon;

import java.util.ArrayList;
import java.util.List;

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

    private final List<Person> picked = new ArrayList<>(SampleData.GROUP_PICKED);

    @FXML
    private void initialize() {
        refresh();
    }

    private void refresh() {
        memberLabel.setText("Thành viên · " + picked.size() + " đã chọn");
        chipPane.getChildren().setAll(picked.stream().map(this::chip).toList());
        suggestionBox.getChildren().setAll(SampleData.GROUP_SUGGESTIONS.stream()
                .filter(p -> !picked.contains(p))
                .map(this::suggestion)
                .toList());
        createButton.setDisable(picked.isEmpty());
    }

    private Node chip(Person p) {
        Label name = new Label(p.name());
        name.getStyleClass().add("small");
        Label username = new Label(p.username());
        username.getStyleClass().addAll("mono", "xs", "muted");
        Button remove = new Button(null, new FontIcon("fth-x"));
        remove.getStyleClass().addAll("ghost", "sm", "icon");
        remove.setOnAction(e -> {
            picked.remove(p);
            refresh();
        });
        HBox chip = new HBox(name, username, remove);
        chip.getStyleClass().add("chip");
        return chip;
    }

    private Node suggestion(Person p) {
        Label name = new Label(p.name() + "  ");
        name.getStyleClass().add("small");
        Label username = new Label(p.username());
        username.getStyleClass().addAll("mono", "xs", "muted");
        HBox text = new HBox(name, username);
        HBox.setHgrow(text, Priority.ALWAYS);
        Label note = new Label(p.sub());
        note.getStyleClass().addAll("xs", "muted");
        HBox row = new HBox(10, ChatViews.avatar(p.initials(), p.online(), "sm"), text, note);
        row.getStyleClass().add("suggestion");
        row.setOnMouseClicked(e -> {
            picked.add(p);
            refresh();
        });
        return row;
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
