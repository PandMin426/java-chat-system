package com.chatapp.admin.controller;

import com.chatapp.admin.sample.SampleData;
import com.chatapp.common.DateFields;
import com.chatapp.admin.sample.SampleData.SpamRow;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Region;
import javafx.scene.layout.VBox;

import java.time.LocalDateTime;
import java.util.Comparator;

/** S14 Báo cáo spam. V1: sample reports; "Bỏ qua" / "Khóa tài khoản" come with the admin-spam feature. */
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
    private TableColumn<SpamRow, SpamRow> reportedColumn;
    @FXML
    private TableColumn<SpamRow, String> reporterColumn;
    @FXML
    private TableColumn<SpamRow, String> reasonColumn;
    @FXML
    private TableColumn<SpamRow, String> statusColumn;
    @FXML
    private TableColumn<SpamRow, String> actionColumn;

    @FXML
    private void initialize() {
        DateFields.useDayMonthYear(fromDate, toDate);
        fromDate.setValue(SampleData.TODAY.withDayOfMonth(1));
        toDate.setValue(SampleData.TODAY);
        Tables.date(timeColumn, SpamRow::time, Tables.DATE_TIME);
        Tables.graphic(reportedColumn, r -> r, SpamController::reportedCell);
        reportedColumn.setComparator(Comparator.comparing(SpamRow::username));
        Tables.text(reporterColumn, SpamRow::reporter, true);
        Tables.text(reasonColumn, SpamRow::reason, false);
        Tables.graphic(statusColumn, SpamRow::status, SpamController::statusBadge);
        Tables.graphic(actionColumn, SpamRow::status, SpamController::actions);
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

    private static Node statusBadge(String status) {
        return switch (status) {
            case SampleData.PENDING -> Tables.badge(status, "warn");
            case "Đã khóa" -> Tables.badge(status, "bad");
            default -> Tables.badge(status, null);
        };
    }

    /** Pending reports get the two actions; handled ones get an empty cell. */
    private static Node actions(String status) {
        if (!SampleData.PENDING.equals(status)) {
            return new Region();
        }
        Button ignore = new Button("Bỏ qua");
        ignore.getStyleClass().add("sm");
        Button lock = new Button("Khóa tài khoản");
        lock.getStyleClass().addAll("sm", "danger", "primary");
        HBox box = new HBox(6, ignore, lock);
        box.setAlignment(Pos.CENTER_LEFT);
        return box;
    }
}
