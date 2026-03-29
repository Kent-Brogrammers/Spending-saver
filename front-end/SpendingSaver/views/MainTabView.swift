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
    @State private var showMenuOverlay = false
    @State private var selectedMenuPage: MenuPage? = nil
    @StateObject private var expenseStore = ExpenseStore()
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                Spacer()
               
                Group {
                    if let selectedMenuPage {
                        switch selectedMenuPage {
                        case .history:
                            HistoryView(expenseStore: expenseStore)
                        case .health:
                            HealthView(expenseStore: expenseStore)
                        case .preferences:
                            PreferencesView()
                        case .trends:
                            TrendsView(expenseStore: expenseStore)
                        case .settings:
                            SettingsView()
                        }
                    } else {
                        switch selectedTab {
                        case .home:
                            DashboardView(expenseStore: expenseStore)
                        case .menuPlaceholder:
                            DashboardView(expenseStore: expenseStore)
                        case .add:
                            AddExpenseView(expenseStore: expenseStore, selectedTab: $selectedTab)
                        case .analytics:
                            AnalyticsView(expenseStore: expenseStore)
                        case .profile:
                            ProfileView(isLoggedIn: $isLoggedIn)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                bottomNavBar
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            .zIndex(0)
            .task {
                await expenseStore.loadExpenses()
            }
            
            if showMenuOverlay {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showMenuOverlay = false
                        }
                    }
                    .zIndex(1)

                    menuOverlay
                        .zIndex(2)
                        .transition(.move(edge: .leading))
        }
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
    
    var menuButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showMenuOverlay.toggle()
            }
        } label: {
            Image(systemName: "list.bullet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(showMenuOverlay ? Color.cyan : Color.white.opacity(0.75))
                .frame(width: 44, height: 44)
        }
    }
    
    var bottomNavBar: some View {
        HStack(spacing: 18) {
            menuButton
            navButton(.home, systemImage: "house.fill")
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
            selectedMenuPage = nil
            showMenuOverlay = false
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
            selectedMenuPage = nil
            showMenuOverlay = false
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
    
    func menuRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            withAnimation(.easeInOut(duration: 0.2)) {
                showMenuOverlay = false
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.cyan)
                    .frame(width: 24)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.45))
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
    
    var menuOverlay: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Menu")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMenuOverlay = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Circle())
                }
            }
            
            VStack(spacing: 14) {
                menuRow(title: "History", systemImage: "clock.arrow.circlepath") {
                    selectedMenuPage = .history
                }

                menuRow(title: "Health", systemImage: "heart.text.square") {
                    selectedMenuPage = .health
                }

                menuRow(title: "Preferences", systemImage: "slider.horizontal.3") {
                    selectedMenuPage = .preferences
                }

                menuRow(title: "Trends", systemImage: "sparkles") {
                    selectedMenuPage = .trends
                }

                menuRow(title: "Settings", systemImage: "gearshape") {
                    selectedMenuPage = .settings
                }
            }
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.68)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.leading, 10)
        .padding(.vertical, 20)
    }
    
}

enum AppTab {
    case menuPlaceholder
    case home
    case add
    case analytics
    case profile
}

enum MenuPage {
    case history
    case health
    case preferences
    case trends
    case settings
}

#Preview {
    MainTabView(isLoggedIn: .constant(true))
}
