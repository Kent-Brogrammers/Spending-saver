//
//  AnalyticsView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var expenseStore: ExpenseStore

    private var allTransactions: [ExpenseItem] {
        expenseStore.expenses
    }

    private var totalSpent: Double {
        allTransactions.reduce(0) { $0 + $1.amount }
    }

    private var averageExpense: Double {
        guard !allTransactions.isEmpty else {
            return 0
        }

        return totalSpent / Double(allTransactions.count)
    }

    private var essentialSpent: Double {
        allTransactions.filter(\.isEssential).reduce(0) { $0 + $1.amount }
    }

    private var nonEssentialSpent: Double {
        allTransactions.filter { !$0.isEssential }.reduce(0) { $0 + $1.amount }
    }

    private var categoryBreakdown: [(category: String, total: Double, share: Double)] {
        guard totalSpent > 0 else {
            return []
        }

        let grouped = Dictionary(grouping: allTransactions, by: \.category)

        return grouped
            .map { category, items in
                let total = items.reduce(0) { $0 + $1.amount }
                return (category: category, total: total, share: total / totalSpent)
            }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Analytics")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)

                summaryCard

                HStack(spacing: 14) {
                    metricCard(
                        title: "Transactions",
                        value: "\(allTransactions.count)",
                        detail: "Total tracked purchases",
                        accent: .cyan
                    )

                    metricCard(
                        title: "Average",
                        value: currencyString(averageExpense),
                        detail: "Average per purchase",
                        accent: .orange
                    )
                }

                HStack(spacing: 14) {
                    metricCard(
                        title: "Essential",
                        value: currencyString(essentialSpent),
                        detail: "Needs and recurring basics",
                        accent: .green
                    )

                    metricCard(
                        title: "Non-essential",
                        value: currencyString(nonEssentialSpent),
                        detail: "Flexible spending",
                        accent: .yellow
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Category Breakdown")
                        .font(.headline)
                        .foregroundColor(.white)

                    if categoryBreakdown.isEmpty {
                        Text("Add a few expenses to see where most of your money is going.")
                            .foregroundColor(.white.opacity(0.72))
                    } else {
                        ForEach(categoryBreakdown, id: \.category) { category in
                            categoryRow(category: category.category, total: category.total, share: category.share)
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .foregroundColor(.white)

                    if allTransactions.isEmpty {
                        Text("No expenses yet")
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        ForEach(allTransactions.prefix(6)) { expense in
                            transactionRow(expense)
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(.bottom, 20)
        }
    }

    var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Analytics explains where your money goes")
                .foregroundColor(.white)
                .font(.headline)

            Text(currencyString(totalSpent))
                .foregroundColor(.white)
                .font(.system(size: 34, weight: .bold))

            Text(summaryText)
                .foregroundColor(.white.opacity(0.8))

            Text("This page is for totals, category breakdowns, and averages.")
                .font(.footnote)
                .foregroundColor(.cyan.opacity(0.9))
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    func metricCard(title: String, value: String, detail: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(value)
                .foregroundColor(accent)
                .font(.system(size: 28, weight: .bold))
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text(detail)
                .font(.caption)
                .foregroundColor(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    func categoryRow(category: String, total: Double, share: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .foregroundColor(.white)

                Spacer()

                Text(currencyString(total))
                    .foregroundColor(.white.opacity(0.85))
                    .fontWeight(.semibold)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.95), Color.green.opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geometry.size.width * share, 12))
                }
            }
            .frame(height: 10)

            Text(share.formatted(.percent.precision(.fractionLength(0))))
                .font(.caption)
                .foregroundColor(.white.opacity(0.68))
        }
        .padding(.vertical, 8)
    }

    func transactionRow(_ expense: ExpenseItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.name)
                    .foregroundColor(.white)

                Text(expense.category)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }

            Spacer()

            Text(currencyString(expense.amount))
                .foregroundColor(.white.opacity(0.82))
        }
        .padding(.vertical, 8)
    }

    var summaryText: String {
        if allTransactions.isEmpty {
            return "Add a few purchases and this screen will break down where your money is going."
        }

        let focusCategory = categoryBreakdown.first?.category ?? "your top category"
        return "Most of your spending is currently going toward \(focusCategory), and your average purchase is \(currencyString(averageExpense))."
    }

    func currencyString(_ amount: Double) -> String {
        amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(ExpenseStore())
}
