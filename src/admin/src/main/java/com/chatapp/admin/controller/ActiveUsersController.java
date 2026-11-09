package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import com.chatapp.admin.sample.SampleData;
import com.chatapp.admin.sample.SampleData.ActiveRow;
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
import java.time.LocalDate;

/** S17 Người dùng hoạt động. V1: sample rows matching "Mở ứng dụng &gt; 5" and a sample chart per year. */
public class ActiveUsersController {

    @FXML
    private ToggleGroup yearGroup;
    @FXML
    private ToggleButton year2026;
    @FXML
    private DatePicker fromDate;
    @FXML
    private DatePicker toDate;
    @FXML
    private TableView<ActiveRow> table;
    @FXML
    private TableColumn<ActiveRow, String> usernameColumn;
    @FXML
    private TableColumn<ActiveRow, String> nameColumn;
    @FXML
    private TableColumn<ActiveRow, LocalDate> createdColumn;
    @FXML
    private TableColumn<ActiveRow, Integer> opensColumn;
    @FXML
    private TableColumn<ActiveRow, Integer> peopleColumn;
    @FXML
    private TableColumn<ActiveRow, Integer> groupsColumn;
    @FXML
    private Label chartTitle;
    @FXML
    private BarChart<String, Number> chart;

    @FXML
    private void initialize() {
        DateFields.useDayMonthYear(fromDate, toDate);
        fromDate.setValue(SampleData.TODAY.withDayOfMonth(1));
        toDate.setValue(SampleData.TODAY);
        Tables.text(usernameColumn, ActiveRow::username, true);
        Tables.text(nameColumn, ActiveRow::fullName, false);
        nameColumn.setComparator(Collator.getInstance(AdminNavigator.LOCALE)::compare);
        Tables.date(createdColumn, ActiveRow::created, Tables.DATE);
        Tables.number(opensColumn, ActiveRow::appOpens);
        Tables.number(peopleColumn, ActiveRow::peopleChatted);
        Tables.number(groupsColumn, ActiveRow::groupsChatted);
        table.getItems().setAll(SampleData.ACTIVE_USERS.stream().filter(r -> r.appOpens() > 5).toList());
        table.getSortOrder().add(nameColumn);

        year2026.setSelected(true);
        showYear(2026);
    }

    @FXML
    private void onYear() {
        ToggleButton selected = (ToggleButton) yearGroup.getSelectedToggle();
        if (selected == null) {
            year2026.setSelected(true);
            selected = year2026;
        }
        showYear(Integer.parseInt(selected.getText()));
    }

    private void showYear(int year) {
        chartTitle.setText("Số người có mở ứng dụng theo tháng, năm " + year);
        MonthlyChart.fill(chart, SampleData.ACTIVE_BY_MONTH.get(year), year);
    }
}
