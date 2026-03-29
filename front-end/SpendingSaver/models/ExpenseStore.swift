//
//  ExpenseStore.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI
import Combine

struct ExpenseItem: Identifiable {
    let id: Int
    let name: String
    let amount: Double
    let category: String
    let frequency: String
    let isEssential: Bool
    let createdAt: Date?
}

struct Projections: Codable {
    let daily: Double
    let weekly: Double
    let monthly: Double
    let yearly: Double

    init(daily: Double = 0, weekly: Double = 0, monthly: Double = 0, yearly: Double = 0) {
        self.daily = daily
        self.weekly = weekly
        self.monthly = monthly
        self.yearly = yearly
    }
}

@MainActor
class ExpenseStore: ObservableObject {
    @Published var expenses: [ExpenseItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var projections = Projections()

    private let authService = AuthService.shared
    private var essentialOverrides: [Int: Bool]

    init() {
        essentialOverrides = [:]
        essentialOverrides = loadEssentialOverrides()
    }

    func loadExpenses() async {
        guard let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty else {
            errorMessage = "Missing auth token."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let items = try await authService.fetchItems(token: token)
            expenses = items.map(mapExpense).sorted { lhs, rhs in
                (lhs.createdAt ?? .distantPast) > (rhs.createdAt ?? .distantPast)
            }
            await fetchAnalysis()

            errorMessage = ""

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addExpense(name: String, amount: Double, category: String, frequency: String, isEssential: Bool) async throws {
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
        applyEssentialOverride(
            name: name,
            amount: amount,
            category: category,
            isEssential: isEssential
        )
    }

    func deleteExpense(_ item: ExpenseItem) async throws {
        guard let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty else {
            throw NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing auth token."]
            )
        }

        try await authService.deleteFood(token: token, orderID: item.id)
        removeEssentialOverride(for: item.id)
        expenses.removeAll { $0.id == item.id }
        await fetchAnalysis()
    }

    private func mapExpense(_ dto: ExpenseDTO) -> ExpenseItem {
        let orderID = dto.order_id ?? 0

        return ExpenseItem(
            id: orderID,
            name: dto.food_name ?? dto.name ?? "Unknown Item",
            amount: dto.cost ?? dto.amount ?? 0,
            category: dto.category ?? "Other",
            frequency: "one-time",
            isEssential: dto.is_essential ?? dto.essential ?? essentialOverrides[orderID] ?? Self.isEssentialCategory(dto.category),
            createdAt: Self.parseDate(dto.order_datetime ?? dto.timestamp_column ?? dto.timestamp ?? dto.created_at)
        )
    }

    private static func isEssentialCategory(_ category: String?) -> Bool {
        switch category {
        case "Groceries", "Gas":
            return true
        default:
            return false
        }
    }

    private static func parseDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else {
            return nil
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
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
        if let date = formatter.date(from: value) {
            return date
        }

        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: value) {
            return date
        }

        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: value)
    }
    
    func fetchAnalysis() async {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "\(authService.baseURL)/inputs/analyze") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            print("RAW ANALYZE RESPONSE:", String(data: data, encoding: .utf8) ?? "")

            let decoded = try JSONDecoder().decode(AnalysisResponse.self, from: data)

            print("DECODED PROJECTIONS:", decoded.projections)

            self.projections = decoded.projections

        } catch {
            print("Analyze failed:", error)
        }
    }

    private func applyEssentialOverride(name: String, amount: Double, category: String, isEssential: Bool) {
        guard let matchIndex = expenses.firstIndex(where: { expense in
            expense.name.caseInsensitiveCompare(name) == .orderedSame &&
            expense.category == category &&
            abs(expense.amount - amount) < 0.001
        }) else {
            return
        }

        let matchedExpense = expenses[matchIndex]
        essentialOverrides[matchedExpense.id] = isEssential
        saveEssentialOverrides()

        expenses[matchIndex] = ExpenseItem(
            id: matchedExpense.id,
            name: matchedExpense.name,
            amount: matchedExpense.amount,
            category: matchedExpense.category,
            frequency: matchedExpense.frequency,
            isEssential: isEssential,
            createdAt: matchedExpense.createdAt
        )
    }

    private func removeEssentialOverride(for orderID: Int) {
        essentialOverrides.removeValue(forKey: orderID)
        saveEssentialOverrides()
    }

    private func loadEssentialOverrides() -> [Int: Bool] {
        guard let data = UserDefaults.standard.data(forKey: essentialOverridesKey),
              let decoded = try? JSONDecoder().decode([Int: Bool].self, from: data) else {
            return [:]
        }

        return decoded
    }

    private func saveEssentialOverrides() {
        guard let data = try? JSONEncoder().encode(essentialOverrides) else {
            return
        }

        UserDefaults.standard.set(data, forKey: essentialOverridesKey)
    }

    private var essentialOverridesKey: String {
        let userID = UserDefaults.standard.integer(forKey: "userID")
        return "essentialOverrides_\(userID)"
    }
}
