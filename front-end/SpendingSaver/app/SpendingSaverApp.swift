//
//  SpendingSaverApp.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

@main
struct SpendingSaverApp: App {
    @StateObject var expenseStore = ExpenseStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(expenseStore)
        }
    }
}
