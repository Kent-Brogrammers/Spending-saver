//
//  AuthService.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    let baseURL = "http://10.14.98.21:5000"

    func login(username: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login/login") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(LoginRequest(username: username, password: password))

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if (200...299).contains(httpResponse.statusCode) {
            let result = try JSONDecoder().decode(LoginResponse.self, from: data)
            return result
        } else {
            let apiError = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: apiError?.error ?? "Login failed"]
            )
        }
    }

    func createAccount(fullName: String, username: String, password: String) async throws -> MessageResponse {
        guard let url = URL(string: "\(baseURL)/login/create_account") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            RegisterRequest(full_name: fullName, username: username, password: password)
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(MessageResponse.self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: apiError?.error ?? "Account creation failed"]
            )
        }
    }

    func fetchItems(token: String) async throws -> [ExpenseDTO] {
        guard let url = URL(string: "\(baseURL)/defaults/listItems") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if (200...299).contains(httpResponse.statusCode) {
            return try decodeExpenseList(from: data)
        } else {
            throw apiError(from: data, statusCode: httpResponse.statusCode, fallback: "Failed to fetch items")
        }
    }

    func insertFood(token: String, requestBody: InsertFoodRequest) async throws {
        guard let url = URL(string: "\(baseURL)/inputs/insertFood") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw apiError(from: data, statusCode: httpResponse.statusCode, fallback: "Failed to save expense")
        }
    }

    func updatePreference(token: String, preference: String) async throws -> MessageResponse {
        guard let url = URL(string: "\(baseURL)/inputs/changePref") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(PreferenceRequest(preference: preference))

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if (200...299).contains(httpResponse.statusCode) {
            return (try? JSONDecoder().decode(MessageResponse.self, from: data)) ?? MessageResponse(message: "Preference saved")
        } else {
            throw apiError(from: data, statusCode: httpResponse.statusCode, fallback: "Failed to save preference")
        }
    }

    private func decodeExpenseList(from data: Data) throws -> [ExpenseDTO] {
        let decoder = JSONDecoder()

        if let items = try? decoder.decode([ExpenseDTO].self, from: data) {
            return items
        }

        struct WrappedItems: Codable {
            let items: [ExpenseDTO]
        }

        if let wrapped = try? decoder.decode(WrappedItems.self, from: data) {
            return wrapped.items
        }

        throw NSError(
            domain: "",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unexpected listItems response format"]
        )
    }

    private func apiError(from data: Data, statusCode: Int, fallback: String) -> NSError {
        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
        let messageResponse = try? JSONDecoder().decode(MessageResponse.self, from: data)

        return NSError(
            domain: "",
            code: statusCode,
            userInfo: [
                NSLocalizedDescriptionKey: errorResponse?.error ?? messageResponse?.message ?? fallback
            ]
        )
    }
    
    func analyzeSpending(token: String, data: [String: Any]) async throws -> AnalysisResponse {
        guard let url = URL(string: "\(baseURL)/inputs/analyze") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        request.httpBody = try JSONSerialization.data(withJSONObject: data)

        let (responseData, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(AnalysisResponse.self, from: responseData)
        } else {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Analyze request failed"
            ])
        }
    }
    
    func deleteFood(token: String, orderID: Int) async throws {
        guard let url = URL(string: "\(baseURL)/inputs/deleteFood") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = DeleteFoodRequest(orderID: orderID)
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
