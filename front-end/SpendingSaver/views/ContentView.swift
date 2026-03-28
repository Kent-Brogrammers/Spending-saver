//
//  ContentView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.18, blue: 0.22),
                    Color(red: 0.33, green: 0.36, blue: 0.40),
                    Color(red: 0.80, green: 0.78, blue: 0.74)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                heroCard
                inputCard
                Spacer()
            }
            .padding(20)
        }
    }
}

extension ContentView {
    var heroCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Receipt →")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Text("Future Impact")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("See how your spending adds up over time.")
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    var inputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Items")
                .font(.headline)
                .foregroundColor(.white)

            Text("This is where your inputs will go.")
                .foregroundColor(.white.opacity(0.85))

            Button(action: {}) {
                Text("Analyze")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

#Preview {
    ContentView()
}
