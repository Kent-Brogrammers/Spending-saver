//
//  TrendsView.swift
//  SpendingSaver
//
//  Created by OpenAI on 8/15/25.
//

import SwiftUI

struct TrendsView: View {
    @EnvironmentObject var expenseStore: ExpenseStore

    

    private var insightCards: [(String, String, String)] {
        [
            (
                "Monthly Outlook",
                "If you keep spending like this, you could spend \(expenseStore.projections.monthly.formatted(.currency(code: "USD"))) in a month.",
                "calendar"
            ),
            (
                "Rent Perspective",
                "That pace could cover rent about \(ratioText(total: expenseStore.projections.yearly, divisor: 1800)) times a year.",
                "house.fill"
            ),
            (
                "MacBook Comparison",
                "That is roughly \(ratioText(total: expenseStore.projections.yearly, divisor: 1599)) MacBooks over a year.",
                "laptopcomputer"
            ),
            (
                "Vacation Fund",
                "That could fund about \(ratioText(total: expenseStore.projections.yearly, divisor: 2500)) vacations.",
                "airplane"
            )
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Trends")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Projection Snapshot")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(expenseStore.projections.yearly, format: .currency(code: "USD"))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    Text("Estimated annual spending based on your current recorded pace.")
                        .foregroundColor(.white.opacity(0.75))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

                ForEach(insightCards, id: \.0) { card in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: card.2)
                                .foregroundColor(.cyan)
                            Text(card.0)
                                .font(.headline)
                                .foregroundColor(.white)
                        }

                        Text(card.1)
                            .foregroundColor(.white.opacity(0.82))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }

                Spacer(minLength: 170)
            }
            .padding(.bottom, 20)
        }
    }

    private func ratioText(total: Double, divisor: Double) -> String {
        guard divisor > 0 else {
            return "0.0"
        }
        return String(format: "%.1f", total / divisor)
    }
}

#Preview {
    TrendsView()
        .environmentObject(ExpenseStore())
}

