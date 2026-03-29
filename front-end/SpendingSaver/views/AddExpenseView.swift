//
//  AddExpenseView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var expenseStore: ExpenseStore
    @Binding var selectedTab: AppTab
    
    @State private var name = ""
    @State private var amount = ""
    @State private var category = "Groceries"
    @State private var frequency = "One Time"
    @State private var isEssential = false
    @State private var isSaving = false
    @State private var statusMessage = ""
    @State private var errorMessage = ""
    
    let categories = ["Groceries", "Gas", "Coffee", "Shopping", "Other"]
    let frequencies = ["One Time", "Daily", "Weekly", "Monthly", "Yearly"]
    
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
                    .onChange(of: name) {
                        statusMessage = ""
                    }
                
                TextField("", text: $amount, prompt: Text("$0.00").foregroundColor(.white.opacity(0.65)))
                    .padding()
                    .background(Color.white.opacity(0.10))
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .onChange(of: amount) {
                        statusMessage = ""
                    }
                
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

                Picker("Frequency", selection: $frequency) {
                    ForEach(frequencies, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color.white.opacity(0.10))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Toggle(isOn: $isEssential) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isEssential ? "Essential" : "Non-Essential")
                            .foregroundColor(.white)
                        Text("Mark whether this purchase is a need or a want")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .tint(.cyan)
                .padding()
                .background(Color.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                HStack {
                    Button("Cancel") {
                        name = ""
                        amount = ""
                        errorMessage = ""
                        statusMessage = ""
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

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundColor(.green.opacity(0.9))
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
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = "Enter a name for the expense."
            statusMessage = ""
            return
        }

        guard let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "Enter a valid amount greater than zero."
            statusMessage = ""
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await expenseStore.addExpense(
                name: trimmedName,
                amount: amountValue,
                category: category,
                frequency: frequency,
                isEssential: isEssential
            )
            errorMessage = ""
            statusMessage = "\(trimmedName) was added successfully."
            name = ""
            amount = ""
            category = "Groceries"
            frequency = "One Time"
            isEssential = false
            selectedTab = .home
        } catch {
            statusMessage = ""
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AddExpenseView(selectedTab: .constant(.add))
        .environmentObject(ExpenseStore())
}
