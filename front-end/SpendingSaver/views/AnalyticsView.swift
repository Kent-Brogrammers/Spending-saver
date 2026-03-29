//
//  AnalyticsView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var expenseStore: ExpenseStore

    var totalSpent: Double {
        expenseStore.expenses.reduce(0) { $0 + $1.amount }
    }

    var allTransactions: [ExpenseItem] {
        expenseStore.expenses
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Analytics")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Spending")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Text(totalSpent, format: .currency(code: "USD"))
                        .foregroundColor(.white)
                        .font(.system(size: 34, weight: .bold))
                    
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 48))
                                .foregroundColor(.cyan.opacity(0.8))
                        )
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Transactions")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if allTransactions.isEmpty {
                        Text("No expenses yet")
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        ForEach(allTransactions) { expense in
                            transactionRow(expense.name, expense.amount.formatted(.currency(code: "USD")))
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
    
    func transactionRow(_ title: String, _ amount: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(amount)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(ExpenseStore())
}
