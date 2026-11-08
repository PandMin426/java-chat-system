package com.chatapp.admin.controller;

import com.chatapp.admin.AdminNavigator;
import com.chatapp.admin.sample.SampleData;
import com.chatapp.admin.sample.SampleData.FriendStatRow;
import javafx.fxml.FXML;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;

import java.text.Collator;
import java.time.LocalDate;

/** S16 Số lượng bạn bè. V1: sample rows matching "&gt; 5"; filtering comes with the admin-stats feature. */
public class FriendStatsController {

    @FXML
    private TableView<FriendStatRow> table;
    @FXML
    private TableColumn<FriendStatRow, String> usernameColumn;
    @FXML
    private TableColumn<FriendStatRow, String> nameColumn;
    @FXML
    private TableColumn<FriendStatRow, LocalDate> createdColumn;
    @FXML
    private TableColumn<FriendStatRow, Integer> directColumn;
    @FXML
    private TableColumn<FriendStatRow, Integer> twoHopColumn;

    @FXML
    private void initialize() {
        Tables.text(usernameColumn, FriendStatRow::username, true);
        Tables.text(nameColumn, FriendStatRow::fullName, false);
        nameColumn.setComparator(Collator.getInstance(AdminNavigator.LOCALE)::compare);
        Tables.date(createdColumn, FriendStatRow::created, Tables.DATE);
        Tables.number(directColumn, FriendStatRow::direct);
        Tables.number(twoHopColumn, FriendStatRow::withFriendsOfFriends);
        table.getItems().setAll(SampleData.FRIEND_STATS.stream().filter(r -> r.direct() > 5).toList());
        table.getSortOrder().add(nameColumn);
    }
}
