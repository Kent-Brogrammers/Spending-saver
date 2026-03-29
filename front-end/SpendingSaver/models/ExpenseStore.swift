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
    }

    private static func mapExpense(_ dto: ExpenseDTO) -> ExpenseItem {
        ExpenseItem(
            name: dto.food_name ?? dto.name ?? "Unknown Item",
            amount: dto.cost ?? dto.amount ?? 0,
            category: dto.category ?? "Other",
            frequency: "One Time",
            isEssential: isEssentialCategory(dto.category),
            createdAt: parseDate(dto.order_datetime ?? dto.timestamp_column ?? dto.timestamp ?? dto.created_at)
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
    
    func fetchAnalysis() async {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "\(authService.baseURL)/inputs/analyze") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            print("RAW ANALYZE RESPONSE:", String(data: data, encoding: .utf8) ?? "")

            let decoded = try JSONDecoder().decode(AnalysisResponse.self, from: data)

            print("DECODED PROJECTIONS:", decoded.projections)

            self.projections = decoded.projections

        } catch {
            print("Analyze failed:", error)
        }
    }
}


