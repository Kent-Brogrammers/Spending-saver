//
//  LoginView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//


import SwiftUI

struct LoginView: View {
    @State private var rememberMe = false
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var expenseStore: ExpenseStore
    @State private var username = ""
    @State private var password = ""
    @State private var showCreateAccount = false
    @State private var errorMessage = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        if showCreateAccount {
            CreateAccountView(showCreateAccount: $showCreateAccount)
        } else {
            loginContent
        }
    }
}

extension LoginView {
    var loginContent: some View {
        ZStack {
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
            
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Spending Saver")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Track your spending and stay in control")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    TextField("", text: $username, prompt: Text("Email").foregroundColor(.white.opacity(0.7)))
                        .padding()
                        .background(Color.white.opacity(0.18))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .tint(.white)

                    SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.7)))
                        .padding()
                        .background(Color.white.opacity(0.18))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .tint(.white)
                    
                    Toggle("Remember Me", isOn: $rememberMe)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        Task {
                            await login()
                        }
                    }) {
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Log In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .disabled(isLoading)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                                        }
                    
                    Button(action: {
                        showCreateAccount = true
                    }) {
                        Text("Create Account")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 4)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func login() async {
        errorMessage = ""

        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            errorMessage = "Enter username and password."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await AuthService.shared.login(username: username, password: password)

            if rememberMe {
                UserDefaults.standard.set(result.token, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
            UserDefaults.standard.set(rememberMe, forKey: "rememberMe")
            UserDefaults.standard.set(result.user_id, forKey: "userID")
            UserDefaults.standard.set(username, forKey: "username")

            
            await expenseStore.loadExpenses()

            isLoggedIn = true

        } catch {
            errorMessage = error.localizedDescription
        }    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
        .environmentObject(ExpenseStore())
}
