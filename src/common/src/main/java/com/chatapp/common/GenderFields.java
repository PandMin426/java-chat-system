package com.chatapp.common;

import javafx.scene.control.ComboBox;

import java.util.List;

/** Gender choices shared by both apps. Gender is optional: nothing is preselected and an empty box means NULL. */
public final class GenderFields {

    public static final List<String> VALUES = List.of("Nam", "Nữ", "Khác");

    private GenderFields() {
    }

    /** Fills the box with {@link #VALUES} and shows "Không nêu" while no value is chosen. */
    public static void setup(ComboBox<String> box) {
        box.getItems().setAll(VALUES);
        box.setPromptText("Không nêu");
    }
}
