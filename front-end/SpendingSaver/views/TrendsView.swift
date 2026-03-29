//
//  TrendsView.swift
//  SpendingSaver
//
//  Created by OpenAI on 8/15/25.
//

import SwiftUI

struct TrendsView: View {
    @EnvironmentObject var expenseStore: ExpenseStore
    @Environment(\.colorScheme) private var colorScheme

    private let calendar = Calendar.current

    private var datedExpenses: [ExpenseItem] {
        expenseStore.expenses.filter { $0.createdAt != nil }
    }

    private var allExpenses: [ExpenseItem] {
        expenseStore.expenses
    }

    private var hasCalendarTrendData: Bool {
        !datedExpenses.isEmpty
    }

    private var currentMonthExpenses: [ExpenseItem] {
        datedExpenses.filter { expense in
            guard let createdAt = expense.createdAt else { return false }
            return calendar.isDate(createdAt, equalTo: Date(), toGranularity: .month)
        }
    }

    private var previousMonthExpenses: [ExpenseItem] {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            return []
        }

        return datedExpenses.filter { expense in
            guard let createdAt = expense.createdAt else { return false }
            return calendar.isDate(createdAt, equalTo: previousMonth, toGranularity: .month)
        }
    }

    private var currentMonthTotal: Double {
        currentMonthExpenses.reduce(0) { $0 + $1.amount }
    }

    private var previousMonthTotal: Double {
        previousMonthExpenses.reduce(0) { $0 + $1.amount }
    }

    private var totalTracked: Double {
        allExpenses.reduce(0) { $0 + $1.amount }
    }

    private var monthDelta: Double {
        currentMonthTotal - previousMonthTotal
    }

    private var monthDeltaPercent: Double? {
        guard previousMonthTotal > 0 else {
            return nil
        }

        return (monthDelta / previousMonthTotal) * 100
    }

    private var dailyAverageThisMonth: Double {
        guard !currentMonthExpenses.isEmpty else {
            return 0
        }

        let daysElapsed = max(calendar.component(.day, from: Date()), 1)
        return currentMonthTotal / Double(daysElapsed)
    }

    private var topCategoryThisMonth: (name: String, total: Double)? {
        let grouped = Dictionary(grouping: currentMonthExpenses, by: \.category)
        let categoryTotals = grouped.map { key, value in
            (name: key, total: value.reduce(0) { $0 + $1.amount })
        }

        return categoryTotals.max { $0.total < $1.total }
    }

    private var essentialShareThisMonth: Double {
        guard currentMonthTotal > 0 else {
            return 0
        }

        let essentialTotal = currentMonthExpenses
            .filter(\.isEssential)
            .reduce(0) { $0 + $1.amount }

        return essentialTotal / currentMonthTotal
    }

    private var essentialShareOverall: Double {
        guard totalTracked > 0 else {
            return 0
        }

        let essentialTotal = allExpenses
            .filter(\.isEssential)
            .reduce(0) { $0 + $1.amount }

        return essentialTotal / totalTracked
    }

    private var topCategoryOverall: (name: String, total: Double)? {
        let grouped = Dictionary(grouping: allExpenses, by: \.category)
        let categoryTotals = grouped.map { key, value in
            (name: key, total: value.reduce(0) { $0 + $1.amount })
        }

        return categoryTotals.max { $0.total < $1.total }
    }

    private var averageExpenseOverall: Double {
        guard !allExpenses.isEmpty else {
            return 0
        }

        return totalTracked / Double(allExpenses.count)
    }

    private var recentMonths: [(month: Date, total: Double)] {
        let grouped = Dictionary(grouping: datedExpenses) { expense in
            calendar.dateInterval(of: .month, for: expense.createdAt ?? Date())?.start ?? Date()
        }

        return grouped
            .map { month, items in
                (month: month, total: items.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.month > $1.month }
            .prefix(4)
            .map { $0 }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Trends")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)

                summaryCard

                HStack(spacing: 14) {
                    metricCard(
                        title: hasCalendarTrendData ? "This Month" : "Tracked Total",
                        value: currencyString(hasCalendarTrendData ? currentMonthTotal : totalTracked),
                        detail: hasCalendarTrendData ? "\(currentMonthExpenses.count) purchases" : "\(allExpenses.count) purchases",
                        accent: .cyan
                    )

                    metricCard(
                        title: hasCalendarTrendData ? "Last Month" : "Monthly Outlook",
                        value: currencyString(hasCalendarTrendData ? previousMonthTotal : expenseStore.projections.monthly),
                        detail: hasCalendarTrendData ? "\(previousMonthExpenses.count) purchases" : "Based on your current pace",
                        accent: .mint
                    )
                }

                HStack(spacing: 14) {
                    metricCard(
                        title: hasCalendarTrendData ? "Daily Avg" : "Average Expense",
                        value: currencyString(hasCalendarTrendData ? dailyAverageThisMonth : averageExpenseOverall),
                        detail: hasCalendarTrendData ? "Based on this month so far" : "Across all recorded purchases",
                        accent: .orange
                    )

                    metricCard(
                        title: "Essential Share",
                        value: (hasCalendarTrendData ? essentialShareThisMonth : essentialShareOverall)
                            .formatted(.percent.precision(.fractionLength(0))),
                        detail: hasCalendarTrendData ? "Of this month's spending" : "Across all recorded spending",
                        accent: .green
                    )
                }

                VStack(alignment: .leading, spacing: 14) {
                    sectionTitle("Key Takeaways")

                    insightRow(
                        icon: monthDelta <= 0 ? "arrow.down.right" : "arrow.up.right",
                        title: hasCalendarTrendData ? "Month-over-month movement" : "Spending summary",
                        detail: monthChangeText
                    )

                    insightRow(
                        icon: "chart.bar.fill",
                        title: hasCalendarTrendData ? "Top category this month" : "Top category overall",
                        detail: topCategoryText
                    )

                    insightRow(
                        icon: "calendar.badge.clock",
                        title: "Projected finish",
                        detail: projectedMonthText
                    )
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 14) {
                    sectionTitle(hasCalendarTrendData ? "Recent Months" : "Spending Notes")

                    if recentMonths.isEmpty {
                        Text(recentMonthsFallbackText)
                            .foregroundColor(secondaryTextColor)
                    } else {
                        ForEach(recentMonths, id: \.month) { month in
                            monthRow(month: month.month, total: month.total)
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )

                Spacer(minLength: 170)
            }
            .padding(.bottom, 20)
        }
    }

    var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(monthHeadline)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(primaryTextColor)

            Text(monthSummary)
                .foregroundColor(secondaryTextColor)

            if expenseStore.isLoading && expenseStore.expenses.isEmpty {
                ProgressView()
                    .tint(primaryTextColor)
                    .padding(.top, 4)
            }

            Text("This page is for patterns over time, momentum, and direction.")
                .font(.footnote)
                .foregroundColor(colorScheme == .dark ? .cyan.opacity(0.9) : Color.blue.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    func metricCard(title: String, value: String, detail: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(primaryTextColor)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(accent)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text(detail)
                .font(.caption)
                .foregroundColor(secondaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    func insightRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(primaryTextColor)

                Text(detail)
                    .foregroundColor(secondaryTextColor)
            }
        }
        .padding(14)
        .background(rowBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    func monthRow(month: Date, total: Double) -> some View {
        HStack {
            Text(month.formatted(.dateTime.month(.wide).year()))
                .foregroundColor(primaryTextColor)

            Spacer()

            Text(currencyString(total))
                .foregroundColor(secondaryTextColor)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
    }

    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(primaryTextColor)
    }

    var monthHeadline: String {
        if !hasCalendarTrendData && !allExpenses.isEmpty {
            return "Here is a simple view of your spending"
        }

        if currentMonthExpenses.isEmpty {
            return "Your spending trends will show up here"
        }

        if monthDelta < 0 {
            return "You are spending less than last month"
        }

        if monthDelta > 0 {
            return "Your spending is higher this month"
        }

        return "This month is tracking close to last month"
    }

    var monthSummary: String {
        if !hasCalendarTrendData && !allExpenses.isEmpty {
            return "These insights are based on your recorded expenses and are designed to give you a quick read on where your money is going."
        }

        if currentMonthExpenses.isEmpty {
            return "Keep logging expenses and this page will start showing monthly patterns, category shifts, and useful comparisons."
        }

        if previousMonthExpenses.isEmpty {
            return "So far this month you have logged \(currentMonthExpenses.count) purchases totaling \(currencyString(currentMonthTotal)). Add more activity to unlock stronger month-to-month comparisons."
        }

        return "You have spent \(currencyString(currentMonthTotal)) this month compared with \(currencyString(previousMonthTotal)) last month."
    }

    var monthChangeText: String {
        if !hasCalendarTrendData && !allExpenses.isEmpty {
            return "Your spending totals are ready to review. As you keep logging purchases over time, this card will become a true month-to-month comparison."
        }

        guard !currentMonthExpenses.isEmpty else {
            return "There is not enough activity yet to show a meaningful month-to-month comparison."
        }

        guard let monthDeltaPercent else {
            return "This is the first month with enough data to analyze, so there is not a previous month to compare against yet."
        }

        let direction = monthDelta <= 0 ? "down" : "up"
        return "You are \(direction) \(currencyString(abs(monthDelta))) from last month, which is a \(abs(monthDeltaPercent)).formatted(.number.precision(.fractionLength(0)))% change."
    }

    var topCategoryText: String {
        if !hasCalendarTrendData {
            guard let topCategoryOverall else {
                return "There is not enough category data yet to show a clear leader."
            }

            return "\(topCategoryOverall.name) is your biggest category overall at \(currencyString(topCategoryOverall.total))."
        }

        guard let topCategoryThisMonth else {
            return "There is not enough category activity this month to show a leader yet."
        }

        return "\(topCategoryThisMonth.name) is leading this month at \(currencyString(topCategoryThisMonth.total))."
    }

    var projectedMonthText: String {
        if !hasCalendarTrendData && !allExpenses.isEmpty {
            return "At your current pace, your monthly spending outlook is about \(currencyString(expenseStore.projections.monthly))."
        }

        guard !currentMonthExpenses.isEmpty else {
            return "Add a few expenses this month and we will estimate where your total is heading."
        }

        let totalDays = calendar.range(of: .day, in: .month, for: Date())?.count ?? 30
        let projected = dailyAverageThisMonth * Double(totalDays)
        return "If this pace continues, you could finish the month around \(currencyString(projected))."
    }

    func currencyString(_ amount: Double) -> String {
        amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    var recentMonthsFallbackText: String {
        if allExpenses.isEmpty {
            return "Add a few expenses with dates and this section will start showing your month-by-month progress."
        }

        return "You already have enough activity for useful insights. As more purchases build up over time, this section will become even more detailed."
    }

    var primaryTextColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.10, green: 0.15, blue: 0.24)
    }

    var secondaryTextColor: Color {
        colorScheme == .dark ? .white.opacity(0.8) : Color(red: 0.24, green: 0.30, blue: 0.40)
    }

    var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.08)
    }

    var rowBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04)
    }
}

#Preview {
    TrendsView()
        .environmentObject(ExpenseStore())
}
