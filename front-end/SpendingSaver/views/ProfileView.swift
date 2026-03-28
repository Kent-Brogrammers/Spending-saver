//
//  ProfileView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Profile")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            HStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 54))
                    .foregroundColor(.white.opacity(0.9))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chris Vuletich")
                        .foregroundColor(.white)
                        .font(.title3.bold())
                    
                    Text("chris@example.com")
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            
            profileRow("View Account", "person")
            profileRow("Notifications", "bell")
            profileRow("Export Data", "paperplane")
            profileRow("About", "info.circle")
            
            Button(action: {
                isLoggedIn = false
            }) {
                Text("Log Out")
                    .foregroundColor(.red.opacity(0.9))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            
            Spacer()
        }
    }
    
    func profileRow(_ title: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.85))
                .frame(width: 28)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}
