package com.chatapp.user.controller;

import javafx.fxml.FXML;
import javafx.scene.control.DatePicker;

import java.time.LocalDate;

/** S09 Hồ sơ. V1: sample values only; saving comes with the profile feature. */
public class ProfileController {

    @FXML
    private DatePicker birthDatePicker;

    @FXML
    private void initialize() {
        birthDatePicker.setValue(LocalDate.of(2004, 5, 12));
    }
}
