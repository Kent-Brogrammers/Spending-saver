//
//  MainTabView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                Spacer()
                
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .activity:
                        HomeView() // temp until ActivityView exists
                    case .add:
                        AddExpenseView()
                    case .analytics:
                        AnalyticsView()
                    case .profile:
                        ProfileView(isLoggedIn: $isLoggedIn)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                bottomNavBar
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
        }
    }
}

extension MainTabView {
    var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.07, blue: 0.15),  // deep navy
                Color(red: 0.10, green: 0.18, blue: 0.35),  // blue
                Color(red: 0.12, green: 0.35, blue: 0.40)   // teal hint
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var bottomNavBar: some View {
        HStack(spacing: 18) {
            navButton(.home, systemImage: "house.fill")
            navButton(.activity, systemImage: "list.bullet")
            addButton
            navButton(.analytics, systemImage: "chart.line.uptrend.xyaxis")
            navButton(.profile, systemImage: "person.crop.circle")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    func navButton(_ tab: AppTab, systemImage: String) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(selectedTab == tab ? Color.cyan : Color.white.opacity(0.75))
                .frame(width: 44, height: 44)
        }
    }
    
    var addButton: some View {
        Button(action: {
            selectedTab = .add
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        colors: [Color.green.opacity(0.95), Color.cyan.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color.green.opacity(0.35), radius: 12, x: 0, y: 6)
        }
        .offset(y: -8)
    }
}

enum AppTab {
    case home
    case activity
    case add
    case analytics
    case profile
}

#Preview {
    MainTabView(isLoggedIn: .constant(true))
}
