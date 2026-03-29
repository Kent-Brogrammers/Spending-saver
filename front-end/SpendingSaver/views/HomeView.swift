//
//  HomeView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Hello \(UserDefaults.standard.string(forKey: "username") ?? "User")")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Recent Activity")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundColor(.white)
                
                activityRow(icon: "bag.fill", title: "Bookstore", amount: "-$45.89")
                activityRow(icon: "leaf.fill", title: "Groceries", amount: "-$102.50")
                activityRow(icon: "cup.and.saucer.fill", title: "Coffee", amount: "-$4.75")
                activityRow(icon: "car.fill", title: "Gas Station", amount: "-$53.20")
                activityRow(icon: "dumbbell.fill", title: "Gym Membership", amount: "-$29.99")
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            
            Spacer()
        }
    }
    
    func activityRow(icon: String, title: String, amount: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 32)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(amount)
                .foregroundColor(.green.opacity(0.9))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    HomeView()
}
