//
//  CreateAccountView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//


import SwiftUI

struct CreateAccountView: View {
    @Binding var showCreateAccount: Bool
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
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
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Start tracking your spending")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack(spacing: 16) {
                    TextField("", text: $fullName, prompt: Text("Full Name").foregroundColor(.white.opacity(0.7)))
                        .padding()
                        .background(Color.white.opacity(0.18))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .tint(.white)
                    
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
                    
                    SecureField("", text: $confirmPassword, prompt: Text("Confirm Password").foregroundColor(.white.opacity(0.7)))
                        .padding()
                        .background(Color.white.opacity(0.18))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .tint(.white)
                    
                    Button(action: {
                        print("Create account tapped")
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    
                    Button(action: {
                        showCreateAccount = false
                    }) {
                        Text("Back to Login")
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
    CreateAccountView(showCreateAccount: .constant(true))
}
