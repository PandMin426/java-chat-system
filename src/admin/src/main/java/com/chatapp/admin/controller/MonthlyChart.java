package com.chatapp.admin.controller;

import com.chatapp.admin.sample.SampleData;
import javafx.beans.binding.Bindings;
import javafx.collections.FXCollections;
import javafx.scene.chart.BarChart;
import javafx.scene.chart.CategoryAxis;
import javafx.scene.chart.NumberAxis;
import javafx.scene.chart.XYChart;
import javafx.scene.control.Tooltip;
import javafx.scene.layout.StackPane;
import javafx.scene.text.Text;
import javafx.util.Duration;

import java.util.List;
import java.util.stream.IntStream;

/**
 * One-series monthly bar chart (A6, A9): months T1–T12 on the x-axis, a count on the y-axis.
 * Every bar has a tooltip; only the peak and the current (partial) month carry a value label.
 */
final class MonthlyChart {

    private static final List<String> MONTHS = IntStream.rangeClosed(1, 12).mapToObj(m -> "T" + m).toList();

    private MonthlyChart() {
    }

    /** @param values 12 monthly counts, {@code null} for months without data yet */
    static void fill(BarChart<String, Number> chart, Integer[] values, int year) {
        CategoryAxis x = (CategoryAxis) chart.getXAxis();
        x.setAutoRanging(false);
        x.setCategories(FXCollections.observableArrayList(MONTHS));

        int peak = 0;
        int last = -1;
        for (int i = 0; i < values.length; i++) {
            if (values[i] != null) {
                peak = Math.max(peak, values[i]);
                last = i;
            }
        }
        int current = year == SampleData.TODAY.getYear() ? last : -1;
        double step = peak <= 100 ? 20 : peak <= 200 ? 40 : peak <= 500 ? 100 : 200;
        NumberAxis y = (NumberAxis) chart.getYAxis();
        y.setAutoRanging(false);
        y.setLowerBound(0);
        y.setUpperBound(Math.ceil(peak * 1.12 / step) * step);
        y.setTickUnit(step);
        y.setMinorTickVisible(false);

        XYChart.Series<String, Number> series = new XYChart.Series<>();
        for (int i = 0; i < values.length; i++) {
            if (values[i] != null) {
                series.getData().add(new XYChart.Data<>(MONTHS.get(i), values[i]));
            }
        }
        chart.getData().setAll(List.of(series));

        // BarChart resets each bar's style classes when it is added, so decorate afterwards.
        for (XYChart.Data<String, Number> item : series.getData()) {
            int month = MONTHS.indexOf(item.getXValue());
            int value = item.getYValue().intValue();
            StackPane bar = (StackPane) item.getNode();
            boolean isCurrent = month == current;
            if (isCurrent) {
                bar.getStyleClass().add("current");
            }
            String tip = "Tháng " + (month + 1) + "/" + year + ": " + value + " người" + (isCurrent ? " (đến 08/11)" : "");
            Tooltip tooltip = new Tooltip(tip);
            tooltip.setShowDelay(Duration.millis(100));
            Tooltip.install(bar, tooltip);
            if (value == peak || isCurrent) {
                bar.getChildren().add(valueLabel(bar, value));
            }
        }
    }

    /** Value printed just above the bar, centred; unmanaged so it does not change the bar's size. */
    private static Text valueLabel(StackPane bar, int value) {
        Text label = new Text(String.valueOf(value));
        label.getStyleClass().add("bar-value");
        label.setManaged(false);
        label.layoutXProperty().bind(Bindings.createDoubleBinding(
                () -> (bar.getWidth() - label.getLayoutBounds().getWidth()) / 2,
                bar.widthProperty(), label.layoutBoundsProperty()));
        label.setLayoutY(-6);
        return label;
    }
}
