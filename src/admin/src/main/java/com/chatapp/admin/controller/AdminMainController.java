package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import javafx.fxml.FXML;
import javafx.scene.control.ToggleButton;
import javafx.scene.layout.BorderPane;

/** Admin main window: the left navigation switches the view shown in the center. */
public class AdminMainController {

    @FXML
    private BorderPane root;
    @FXML
    private ToggleButton usersButton;
    @FXML
    private ToggleButton loginLogButton;
    @FXML
    private ToggleButton groupsButton;
    @FXML
    private ToggleButton spamButton;
    @FXML
    private ToggleButton newUsersButton;
    @FXML
    private ToggleButton friendStatsButton;
    @FXML
    private ToggleButton activeButton;

    /** Shows {@code view} (an FXML name in the view folder) and highlights its navigation item. */
    public void setContent(String view) {
        root.setCenter(AdminNavigator.load(view));
        ToggleButton active = switch (view) {
            case "LoginLogView" -> loginLogButton;
            case "GroupsView" -> groupsButton;
            case "SpamView" -> spamButton;
            case "NewUsersView" -> newUsersButton;
            case "FriendStatsView" -> friendStatsButton;
            case "ActiveUsersView" -> activeButton;
            default -> usersButton;
        };
        active.setSelected(true);
    }

    @FXML
    private void onUsers() {
        AdminNavigator.showMain("UsersView");
    }

    @FXML
    private void onLoginLog() {
        AdminNavigator.showMain("LoginLogView");
    }

    @FXML
    private void onGroups() {
        AdminNavigator.showMain("GroupsView");
    }

    @FXML
    private void onSpam() {
        AdminNavigator.showMain("SpamView");
    }

    @FXML
    private void onNewUsers() {
        AdminNavigator.showMain("NewUsersView");
    }

    @FXML
    private void onFriendStats() {
        AdminNavigator.showMain("FriendStatsView");
    }

    @FXML
    private void onActive() {
        AdminNavigator.showMain("ActiveUsersView");
    }

    @FXML
    private void onLogout() {
        AdminNavigator.showLogin();
    }
}
