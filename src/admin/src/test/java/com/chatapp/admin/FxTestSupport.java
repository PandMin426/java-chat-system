package com.chatapp.admin;

import javafx.application.Platform;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.stream.Stream;

/** JavaFX start-up, FX-thread execution and view listing shared by the admin tests. */
final class FxTestSupport {

    private static boolean started;

    private FxTestSupport() {
    }

    static synchronized void startToolkit() {
        if (!started) {
            Locale.setDefault(AdminNavigator.LOCALE);
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
        Path dir = Path.of(AdminNavigator.class.getResource(AdminNavigator.VIEW_DIR).toURI());
        try (Stream<Path> files = Files.list(dir)) {
            return files.map(p -> p.getFileName().toString())
                    .filter(name -> name.endsWith(".fxml"))
                    .map(name -> name.substring(0, name.length() - ".fxml".length()))
                    .sorted()
                    .toList();
        }
    }
}
