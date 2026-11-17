package com.chatapp.admin.controller;

import com.chatapp.admin.sample.SampleData;
import com.chatapp.common.DateFields;
import com.chatapp.admin.sample.SampleData.SpamRow;
import com.chatapp.admin.sample.SampleData.SpamStatus;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

import java.time.LocalDateTime;
import java.util.Comparator;

/** S14 Báo cáo spam. V1: sample reports; "Khóa tài khoản" and "Bỏ qua" come with the admin-spam feature. */
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
    private TableColumn<SpamRow, String> reasonColumn;
    @FXML
    private TableColumn<SpamRow, SpamStatus> actionColumn;

    @FXML
    private void initialize() {
        DateFields.useDayMonthYear(fromDate, toDate);
        fromDate.setValue(SampleData.TODAY.withDayOfMonth(1));
        toDate.setValue(SampleData.TODAY);
        Tables.date(timeColumn, SpamRow::time, Tables.DATE_TIME);
        Tables.text(reporterColumn, SpamRow::reporter, true);
        Tables.graphic(reportedColumn, r -> r, SpamController::reportedCell);
        reportedColumn.setComparator(Comparator.comparing(SpamRow::username));
        Tables.text(reasonColumn, SpamRow::reasons, false);
        Tables.graphic(actionColumn, SpamRow::status, SpamController::action);
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

    /** D38: a pending report offers "Khóa tài khoản" and "Bỏ qua"; a handled one shows its status. */
    private static Node action(SpamStatus status) {
        return switch (status) {
            case PENDING -> {
                Button lock = new Button("Khóa tài khoản");
                lock.getStyleClass().addAll("sm", "danger", "primary");
                Button dismiss = new Button("Bỏ qua");
                dismiss.getStyleClass().add("sm");
                yield new HBox(6, lock, dismiss);
            }
            case RESOLVED -> Tables.badge("Đã xử lý · đã khóa", "bad");
            case DISMISSED -> Tables.badge("Đã bỏ qua", null);
        };
    }
}
