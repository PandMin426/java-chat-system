package com.chatapp.admin.controller;

import com.chatapp.admin.sample.SampleData;
import com.chatapp.common.DateFields;
import com.chatapp.admin.sample.SampleData.LoginRow;
import javafx.fxml.FXML;
import javafx.scene.control.DatePicker;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;

import java.time.LocalDateTime;

/** S12 Nhật ký đăng nhập. V1: sample rows, newest first; filtering comes with the admin-log feature. */
public class LoginLogController {

    @FXML
    private DatePicker fromDate;
    @FXML
    private DatePicker toDate;
    @FXML
    private TableView<LoginRow> table;
    @FXML
    private TableColumn<LoginRow, LocalDateTime> timeColumn;
    @FXML
    private TableColumn<LoginRow, String> usernameColumn;
    @FXML
    private TableColumn<LoginRow, String> nameColumn;
    @FXML
    private TableColumn<LoginRow, String> ipColumn;

    @FXML
    private void initialize() {
        DateFields.useDayMonthYear(fromDate, toDate);
        fromDate.setValue(SampleData.TODAY.withDayOfMonth(1));
        toDate.setValue(SampleData.TODAY);
        Tables.date(timeColumn, LoginRow::time, Tables.DATE_TIME);
        Tables.text(usernameColumn, LoginRow::username, true);
        Tables.text(nameColumn, LoginRow::fullName, false);
        Tables.text(ipColumn, LoginRow::ip, true);
        table.getItems().setAll(SampleData.LOGINS);
        timeColumn.setSortType(TableColumn.SortType.DESCENDING);
        table.getSortOrder().add(timeColumn);
    }
}
