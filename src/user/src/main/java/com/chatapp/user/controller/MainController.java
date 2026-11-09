package com.chatapp.user.controller;

import com.chatapp.user.Navigator;
import javafx.fxml.FXML;
import javafx.scene.control.ToggleButton;
import javafx.scene.layout.BorderPane;

/** Main window shell: the icon rail switches the view shown in the center. */
public class MainController {

    @FXML
    private BorderPane root;
    @FXML
    private ToggleButton chatsButton;
    @FXML
    private ToggleButton friendsButton;
    @FXML
    private ToggleButton searchButton;
    @FXML
    private ToggleButton profileButton;

    /** Shows {@code view} (an FXML name in the view folder) and highlights its rail button. */
    public void setContent(String view) {
        root.setCenter(Navigator.load(view));
        ToggleButton active = switch (view) {
            case "FriendsView" -> friendsButton;
            case "SearchUsersView" -> searchButton;
            case "ProfileView" -> profileButton;
            default -> chatsButton;
        };
        active.setSelected(true);
    }

    @FXML
    private void onChats() {
        Navigator.showMain("ChatView");
    }

    @FXML
    private void onFriends() {
        Navigator.showMain("FriendsView");
    }

    @FXML
    private void onSearchUsers() {
        Navigator.showMain("SearchUsersView");
    }

    @FXML
    private void onProfile() {
        Navigator.showMain("ProfileView");
    }

    @FXML
    private void onLogout() {
        Navigator.showAuth("LoginView");
    }
}
