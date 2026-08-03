//
//  AccountMenuView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 7/27/26.
//

import SwiftUI
import SwiftData
import Charts
import Foundation

struct AccountMenuView: View {
    let profile: Profile
    let selectedAccount: Account

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var sevenDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: today)!
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var snapshots: [Snapshot]

    @State private var selectedDate: Date?
    @State private var dateIdle: Date?
    @State private var chartRefreshID = UUID()

    private var filteredSnapshots: [Snapshot] {
        snapshots
            .filter { $0.accountName == selectedAccount.name }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var selectionText: String {
        let displayedDate = selectedDate ?? dateIdle ?? filteredSnapshots.last?.createdAt ?? Date()
        let selectedSnapshot = snapshot(for: displayedDate)
        let amountText = selectedSnapshot?.amount.formatted(.currency(code: "USD")) ?? "$0.00"
        let dateText = dateFormatter.string(from: displayedDate)

        return "Selected day: \(dateText) • Amount: \(amountText)"
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedAccount.name)
                .font(.headline)

            Text(selectionText)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .foregroundStyle(.blue)
            
            Spacer(minLength: 8)

            Chart {
                ForEach(filteredSnapshots) { snap in
                    BarMark(
                        x: .value("Day", snap.createdAt, unit: .day),
                        y: .value("Amount", snap.amount)
                    )
                    .foregroundStyle(
                        isSelectedSnapshot(snap)
                            ? Color.accentColor
                            : Color.blue.opacity(0.75)
                    )
                }
            }
            .chartXSelection(value: $selectedDate)
            .chartXAxis {
                AxisMarks(values: .automatic)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding()
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .gray.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .id(chartRefreshID)
        .padding()
        .onAppear {
            ensureDailySnapshots()

            if selectedDate == nil, let latest = filteredSnapshots.last?.createdAt {
                if dateIdle == nil {
                    selectedDate = latest
                    dateIdle = latest
                } else {
                    selectedDate = dateIdle
                }
            }
        }
        .onChange(of: selectedAccount.name) {
            selectedDate = filteredSnapshots.last?.createdAt
        }
        .onChange(of: selectedDate) {
            if selectedDate != nil {
                dateIdle = selectedDate
            }
        }
    }

    private func ensureDailySnapshots() {
        let accountSnapshots = filteredSnapshots
        guard accountSnapshots.count > 1 else { return }

        var lastValidSnapshot: Snapshot? = nil
        let calendar = Calendar.current
        var existingDayKeys = Set(accountSnapshots.map { calendar.startOfDay(for: $0.createdAt) })

        for snapshot in accountSnapshots {
            if let previousSnapshot = lastValidSnapshot {
                let previousDay = calendar.startOfDay(for: previousSnapshot.createdAt)
                let currentDay = calendar.startOfDay(for: snapshot.createdAt)
                var fillDate = calendar.date(byAdding: .day, value: 1, to: previousDay) ?? previousDay

                while fillDate < currentDay {
                    if !existingDayKeys.contains(fillDate) {
                        let filledSnapshot = Snapshot(
                            createdAt: fillDate,
                            name: selectedAccount.name,
                            amount: previousSnapshot.amount
                        )
                        modelContext.insert(filledSnapshot)
                        existingDayKeys.insert(fillDate)
                    }

                    fillDate = calendar.date(byAdding: .day, value: 1, to: fillDate) ?? fillDate
                }
            }

            lastValidSnapshot = snapshot
        }

        if modelContext.hasChanges {
            try? modelContext.save()
            chartRefreshID = UUID()
        }
    }

    private func snapshot(for date: Date) -> Snapshot? {
        let targetDay = Calendar.current.startOfDay(for: date)

        if let exactDayMatch = filteredSnapshots.first(where: {
            Calendar.current.isDate(Calendar.current.startOfDay(for: $0.createdAt), inSameDayAs: targetDay)
        }) {
            return exactDayMatch
        }

        return filteredSnapshots.last(where: { $0.createdAt <= targetDay }) ?? filteredSnapshots.first
    }

    private func isSelectedSnapshot(_ snapshot: Snapshot) -> Bool {
        guard let selectedDate else { return false }

        let targetDay = Calendar.current.startOfDay(for: selectedDate)
        let snapshotDay = Calendar.current.startOfDay(for: snapshot.createdAt)

        return Calendar.current.isDate(snapshotDay, inSameDayAs: targetDay)
    }
}
