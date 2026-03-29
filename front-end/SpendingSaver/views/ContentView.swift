//
//  ContentView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI


struct ContentView: View {
    @State private var isLoggedIn = {
        let remember = UserDefaults.standard.bool(forKey: "rememberMe")
        let token = UserDefaults.standard.string(forKey: "authToken")
        return remember && token != nil
    }()
    
    @StateObject var expenseStore = ExpenseStore()
    
    var body: some View {
        if isLoggedIn {
            MainTabView(isLoggedIn: $isLoggedIn)
                .environmentObject(expenseStore)
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
                .environmentObject(expenseStore)
        }
    }
}

#Preview {
    ContentView()
}
