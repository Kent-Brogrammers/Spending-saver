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

    private let baseURL = "http://127.0.0.1:5000"

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
            return try JSONDecoder().decode(LoginResponse.self, from: data)
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
}
