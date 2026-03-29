//
//  HistoryView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

private enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case essential = "Essential"
    case nonEssential = "Non-essential"
}

struct HistoryView: View {
    @EnvironmentObject var expenseStore: ExpenseStore
    @State private var selectedFilter: HistoryFilter = .all
    @State private var itemToDelete: ExpenseItem?
    @State private var showDeleteAlert = false

    var filteredExpenses: [ExpenseItem] {
        switch selectedFilter {
        case .all:
            return expenseStore.expenses
        case .essential:
            return expenseStore.expenses.filter(\.isEssential)
        case .nonEssential:
            return expenseStore.expenses.filter { !$0.isEssential }
        }
    }

    var groupedHistory: [(date: String, items: [ExpenseItem])] {
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
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

                filterBar
                
                if groupedHistory.isEmpty {
                    Text(emptyStateText)
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
            .alert("Delete Expense?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteSelectedItem()
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(deleteMessage)
            }
            .padding(.bottom, 20)
        }
    }

    var filterBar: some View {
        HStack(spacing: 10) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(selectedFilter == filter ? Color.black.opacity(0.85) : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            selectedFilter == filter
                            ? Color.white.opacity(0.95)
                            : Color.white.opacity(0.10)
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .padding(6)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
    
    func historyRow(_ item: ExpenseItem) -> some View {
        HStack {
            Image(systemName: iconForCategory(item.category))
                .foregroundColor(.cyan)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.65))
                    
                    Text(item.isEssential ? "Essential" : "Non-essential")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.isEssential ? Color.green.opacity(0.28) : Color.yellow.opacity(0.28))
                        .foregroundColor(item.isEssential ? Color.green.opacity(0.95) : Color.yellow.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            Spacer()
            
            Text(String(format: "-$%.2f", item.amount))
                .foregroundColor(.green.opacity(0.9))
            
            Button {
                itemToDelete = item
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
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

    var emptyStateText: String {
        switch selectedFilter {
        case .all:
            return "No expenses yet"
        case .essential:
            return "No essential expenses yet"
        case .nonEssential:
            return "No non-essential expenses yet"
        }
    }

    var deleteMessage: String {
        guard let itemToDelete else {
            return "This action cannot be undone."
        }

        return "Delete \(itemToDelete.name)? This action cannot be undone."
    }
    
    func deleteSelectedItem() async {
        guard let item = itemToDelete else { return }

        do {
            try await expenseStore.deleteExpense(item)
        } catch {
            print("Delete failed:", error)
        }

        itemToDelete = nil
    }
}

#Preview {
    HistoryView()
        .environmentObject(ExpenseStore())
}
