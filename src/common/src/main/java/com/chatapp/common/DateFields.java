package com.chatapp.common;

import javafx.scene.control.DatePicker;
import javafx.util.StringConverter;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/** Date input format shared by both apps. The vi-VN short style ("1/11/2026") has no leading zeros, so it is set explicitly. */
public final class DateFields {

    public static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private DateFields() {
    }

    /** Shows and parses dates as dd/MM/yyyy; text that does not parse keeps the previous value. */
    public static void useDayMonthYear(DatePicker... pickers) {
        for (DatePicker picker : pickers) {
            picker.setConverter(new StringConverter<>() {
                @Override
                public String toString(LocalDate date) {
                    return date == null ? "" : FORMAT.format(date);
                }

                @Override
                public LocalDate fromString(String text) {
                    if (text == null || text.isBlank()) {
                        return null;
                    }
                    try {
                        return LocalDate.parse(text.trim(), FORMAT);
                    } catch (DateTimeParseException e) {
                        return picker.getValue();
                    }
                }
            });
        }
    }
}
