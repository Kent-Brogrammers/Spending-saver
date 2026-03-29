//
//  AuthModels.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let full_name: String
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let message: String
    let token: String
    let user_id: Int
}

struct MessageResponse: Codable {
    let message: String
}

struct ErrorResponse: Codable {
    let error: String
}
