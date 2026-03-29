import SwiftUI

struct DashboardView: View {
    @AppStorage("displayName") private var displayName = ""
    @EnvironmentObject var expenseStore: ExpenseStore

    private var recentExpenses: [ExpenseItem] {
        Array(expenseStore.expenses.prefix(5))
    }

    private var currentDisplayName: String {
        if !displayName.isEmpty {
            return displayName
        }

        return UserDefaults.standard.string(forKey: "username") ?? "User"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                summaryCard

                VStack(alignment: .leading, spacing: 14) {
                    Text("Recent Expenses")
                        .font(.headline)
                        .foregroundColor(.white)

                    if expenseStore.isLoading && expenseStore.expenses.isEmpty {
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.white)

                            Text("Loading your latest expenses...")
                                .foregroundColor(.white.opacity(0.72))
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                    } else if !expenseStore.errorMessage.isEmpty && expenseStore.expenses.isEmpty {
                        VStack(spacing: 12) {
                            Text(expenseStore.errorMessage)
                                .foregroundColor(.red.opacity(0.85))
                                .font(.subheadline)
                                .multilineTextAlignment(.center)

                            Button("Try Again") {
                                Task {
                                    await expenseStore.loadExpenses()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.10))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    } else if recentExpenses.isEmpty {
                        Text("No expenses yet")
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    } else {
                        ForEach(recentExpenses) { expense in
                            expenseRow(expense)
                        }
                    }

                    if !expenseStore.errorMessage.isEmpty && !expenseStore.expenses.isEmpty {
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
        .refreshable {
            await expenseStore.loadExpenses()
        }
    }

    var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome back")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text(summarySubtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.82))
            }

            Text("Use Trends for patterns over time and Analytics for the full breakdown.")
                .font(.footnote)
                .foregroundColor(.cyan.opacity(0.9))
        }
        .padding(22)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.top, 20)
    }

    func expenseRow(_ expense: ExpenseItem) -> some View {
        HStack {
            Image(systemName: iconForCategory(expense.category))
                .foregroundColor(.cyan)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.name)
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Text(expense.category)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.65))

                    Text(expense.isEssential ? "Essential" : "Non-essential")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(expense.isEssential ? Color.green.opacity(0.28) : Color.yellow.opacity(0.28))
                        .foregroundColor(expense.isEssential ? Color.green.opacity(0.95) : Color.yellow.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }

            Spacer()

            Text(String(format: "-$%.2f", expense.amount))
                .foregroundColor(.green.opacity(0.9))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    var summarySubtitle: String {
        if expenseStore.isLoading && expenseStore.expenses.isEmpty {
            return "Pulling in your latest spending activity, \(currentDisplayName)."
        }

        if recentExpenses.isEmpty {
            return "No purchases tracked yet. Add one to start your trendline."
        }

        return "\(currentDisplayName), here are your most recent expenses and the choices that are shaping your spending."
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
        case "Fast Food":
            return "fork.knife"
        case "Health":
            return "heart.fill"
        case "Subscription":
            return "tv.fill"
        default:
            return "dollarsign.circle.fill"
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(ExpenseStore())
}
