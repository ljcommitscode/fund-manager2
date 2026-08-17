//
//  AutomatorPreviewView.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import SwiftUI

struct AutomatorPreviewView: View {

    let amount: Double
    let allocations: [AutomatorAllocation]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Automator Preview")
                .font(.headline)

            Text(amount, format: .currency(code: "USD"))
                .font(.title2)
                .fontWeight(.semibold)

            ForEach(allocations) { allocation in

                VStack(alignment: .leading, spacing: 4) {

                    Text(allocation.accountName)
                        .font(.headline)

                    HStack {
                        Text(
                            allocation.currentAmount,
                            format: .currency(code: "USD")
                        )

                        Image(systemName: "arrow.right")

                        Text(
                            allocation.updatedAmount,
                            format: .currency(code: "USD")
                        )
                    }

                    Text(
                        allocation.change,
                        format: .currency(code: "USD")
                    )
                    .foregroundStyle(
                        allocation.change >= 0
                        ? .green
                        : .red
                    )
                }
            }
        }
        .padding()
    }
}
