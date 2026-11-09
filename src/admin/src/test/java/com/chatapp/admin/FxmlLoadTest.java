package com.chatapp.admin;

import com.chatapp.admin.sample.SampleData;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestFactory;

import java.util.List;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/** Loads every FXML view of the admin app (with its controller and sample data) on the JavaFX thread. */
class FxmlLoadTest {

    static final List<String> MAIN_VIEWS = List.of("UsersView", "LoginLogView", "GroupsView", "SpamView",
            "NewUsersView", "FriendStatsView", "ActiveUsersView");

    @BeforeAll
    static void startToolkit() {
        FxTestSupport.startToolkit();
    }

    @Test
    void allPlannedViewsExist() throws Exception {
        assertEquals(11, FxTestSupport.viewNames().size(), FxTestSupport.viewNames().toString());
    }

    @TestFactory
    Stream<DynamicTest> everyViewLoads() throws Exception {
        return FxTestSupport.viewNames().stream().map(view -> DynamicTest.dynamicTest(view,
                () -> assertNotNull(FxTestSupport.onFx(() -> AdminNavigator.load(view)))));
    }

    @TestFactory
    Stream<DynamicTest> everyViewLoadsInsideMainWindow() {
        return MAIN_VIEWS.stream().map(view -> DynamicTest.dynamicTest("AdminMainView + " + view,
                () -> assertNotNull(FxTestSupport.onFx(() -> AdminNavigator.buildMain(view)))));
    }

    @Test
    void userFormLoadsInBothModes() throws Exception {
        assertNotNull(FxTestSupport.onFx(() -> AdminNavigator.buildUserForm(null)));
        assertNotNull(FxTestSupport.onFx(() -> AdminNavigator.buildUserForm(SampleData.USERS.get(8))));
    }
}
