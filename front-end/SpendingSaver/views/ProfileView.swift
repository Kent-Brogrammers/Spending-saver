//
//  ProfileView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @AppStorage("displayName") private var displayName = ""
    @AppStorage("isDarkMode") private var isDarkMode = true
    @EnvironmentObject var expenseStore: ExpenseStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                accountCard
                settingsPreviewCard
                logoutButton
                
                Spacer(minLength: 120)
            }
            .padding(.bottom, 20)
        }
    }

    var accountCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.95), Color.green.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)

                Text(initials)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(currentDisplayName)
                    .foregroundColor(.white)
                    .font(.title3.bold())
                
                Text(UserDefaults.standard.string(forKey: "username") ?? "No username")
                    .foregroundColor(.white.opacity(0.72))

                Text("Hackathon Demo Account")
                    .font(.caption)
                    .foregroundColor(.cyan.opacity(0.9))
            }
            
            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    var settingsPreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Details")
                .font(.headline)
                .foregroundColor(.white)

            profileRow("Theme", isDarkMode ? "Dark Mode" : "Light Mode", "moon.stars.fill")
            profileRow("Display Name", currentDisplayName, "person.text.rectangle")
            profileRow("Status", expenseStore.expenses.isEmpty ? "Getting started" : "Actively tracking", "sparkles")
            profileRow("Where to view stats", "Use Trends and Analytics", "chart.xyaxis.line")
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    var logoutButton: some View {
        Button(action: {
            UserDefaults.standard.removeObject(forKey: "authToken")
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "displayName")
            
            isLoggedIn = false
        }) {
            Text("Log Out")
                .foregroundColor(.red.opacity(0.9))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
    
    func profileRow(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)

                Text(value)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.68))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    var initials: String {
        let parts = currentDisplayName.split(separator: " ")
        if parts.isEmpty {
            return "U"
        }

        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
    }

    var currentDisplayName: String {
        if !displayName.isEmpty {
            return displayName
        }

        return UserDefaults.standard.string(forKey: "username") ?? "User"
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
        .environmentObject(ExpenseStore())
}
