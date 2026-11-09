package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import com.chatapp.admin.sample.SampleData;
import com.chatapp.admin.sample.SampleData.NewUserRow;
import com.chatapp.common.DateFields;
import javafx.fxml.FXML;
import javafx.scene.chart.BarChart;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.ToggleButton;
import javafx.scene.control.ToggleGroup;

import java.text.Collator;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Objects;

/** S15 Đăng ký mới. V1: sample chart per year (switching year redraws the sample data) and sample list. */
public class NewUsersController {

    @FXML
    private ToggleGroup yearGroup;
    @FXML
    private ToggleButton year2026;
    @FXML
    private Label totalLabel;
    @FXML
    private Label chartTitle;
    @FXML
    private BarChart<String, Number> chart;
    @FXML
    private DatePicker fromDate;
    @FXML
    private DatePicker toDate;
    @FXML
    private TableView<NewUserRow> table;
    @FXML
    private TableColumn<NewUserRow, String> usernameColumn;
    @FXML
    private TableColumn<NewUserRow, String> nameColumn;
    @FXML
    private TableColumn<NewUserRow, String> emailColumn;
    @FXML
    private TableColumn<NewUserRow, LocalDateTime> createdColumn;

    @FXML
    private void initialize() {
        year2026.setSelected(true);
        showYear(2026);

        DateFields.useDayMonthYear(fromDate, toDate);
        fromDate.setValue(SampleData.TODAY.withDayOfMonth(1));
        toDate.setValue(SampleData.TODAY);
        Tables.text(usernameColumn, NewUserRow::username, true);
        Tables.text(nameColumn, NewUserRow::fullName, false);
        nameColumn.setComparator(Collator.getInstance(AdminNavigator.LOCALE)::compare);
        Tables.text(emailColumn, NewUserRow::email, false);
        Tables.date(createdColumn, NewUserRow::created, Tables.DATE_TIME);
        table.getItems().setAll(SampleData.NEW_USERS);
        createdColumn.setSortType(TableColumn.SortType.DESCENDING);
        table.getSortOrder().add(createdColumn);
    }

    @FXML
    private void onYear() {
        // Keep one year selected even when the selected button is clicked again.
        ToggleButton selected = (ToggleButton) yearGroup.getSelectedToggle();
        if (selected == null) {
            year2026.setSelected(true);
            selected = year2026;
        }
        showYear(Integer.parseInt(selected.getText()));
    }

    private void showYear(int year) {
        Integer[] values = SampleData.NEW_USERS_BY_MONTH.get(year);
        int total = Arrays.stream(values).filter(Objects::nonNull).mapToInt(Integer::intValue).sum();
        totalLabel.setText("Tổng năm " + year + ": " + total + " người");
        chartTitle.setText("Số người đăng ký mới theo tháng, năm " + year);
        MonthlyChart.fill(chart, values, year);
    }
}
