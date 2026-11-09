package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import javafx.fxml.FXML;

/** S10 Đăng nhập quản trị. V1: navigation only; the admin-role check comes with the auth feature. */
public class AdminLoginController {

    @FXML
    private void onLogin() {
        AdminNavigator.showMain("UsersView");
    }
}
