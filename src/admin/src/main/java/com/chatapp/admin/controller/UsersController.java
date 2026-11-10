package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import com.chatapp.admin.sample.SampleData;
import com.chatapp.admin.sample.SampleData.GroupMember;
import com.chatapp.admin.sample.SampleData.LoginRow;
import com.chatapp.admin.sample.SampleData.UserRow;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.Tab;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.shape.Circle;

import java.text.Collator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Comparator;
import java.util.stream.Collectors;

/** S11 Quản lý người dùng. V1: sample rows, header sorting and the detail pane; actions come with V2. */
public class UsersController {

    @FXML
    private TableView<UserRow> table;
    @FXML
    private TableColumn<UserRow, String> usernameColumn;
    @FXML
    private TableColumn<UserRow, UserRow> nameColumn;
    @FXML
    private TableColumn<UserRow, LocalDate> createdColumn;
    @FXML
    private TableColumn<UserRow, Boolean> statusColumn;
    @FXML
    private Label initialsLabel;
    @FXML
    private Label nameLabel;
    @FXML
    private Label usernameLabel;
    @FXML
    private Label statusBadge;
    @FXML
    private Label onlineBadge;
    @FXML
    private Button lockButton;
    @FXML
    private Label emailLabel;
    @FXML
    private Label genderLabel;
    @FXML
    private Label birthLabel;
    @FXML
    private Label addressLabel;
    @FXML
    private Label createdLabel;
    @FXML
    private TableView<LoginRow> loginTable;
    @FXML
    private TableColumn<LoginRow, LocalDateTime> loginTimeColumn;
    @FXML
    private Tab friendsTab;
    @FXML
    private VBox friendBox;

    @FXML
    private void initialize() {
        Tables.text(usernameColumn, UserRow::username, true);
        Tables.graphic(nameColumn, u -> u, UsersController::nameCell);
        Collator collator = Collator.getInstance(AdminNavigator.LOCALE);
        nameColumn.setComparator(Comparator.comparing(UserRow::fullName, collator));
        Tables.date(createdColumn, UserRow::created, Tables.DATE);
        Tables.graphic(statusColumn, UserRow::locked,
                locked -> locked ? Tables.badge("Bị khóa", "bad") : Tables.badge("Hoạt động", "ok"));

        table.getItems().setAll(SampleData.USERS);
        createdColumn.setSortType(TableColumn.SortType.DESCENDING);
        table.getSortOrder().add(createdColumn);
        table.getSelectionModel().selectedItemProperty().addListener((obs, old, user) -> {
            if (user != null) {
                showDetail(user);
            }
        });
        table.getSelectionModel().select(SampleData.USERS.get(0));

        Tables.date(loginTimeColumn, LoginRow::time, Tables.DATE_TIME);
        loginTable.getItems().setAll(SampleData.USER_LOGINS);
        friendsTab.setText("Bạn bè · " + SampleData.USER_FRIENDS.size());
        for (GroupMember friend : SampleData.USER_FRIENDS) {
            friendBox.getChildren().add(friendRow(friend));
        }
    }

    private static Node nameCell(UserRow u) {
        Circle dot = new Circle(4);
        dot.getStyleClass().add("status-dot");
        dot.setStyle("-fx-stroke-width: 0;");
        if (u.online()) {
            dot.getStyleClass().add("online");
        }
        HBox cell = new HBox(8, dot, new Label(u.fullName()));
        cell.setAlignment(Pos.CENTER_LEFT);
        return cell;
    }

    private static Node friendRow(GroupMember f) {
        Label avatar = new Label(f.initials());
        avatar.getStyleClass().addAll("avatar", "sm");
        Label name = new Label(f.fullName());
        name.getStyleClass().add("small");
        Label username = new Label(f.username());
        username.getStyleClass().addAll("xs", "muted", "mono");
        HBox row = new HBox(10, avatar, new VBox(name, username));
        row.getStyleClass().add("member-row");
        return row;
    }

    private void showDetail(UserRow u) {
        initialsLabel.setText(initials(u.fullName()));
        nameLabel.setText(u.fullName());
        usernameLabel.setText(u.username());
        statusBadge.setText(u.locked() ? "Bị khóa" : "Hoạt động");
        statusBadge.getStyleClass().setAll("label", "badge", u.locked() ? "bad" : "ok");
        onlineBadge.setText(u.online() ? "Online" : "Offline");
        lockButton.setText(u.locked() ? "Mở khóa" : "Khóa");
        emailLabel.setText(u.email());
        genderLabel.setText(u.gender());
        birthLabel.setText(u.birthDate() == null ? "—" : Tables.DATE.format(u.birthDate()));
        addressLabel.setText(u.address());
        createdLabel.setText(Tables.DATE.format(u.created()));
    }

    /** First letters of the last two words, e.g. "Trần Thị Bích" → "TB". */
    static String initials(String fullName) {
        String[] words = fullName.trim().split("\\s+");
        return Arrays.stream(words, Math.max(0, words.length - 2), words.length)
                .map(w -> w.substring(0, 1).toUpperCase(AdminNavigator.LOCALE))
                .collect(Collectors.joining());
    }

    @FXML
    private void onAdd() {
        AdminNavigator.openUserForm(null);
    }

    @FXML
    private void onEdit() {
        AdminNavigator.openUserForm(table.getSelectionModel().getSelectedItem());
    }

    @FXML
    private void onResetPassword() {
        AdminNavigator.openDialog("ResetPasswordDialog", "Đặt lại mật khẩu");
    }
}
