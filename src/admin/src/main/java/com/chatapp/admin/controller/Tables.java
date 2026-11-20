package com.chatapp.admin.controller;

import javafx.beans.property.ReadOnlyObjectWrapper;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;

import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAccessor;
import java.util.function.Function;

/** Column binding shared by the admin tables. Date columns keep the real value so header sorting is chronological. */
final class Tables {

    static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private Tables() {
    }

    static <S, T> void bind(TableColumn<S, T> column, Function<S, T> value) {
        column.setCellValueFactory(c -> new ReadOnlyObjectWrapper<>(value.apply(c.getValue())));
    }

    /** Text column; {@code mono} uses the monospace font (usernames). */
    static <S> void text(TableColumn<S, String> column, Function<S, String> value, boolean mono) {
        bind(column, value);
        if (mono) {
            column.getStyleClass().add("mono");
        }
    }

    static <S, T extends TemporalAccessor & Comparable<? super T>> void date(TableColumn<S, T> column, Function<S, T> value,
                                                                             DateTimeFormatter format) {
        bind(column, value);
        column.getStyleClass().add("mono");
        column.setCellFactory(c -> new TableCell<>() {
            @Override
            protected void updateItem(T item, boolean empty) {
                super.updateItem(item, empty);
                setText(empty || item == null ? null : format.format(item));
            }
        });
    }

    static <S> void number(TableColumn<S, Integer> column, Function<S, Integer> value) {
        bind(column, value);
        column.getStyleClass().add("num");
    }

    /** Column whose cells show a node built from the value (badges, buttons). */
    static <S, T> void graphic(TableColumn<S, T> column, Function<S, T> value, Function<T, Node> view) {
        bind(column, value);
        column.setCellFactory(c -> new TableCell<>() {
            @Override
            protected void updateItem(T item, boolean empty) {
                super.updateItem(item, empty);
                setText(null);
                setGraphic(empty || item == null ? null : view.apply(item));
            }
        });
    }

    static Label badge(String text, String kind) {
        Label badge = new Label(text);
        badge.getStyleClass().add("badge");
        if (kind != null) {
            badge.getStyleClass().add(kind);
        }
        badge.setAlignment(Pos.CENTER);
        return badge;
    }
}
