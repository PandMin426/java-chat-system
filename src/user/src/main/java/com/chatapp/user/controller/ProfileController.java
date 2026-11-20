package com.chatapp.user.controller;

import com.chatapp.common.DateFields;
import com.chatapp.common.GenderFields;
import javafx.fxml.FXML;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;

import java.time.LocalDate;

/** S09 Hồ sơ. V1: sample values only; saving comes with the profile feature. */
public class ProfileController {

    @FXML
    private DatePicker birthDatePicker;
    @FXML
    private ComboBox<String> genderBox;

    @FXML
    private void initialize() {
        DateFields.useDayMonthYear(birthDatePicker);
        GenderFields.setup(genderBox);
        // Values already saved in the sample profile, not defaults.
        birthDatePicker.setValue(LocalDate.of(2004, 5, 12));
        genderBox.setValue("Nam");
    }
}
