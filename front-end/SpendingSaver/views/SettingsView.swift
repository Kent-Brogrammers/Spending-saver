//
//  SettingsView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("displayName") private var displayName = "Chris"
    @State private var editedName = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("Account")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("", text: Binding(
                        get: { editedName.isEmpty ? displayName : editedName },
                        set: { editedName = $0 }
                    ), prompt: Text("Display Name").foregroundColor(.white.opacity(0.7)))
                    .padding()
                    .background(Color.white.opacity(0.10))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    
                    Button("Save Name") {
                        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            displayName = trimmed
                            UserDefaults.standard.set(trimmed, forKey: "username")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.green.opacity(0.95), Color.cyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("Appearance")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                            .foregroundColor(.white)
                    }
                    .tint(.cyan)
                    
                    HStack {
                        Text("Current Mode")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(isDarkMode ? "Dark" : "Light")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("Preferences")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    settingsRow("Notifications", "bell")
                    settingsRow("Data Export", "square.and.arrow.up")
                    settingsRow("Privacy", "lock.shield")
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
        .onAppear {
            editedName = displayName
        }
    }
    
    func settingsRow(_ title: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 28)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    SettingsView()
}
