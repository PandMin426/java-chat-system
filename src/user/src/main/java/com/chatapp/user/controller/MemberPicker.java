package com.chatapp.user.controller;

import com.chatapp.user.sample.SampleData.Person;
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

/**
 * Picked people as chips above a suggestion list, shared by D01 (create group) and D04 (add members).
 * Clicking a suggestion picks it, the chip's x puts it back; the confirm button is off while nobody is picked.
 */
final class MemberPicker {

    private final Label countLabel;
    private final String countPrefix;
    private final FlowPane chipPane;
    private final VBox suggestionBox;
    private final Button confirmButton;
    private final List<Person> suggestions;
    private final List<Person> picked;

    MemberPicker(Label countLabel, String countPrefix, FlowPane chipPane, VBox suggestionBox, Button confirmButton,
                 List<Person> picked, List<Person> suggestions) {
        this.countLabel = countLabel;
        this.countPrefix = countPrefix;
        this.chipPane = chipPane;
        this.suggestionBox = suggestionBox;
        this.confirmButton = confirmButton;
        this.picked = new ArrayList<>(picked);
        this.suggestions = suggestions;
        refresh();
    }

    private void refresh() {
        countLabel.setText(countPrefix + " · " + picked.size() + " đã chọn");
        chipPane.getChildren().setAll(picked.stream().map(this::chip).toList());
        suggestionBox.getChildren().setAll(suggestions.stream()
                .filter(p -> !picked.contains(p))
                .map(this::suggestion)
                .toList());
        confirmButton.setDisable(picked.isEmpty());
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
}
