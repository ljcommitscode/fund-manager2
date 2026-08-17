//
//  ChartsWidgetView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import SwiftUI
import Charts
import WidgetKit

struct ChartsWidgetView: View {

    let entry: ChartsWidgetEntry

    private var chartSnapshots: [WidgetSnapshot] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var snapshotsByDay: [Date: WidgetSnapshot] = [:]

        for snapshot in entry.snapshots {
            let day = calendar.startOfDay(for: snapshot.date)

            guard day <= today else {
                continue
            }

            if let existing = snapshotsByDay[day] {
                if snapshot.date > existing.date {
                    snapshotsByDay[day] = snapshot
                }
            } else {
                snapshotsByDay[day] = snapshot
            }
        }

        var result: [WidgetSnapshot] = []
        var previousAmount = 0.0

        for offset in stride(from: -6, through: 0, by: 1) {

            guard let day = calendar.date(
                byAdding: .day,
                value: offset,
                to: today
            ) else {
                continue
            }

            if let snapshot = snapshotsByDay[day] {
                previousAmount = snapshot.amount

                result.append(
                    WidgetSnapshot(
                        date: day,
                        amount: snapshot.amount
                    )
                )
            } else {
                result.append(
                    WidgetSnapshot(
                        date: day,
                        amount: previousAmount
                    )
                )
            }
        }

        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.accountName)
                        .font(.headline)
                        .lineLimit(1)

                    Text(
                        entry.currentAmount,
                        format: .currency(code: "USD")
                    )
                    .font(.title)
                    .fontWeight(.semibold)
                }

                Spacer()
            }

            chart
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .containerBackground(
            .fill.tertiary,
            for: .widget
        )
    }

    @ViewBuilder
    private var chart: some View {
        switch entry.graphType {

        case .line:
            LineMarkChart(
                snapshots: chartSnapshots
            )

        case .bar:
            BarMarkChart(
                snapshots: chartSnapshots
            )
        }
    }
}

// MARK: - Line Chart

private struct LineMarkChart: View {

    let snapshots: [WidgetSnapshot]

    var body: some View {

        Chart(snapshots, id: \.date) { snapshot in

            LineMark(
                x: .value("Date", snapshot.date),
                y: .value("Balance", snapshot.amount)
            )
            .interpolationMethod(.linear)

            PointMark(
                x: .value("Date", snapshot.date),
                y: .value("Balance", snapshot.amount)
            )
        }
        .chartXAxis {
            AxisMarks(values: snapshots.map(\.date)) { value in
                AxisGridLine()

                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(
                            date,
                            format: .dateTime.weekday(.abbreviated)
                        )
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()

                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(
                            amount,
                            format: .currency(code: "USD")
                                .precision(.fractionLength(0))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Bar Chart

private struct BarMarkChart: View {

    let snapshots: [WidgetSnapshot]

    var body: some View {

        Chart(snapshots, id: \.date) { snapshot in

            BarMark(
                x: .value("Date", snapshot.date),
                y: .value("Balance", snapshot.amount)
            )
        }
        .chartXAxis {
            AxisMarks(values: snapshots.map(\.date)) { value in
                AxisGridLine()

                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(
                            date,
                            format: .dateTime.weekday(.abbreviated)
                        )
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()

                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(
                            amount,
                            format: .currency(code: "USD")
                                .precision(.fractionLength(0))
                        )
                    }
                }
            }
        }
    }
}
