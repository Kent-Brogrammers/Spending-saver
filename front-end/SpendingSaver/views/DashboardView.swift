import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var expenseStore: ExpenseStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hello")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    Text("Recent Activity")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Recent Expenses")
                        .font(.headline)
                        .foregroundColor(.white)

                    if expenseStore.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding()
                    } else if expenseStore.expenses.isEmpty {
                        Text("No expenses yet")
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    } else {
                        ForEach(expenseStore.expenses) { expense in
                            expenseRow(expense)
                        }
                    }

                    if !expenseStore.errorMessage.isEmpty {
                        Text(expenseStore.errorMessage)
                            .foregroundColor(.red.opacity(0.8))
                            .font(.caption)
                            .padding(.top, 4)
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

                Spacer()
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            Task {
                await expenseStore.loadExpenses()
            }
        }
    }

    func expenseRow(_ expense: ExpenseItem) -> some View {
        HStack {
            Image(systemName: iconForCategory(expense.category))
                .foregroundColor(.cyan)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.name)
                    .foregroundColor(.white)

                Text(expense.category)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }

            Spacer()

            Text(String(format: "-$%.2f", expense.amount))
                .foregroundColor(.green.opacity(0.9))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    func iconForCategory(_ category: String) -> String {
        switch category {
        case "Groceries": return "cart.fill"
        case "Gas": return "car.fill"
        case "Coffee": return "cup.and.saucer.fill"
        case "Shopping": return "bag.fill"
        case "Fast Food": return "fork.knife"
        case "Health": return "heart.fill"
        case "Subscription": return "tv.fill"
        default: return "dollarsign.circle.fill"
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(ExpenseStore())
}