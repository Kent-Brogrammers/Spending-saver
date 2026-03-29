//
//  HealthView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct HealthView: View {
    @EnvironmentObject var expenseStore: ExpenseStore

    private var allExpenses: [ExpenseItem] {
        expenseStore.expenses
    }

    private var convenienceExpenses: [ExpenseItem] {
        allExpenses.filter {
            ["Coffee", "Fast Food", "Shopping"].contains($0.category)
        }
    }

    private var essentialExpenses: [ExpenseItem] {
        allExpenses.filter(\.isEssential)
    }

    private var convenienceTotal: Double {
        convenienceExpenses.reduce(0) { $0 + $1.amount }
    }

    private var essentialTotal: Double {
        essentialExpenses.reduce(0) { $0 + $1.amount }
    }

    private var totalSpent: Double {
        allExpenses.reduce(0) { $0 + $1.amount }
    }

    private var topConvenienceCategory: String? {
        let grouped = Dictionary(grouping: convenienceExpenses, by: \.category)
        return grouped.max { $0.value.count < $1.value.count }?.key
    }

    private var healthHeadline: String {
        if allExpenses.isEmpty {
            return "Your wellness snapshot will show up here"
        }

        if convenienceTotal == 0 {
            return "Your spending habits look fairly balanced"
        }

        if convenienceExpenses.count <= 2 {
            return "A few small swaps could improve your routine"
        }

        return "Your convenience spending may be creeping up"
    }

    private var healthSummary: String {
        if allExpenses.isEmpty {
            return "As you log food, coffee, and convenience purchases, this screen will turn your spending into simple wellness insights."
        }

        if let topConvenienceCategory {
            return "\(topConvenienceCategory) is showing up the most in your convenience spending, which makes this a good habit to watch."
        }

        return "Most of your current spending is landing in essential categories, which usually points to a steadier routine."
    }

    private var healthConcerns: [(String, String, String)] {
        var concerns: [(String, String, String)] = []

        if convenienceExpenses.contains(where: { $0.category == "Coffee" }) {
            concerns.append((
                "cup.and.saucer.fill",
                "Coffee runs are adding up",
                "Frequent coffee purchases can point to stress-driven spending and a more expensive daily routine."
            ))
        }

        if convenienceExpenses.contains(where: { $0.category == "Fast Food" }) {
            concerns.append((
                "fork.knife",
                "Grab-and-go meals are showing up",
                "That can be a sign of rushed days, convenience eating, and higher sodium spending patterns."
            ))
        }

        if convenienceExpenses.count >= 3 {
            concerns.append((
                "bolt.fill",
                "Impulse spending may be part of the pattern",
                "Repeated small purchases often feel harmless, but they can quietly become a daily habit."
            ))
        }

        if concerns.isEmpty {
            concerns.append((
                "heart.fill",
                "No strong risk signals yet",
                "Your current spending pattern does not show a major convenience-spending spike."
            ))
        }

        return concerns
    }

    private var suggestionList: [String] {
        var suggestions: [String] = []

        if convenienceExpenses.contains(where: { $0.category == "Coffee" }) {
            suggestions.append("Pick 2 mornings this week to make coffee at home and compare the savings.")
        }

        if convenienceExpenses.contains(where: { $0.category == "Fast Food" }) {
            suggestions.append("Plan one quick backup meal so convenience food is not the default choice.")
        }

        if convenienceTotal > essentialTotal && totalSpent > 0 {
            suggestions.append("Your flexible spending is ahead of essentials right now. Try setting one simple weekly cap.")
        }

        if suggestions.isEmpty {
            suggestions.append("Keep logging consistently so this page can spot stronger patterns over time.")
            suggestions.append("Use the Trends page alongside this one to compare financial habits month to month.")
        }

        return suggestions
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Health")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)

                summaryCard

                VStack(alignment: .leading, spacing: 12) {
                    Text("What We Noticed")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(healthConcerns, id: \.1) { concern in
                        healthRiskRow(icon: concern.0, title: concern.1, detail: concern.2)
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
                    Text("Easy Wins")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(suggestionList, id: \.self) { suggestion in
                        suggestionRow(suggestion)
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                Spacer(minLength: 120)
            }
            .padding(.bottom, 20)
        }
    }

    var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(healthHeadline)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)

            Text(healthSummary)
                .foregroundColor(.white.opacity(0.82))
                .font(.subheadline)

            Text("This page focuses on habits and behavior, not detailed stats.")
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

    func healthRiskRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.semibold))
                
                Text(detail)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    func suggestionRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green.opacity(0.9))
            
            Text(text)
                .foregroundColor(.white.opacity(0.85))
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }

    func currencyString(_ amount: Double) -> String {
        amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}

#Preview {
    HealthView()
        .environmentObject(ExpenseStore())
}
