//
//  HistoryView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var expenseStore: ExpenseStore
    @State private var selectedDateLabel = "March 28, 2026"
    
    let groupedHistory: [(date: String, items: [HistoryItem])] = [
        (
            date: "March 28, 2026",
            items: [
                HistoryItem(name: "Starbucks", category: "Coffee", amount: 7.45),
                HistoryItem(name: "Target", category: "Shopping", amount: 42.19),
                HistoryItem(name: "Sheetz", category: "Gas", amount: 28.00)
            ]
        ),
        (
            date: "March 27, 2026",
            items: [
                HistoryItem(name: "Walmart", category: "Groceries", amount: 63.84),
                HistoryItem(name: "Dunkin", category: "Coffee", amount: 5.75)
            ]
        )
    ]
    
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
                
                Spacer(minLength: 120)
            }
            .padding(.bottom, 20)
        }
    }
    
    func historyRow(_ item: HistoryItem) -> some View {
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

struct HistoryItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let amount: Double
}

#Preview {
    HistoryView(expenseStore: ExpenseStore())
}
