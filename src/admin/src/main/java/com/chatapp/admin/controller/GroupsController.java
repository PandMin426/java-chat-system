package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import com.chatapp.admin.sample.SampleData;
import com.chatapp.admin.sample.SampleData.GroupMember;
import com.chatapp.admin.sample.SampleData.GroupRow;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.control.Tab;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

import java.text.Collator;
import java.time.LocalDate;

/** S13 Nhóm chat. V1: sample groups, header sorting and the member/admin tabs (same sample members for every group). */
public class GroupsController {

    @FXML
    private TableView<GroupRow> table;
    @FXML
    private TableColumn<GroupRow, String> nameColumn;
    @FXML
    private TableColumn<GroupRow, Integer> membersColumn;
    @FXML
    private TableColumn<GroupRow, Boolean> encryptedColumn;
    @FXML
    private TableColumn<GroupRow, LocalDate> createdColumn;
    @FXML
    private Label groupNameLabel;
    @FXML
    private Label groupInfoLabel;
    @FXML
    private Tab membersTab;
    @FXML
    private Tab adminsTab;
    @FXML
    private VBox memberBox;
    @FXML
    private VBox adminBox;

    @FXML
    private void initialize() {
        Tables.text(nameColumn, GroupRow::name, false);
        nameColumn.setComparator(Collator.getInstance(AdminNavigator.LOCALE)::compare);
        Tables.number(membersColumn, GroupRow::members);
        Tables.graphic(encryptedColumn, GroupRow::encrypted,
                encrypted -> encrypted ? Tables.badge("Có", "ok") : Tables.badge("Không", null));
        Tables.date(createdColumn, GroupRow::created, Tables.DATE);

        table.getItems().setAll(SampleData.GROUPS);
        createdColumn.setSortType(TableColumn.SortType.DESCENDING);
        table.getSortOrder().add(createdColumn);
        table.getSelectionModel().selectedItemProperty().addListener((obs, old, group) -> {
            if (group != null) {
                showDetail(group);
            }
        });
        table.getSelectionModel().select(SampleData.GROUPS.get(0));

        for (GroupMember m : SampleData.GROUP_MEMBERS) {
            memberBox.getChildren().add(memberRow(m));
            if (m.admin()) {
                adminBox.getChildren().add(memberRow(m));
            }
        }
    }

    private void showDetail(GroupRow g) {
        groupNameLabel.setText(g.name());
        groupInfoLabel.setText("Tạo ngày " + Tables.DATE.format(g.created()) + " bởi " + g.creator());
        membersTab.setText("Thành viên · " + g.members());
        adminsTab.setText("Admin · " + g.admins());
    }

    private static Node memberRow(GroupMember m) {
        Label avatar = new Label(m.initials());
        avatar.getStyleClass().addAll("avatar", "sm");
        Label name = new Label(m.fullName());
        name.getStyleClass().add("small");
        Label username = new Label(m.username());
        username.getStyleClass().addAll("xs", "muted", "mono");
        VBox text = new VBox(name, username);
        HBox.setHgrow(text, Priority.ALWAYS);
        HBox row = new HBox(10, avatar, text);
        if (m.admin()) {
            row.getChildren().add(Tables.badge("Admin", "dark"));
        }
        row.getStyleClass().add("member-row");
        return row;
    }
}
