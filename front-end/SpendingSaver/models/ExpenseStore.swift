//
//  ExpenseStore.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI
import Combine

struct ExpenseItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let category: String
    let createdAt: Date?
}

@MainActor
class ExpenseStore: ObservableObject {
    @Published var expenses: [ExpenseItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let authService = AuthService.shared

    func loadExpenses() async {
        guard let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty else {
            errorMessage = "Missing auth token."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let items = try await authService.fetchItems(token: token)
            expenses = items.map(Self.mapExpense).sorted { lhs, rhs in
                (lhs.createdAt ?? .distantPast) > (rhs.createdAt ?? .distantPast)
            }
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addExpense(name: String, amount: Double, category: String, frequency: String) async throws {
        guard let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty else {
            throw NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing auth token."]
            )
        }

        let request = InsertFoodRequest(name: name, cost: amount, category: category, frequency: frequency)
        try await authService.insertFood(token: token, requestBody: request)
        await loadExpenses()
    }

    private static func mapExpense(_ dto: ExpenseDTO) -> ExpenseItem {
        ExpenseItem(
            name: dto.food_name ?? dto.name ?? "Unknown Item",
            amount: dto.cost ?? dto.amount ?? 0,
            category: dto.category ?? "Other",
            createdAt: parseDate(dto.order_datetime ?? dto.timestamp_column ?? dto.timestamp ?? dto.created_at)
        )
    }

    private static func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else {
            return nil
        }

        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: value) {
            return date
        }

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: value)
    }
}
