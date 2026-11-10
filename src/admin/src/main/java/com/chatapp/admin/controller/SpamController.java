package com.chatapp.admin.controller;

import com.chatapp.admin.sample.SampleData;
import com.chatapp.common.DateFields;
import com.chatapp.admin.sample.SampleData.SpamRow;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.layout.VBox;

import java.time.LocalDateTime;
import java.util.Comparator;

/** S14 Báo cáo spam. V1: sample reports; "Khóa tài khoản" comes with the admin-spam feature. */
public class SpamController {

    @FXML
    private DatePicker fromDate;
    @FXML
    private DatePicker toDate;
    @FXML
    private TableView<SpamRow> table;
    @FXML
    private TableColumn<SpamRow, LocalDateTime> timeColumn;
    @FXML
    private TableColumn<SpamRow, String> reporterColumn;
    @FXML
    private TableColumn<SpamRow, SpamRow> reportedColumn;
    @FXML
    private TableColumn<SpamRow, Boolean> actionColumn;

    @FXML
    private void initialize() {
        DateFields.useDayMonthYear(fromDate, toDate);
        fromDate.setValue(SampleData.TODAY.withDayOfMonth(1));
        toDate.setValue(SampleData.TODAY);
        Tables.date(timeColumn, SpamRow::time, Tables.DATE_TIME);
        Tables.text(reporterColumn, SpamRow::reporter, true);
        Tables.graphic(reportedColumn, r -> r, SpamController::reportedCell);
        reportedColumn.setComparator(Comparator.comparing(SpamRow::username));
        Tables.graphic(actionColumn, SpamRow::locked, SpamController::action);
        table.getItems().setAll(SampleData.SPAM_REPORTS);
        timeColumn.setSortType(TableColumn.SortType.DESCENDING);
        table.getSortOrder().add(timeColumn);
    }

    private static Node reportedCell(SpamRow r) {
        Label username = new Label(r.username());
        username.getStyleClass().add("mono");
        Label name = new Label(r.fullName());
        name.getStyleClass().addAll("xs", "muted");
        return new VBox(username, name);
    }

    /** An account that is already locked (users.account_status) shows "Đã khóa" instead of the lock button. */
    private static Node action(boolean locked) {
        if (locked) {
            return Tables.badge("Đã khóa", "bad");
        }
        Button lock = new Button("Khóa tài khoản");
        lock.getStyleClass().addAll("sm", "danger", "primary");
        return lock;
    }
}
