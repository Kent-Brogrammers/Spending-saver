//
//  AnalyticsView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Analytics")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Spending")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Text("$732.55")
                        .foregroundColor(.white)
                        .font(.system(size: 34, weight: .bold))
                    
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 48))
                                .foregroundColor(.cyan.opacity(0.8))
                        )
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    transactionRow("Bookstore", "$45.89")
                    transactionRow("Gas Station", "$55.20")
                    transactionRow("Coffee", "$4.75")
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(.bottom, 20)
        }
    }
    
    func transactionRow(_ title: String, _ amount: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(amount)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AnalyticsView()
}
