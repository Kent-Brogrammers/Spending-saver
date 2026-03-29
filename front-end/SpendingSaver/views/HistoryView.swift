//
//  HistoryView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var expenseStore: ExpenseStore
    @State private var selectedDateLabel = "All Dates"

    var groupedHistory: [(date: String, items: [ExpenseItem])] {
        let grouped = Dictionary(grouping: expenseStore.expenses) { expense in
            historyDateLabel(for: expense.createdAt)
        }

        return grouped
            .map { (date: $0.key, items: $0.value) }
            .sorted { lhs, rhs in
                let lhsDate = lhs.items.first?.createdAt ?? .distantPast
                let rhsDate = rhs.items.first?.createdAt ?? .distantPast
                return lhsDate > rhsDate
            }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("History")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                Button {
                    // later: show date picker
                } label: {
                    HStack {
                        Text(selectedDateLabel)
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                }
                
                if groupedHistory.isEmpty {
                    Text("No expenses yet")
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(groupedHistory, id: \.date) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.date)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(group.items) { item in
                                historyRow(item)
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
                }
                
                Spacer(minLength: 120)
            }
            .padding(.bottom, 20)
        }
    }
    
    func historyRow(_ item: ExpenseItem) -> some View {
        HStack {
            Image(systemName: iconForCategory(item.category))
                .foregroundColor(.cyan)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .foregroundColor(.white)
                
                Text(item.category)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }
            
            Spacer()
            
            Text(String(format: "-$%.2f", item.amount))
                .foregroundColor(.green.opacity(0.9))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    func historyDateLabel(for date: Date?) -> String {
        guard let date else {
            return "Recent"
        }

        return date.formatted(date: .long, time: .omitted)
    }
    
    func iconForCategory(_ category: String) -> String {
        switch category {
        case "Groceries":
            return "cart.fill"
        case "Gas":
            return "car.fill"
        case "Coffee":
            return "cup.and.saucer.fill"
        case "Shopping":
            return "bag.fill"
        default:
            return "dollarsign.circle.fill"
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(ExpenseStore())
}
