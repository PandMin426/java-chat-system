package com.chatapp.user;

import javafx.application.Platform;
import javafx.scene.Parent;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.TestFactory;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/** Loads every FXML view of the user app (with its controller and sample data) on the JavaFX thread. */
class FxmlLoadTest {

    @BeforeAll
    static void startToolkit() {
        FxTestSupport.startToolkit();
    }

    @TestFactory
    Stream<DynamicTest> everyViewLoads() throws Exception {
        List<String> views = FxTestSupport.viewNames();
        assertFalse(views.isEmpty(), "no FXML files found");
        return views.stream().map(view -> DynamicTest.dynamicTest(view, () -> {
            Parent root = FxTestSupport.onFx(() -> Navigator.load(view));
            assertNotNull(root, view);
        }));
    }

    @TestFactory
    Stream<DynamicTest> everyViewLoadsInsideMainWindow() {
        return Stream.of("ChatView", "GroupChatView", "SearchMessagesView", "FriendsView", "SearchUsersView", "ProfileView")
                .map(view -> DynamicTest.dynamicTest("MainView + " + view,
                        () -> assertNotNull(FxTestSupport.onFx(() -> Navigator.buildMain(view)))));
    }
}

/** Shared JavaFX start-up and view listing for the test classes. */
final class FxTestSupport {

    private static boolean started;

    private FxTestSupport() {
    }

    static synchronized void startToolkit() {
        if (!started) {
            java.util.Locale.setDefault(Navigator.LOCALE);
            Platform.startup(() -> { });
            Platform.setImplicitExit(false);
            started = true;
        }
    }

    static <T> T onFx(Callable<T> task) throws Exception {
        CompletableFuture<T> result = new CompletableFuture<>();
        Platform.runLater(() -> {
            try {
                result.complete(task.call());
            } catch (Throwable t) {
                result.completeExceptionally(t);
            }
        });
        return result.get(30, TimeUnit.SECONDS);
    }

    /** FXML names (without extension) found in the compiled view folder. */
    static List<String> viewNames() throws Exception {
        Path dir = Path.of(Navigator.class.getResource(Navigator.VIEW_DIR).toURI());
        try (Stream<Path> files = Files.list(dir)) {
            return files.map(p -> p.getFileName().toString())
                    .filter(name -> name.endsWith(".fxml"))
                    .map(name -> name.substring(0, name.length() - ".fxml".length()))
                    .sorted()
                    .toList();
        }
    }
}
