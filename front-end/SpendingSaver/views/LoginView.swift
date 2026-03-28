//
//  LoginView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//


import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showCreateAccount = false
    
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
                    Color(red: 0.10, green: 0.11, blue: 0.16),
                    Color(red: 0.20, green: 0.24, blue: 0.32)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("SpendingSaver")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Track your spending and stay in control")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.7)))
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
                    
                    Button(action: {
                        isLoggedIn = true
                    }) {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
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
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
