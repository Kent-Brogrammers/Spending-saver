//
//  ExpenseStore.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct ExpenseItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let category: String
}

class ExpenseStore: ObservableObject {
    @Published var expenses: [ExpenseItem] = [
        ExpenseItem(name: "Bookstore", amount: 45.89, category: "Shopping"),
        ExpenseItem(name: "Groceries", amount: 102.50, category: "Groceries"),
        ExpenseItem(name: "Coffee", amount: 4.75, category: "Coffee")
    ]
    
    func addExpense(name: String, amount: Double, category: String) {
        let newExpense = ExpenseItem(name: name, amount: amount, category: category)
        expenses.insert(newExpense, at: 0)
    }
}
