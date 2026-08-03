# Charts in this app

## Flow of the charts system

1. The account view collects snapshots for the currently selected account.
2. Those snapshots are filtered by account name and sorted by date.
3. The chart renders each snapshot as a bar using BarMark.
4. Tapping or selecting a bar updates the chart selection state.
5. The selected date is used to build the summary text at the top of the screen.
6. If a selected day has no direct snapshot, the app falls back to the most recent earlier snapshot.

## How the chart works in this project

- The main chart lives in AccountMenuView.swift.
- Snapshots are read from SwiftData through the @Query property wrapper.
- Each snapshot becomes a bar using the createdAt date for the x-axis and amount for the y-axis.
- The selection binding is connected with chartXSelection(value: $selectedDate).
- The summary label uses the selected date to show the day and amount in user-friendly text.

## Useful chart modifiers

Here are common modifiers you can apply to SwiftUI charts:

- chartXScale(domain: ...) – changes the range of the x-axis.
- chartYScale(domain: ...) – changes the range of the y-axis.
- chartXAxis { ... } – customizes the x-axis, including labels and ticks.
- chartYAxis { ... } – customizes the y-axis, including labels and ticks.
- chartXSelection(value: $selectedDate) – enables selection for the chart.
- foregroundStyle(...) – changes the color of a mark.
- annotation(...) – adds labels or callouts near a data point.
- symbol(...) – changes the shape used for point marks.
- lineStyle(...) – changes the appearance of line marks.
- interpolationMethod(...) – controls how line charts connect points.
- padding() – adds spacing around the chart.
- background(..., in: RoundedRectangle(...)) – adds a styled backdrop.
- shadow(...) – adds depth to the chart container.

## Quick examples

### Make the chart more polished

```swift
Chart {
    ForEach(filteredSnapshots) { snap in
        BarMark(
            x: .value("Day", snap.createdAt, unit: .day),
            y: .value("Amount", snap.amount)
        )
        .foregroundStyle(.blue)
    }
}
.chartXAxis {
    AxisMarks(values: .automatic)
}
.chartYAxis {
    AxisMarks(position: .leading)
}
.padding()
.background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
.shadow(color: .gray.opacity(0.15), radius: 6, x: 0, y: 3)
```

### Add a selection binding

```swift
@State private var selectedDate: Date?

Chart {
    ForEach(filteredSnapshots) { snap in
        BarMark(
            x: .value("Day", snap.createdAt, unit: .day),
            y: .value("Amount", snap.amount)
        )
    }
}
.chartXSelection(value: $selectedDate)
```
