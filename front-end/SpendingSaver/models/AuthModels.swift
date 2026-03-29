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

struct InsertFoodRequest: Codable {
    let name: String
    let cost: Double
    let category: String
    let frequency: String

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case cost = "Cost"
        case category = "Category"
        case frequency = "Frequency"
    }
}

struct DeleteFoodRequest: Codable {
    let orderID: Int

    enum CodingKeys: String, CodingKey {
        case orderID = "ORDER_ID"
    }
}

struct PreferenceRequest: Codable {
    let preference: String
}

struct ExpenseDTO: Codable {
    let order_id: Int?
    let food_name: String?
    let name: String?
    let cost: Double?
    let amount: Double?
    let category: String?
    let order_datetime: String?
    let timestamp_column: String?
    let timestamp: String?
    let created_at: String?
}
