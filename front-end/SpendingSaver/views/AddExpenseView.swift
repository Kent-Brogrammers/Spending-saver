//
//  AddExpenseView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var expenseStore: ExpenseStore
    @Binding var selectedTab: AppTab
    
    @State private var name = ""
    @State private var amount = ""
    @State private var category = "Groceries"
    @State private var isSaving = false
    @State private var errorMessage = ""
    
    let categories = ["Groceries", "Gas", "Coffee", "Shopping", "Other"]
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Add Expense")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                TextField("", text: $name, prompt: Text("E.g. Groceries").foregroundColor(.white.opacity(0.65)))
                    .padding()
                    .background(Color.white.opacity(0.10))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                TextField("", text: $amount, prompt: Text("$0.00").foregroundColor(.white.opacity(0.65)))
                    .padding()
                    .background(Color.white.opacity(0.10))
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color.white.opacity(0.10))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                HStack {
                    Button("Cancel") {
                        name = ""
                        amount = ""
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.10))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    
                    Button("Add Expense") {
                        Task {
                            await addExpense()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.green.opacity(0.95), Color.cyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .disabled(isSaving)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red.opacity(0.9))
                }
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            
            Spacer()
        }
    }
    func addExpense() async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let amountValue = Double(amount) else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await expenseStore.addExpense(name: name, amount: amountValue, category: category)
            errorMessage = ""
            name = ""
            amount = ""
            category = "Groceries"
            selectedTab = .home
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AddExpenseView(expenseStore: ExpenseStore(), selectedTab: .constant(.add))
}
