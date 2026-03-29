//
//  PreferencesView.swift
//  SpendingSaver
//
//  Created by OpenAI on 8/15/25.
//

import SwiftUI

struct PreferencesView: View {
    @AppStorage("savedPreferenceText") private var savedPreferenceText = ""
    @State private var draftPreference = ""
    @State private var isSaving = false
    @State private var statusMessage = ""
    @State private var errorMessage = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Preferences")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Spending Priorities")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Describe what matters most to you so the app can frame insights around your goals.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))

                    TextEditor(text: $draftPreference)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 180)
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Button {
                        Task {
                            await savePreference()
                        }
                    } label: {
                        Group {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Save Preference")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.green.opacity(0.95), Color.cyan.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(isSaving)

                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundColor(.green.opacity(0.9))
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Focus")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(savedPreferenceText.isEmpty ? "No preference saved yet." : savedPreferenceText)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

                Spacer(minLength: 170)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            draftPreference = savedPreferenceText
        }
    }

    private func savePreference() async {
        let trimmed = draftPreference.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter a preference before saving."
            return
        }

        savedPreferenceText = trimmed
        statusMessage = "Saved locally."
        errorMessage = ""
        isSaving = true
        defer { isSaving = false }

        guard let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty else {
            errorMessage = "Saved locally. Sign in again to sync with the backend."
            return
        }

        do {
            let result = try await AuthService.shared.updatePreference(token: token, preference: trimmed)
            statusMessage = result.message
        } catch {
            errorMessage = "Saved locally, but backend sync failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    PreferencesView()
}
