//
//  HealthView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct HealthView: View {
    @ObservedObject var expenseStore: ExpenseStore
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Health")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                infoCard(
                    title: "Habit Summary",
                    body: "Your recent spending suggests frequent purchases of convenience drinks and fast grab-and-go items."
                )
                
                infoCard(
                    title: "AI Insight",
                    body: "Repeated coffee and sugary drink purchases may point to a daily caffeine and added sugar habit. Over time, this can affect sleep quality, energy crashes, and overall health."
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Potential Health Concerns")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    healthRiskRow(icon: "cup.and.saucer.fill", title: "Sugary Coffee", detail: "May increase daily sugar intake")
                    healthRiskRow(icon: "bolt.fill", title: "High Caffeine", detail: "Can affect sleep and stress levels")
                    healthRiskRow(icon: "fork.knife", title: "Convenience Food", detail: "May mean more sodium and processed foods")
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Better Alternatives")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    suggestionRow("Try making coffee at home 2–3 days a week")
                    suggestionRow("Swap one sugary drink for water or unsweetened tea")
                    suggestionRow("Set a weekly limit for convenience purchases")
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                Spacer(minLength: 120)
            }
            .padding(.bottom, 20)
        }
    }
    
    func infoCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(body)
                .foregroundColor(.white.opacity(0.82))
                .font(.subheadline)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    func healthRiskRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.semibold))
                
                Text(detail)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    func suggestionRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green.opacity(0.9))
            
            Text(text)
                .foregroundColor(.white.opacity(0.85))
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HealthView(expenseStore: ExpenseStore())
}
