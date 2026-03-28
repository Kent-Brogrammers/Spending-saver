//
//  ContentView.swift
//  SpendingSaver
//
//  Created by Chris Vuletich on 3/28/26.
//

import SwiftUI

struct ContentView: View {
    @State private var itemName = ""
    @State private var itemPrice = ""
    @State private var items: [Item] = []
    
    struct Item: Identifiable {
        let id = UUID()
        let name: String
        let price: String
    }
    
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
                itemsCard
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(20)
        }
    }
}

extension ContentView {
    var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Receipt →")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.82))
            
            Text("Future Impact")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("See how your spending adds up over time.")
                .foregroundColor(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(.white.opacity(0.10))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous)
            .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
    
    var inputCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Items")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                TextField("Item name", text: $itemName)
                    .textFieldStyle(.plain)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.white)
                    .padding()
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                TextField("Price", text: $itemPrice)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .padding()
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            
            Button(action: {
                if !itemName.isEmpty && !itemPrice.isEmpty {
                    items.append(Item(name: itemName, price: itemPrice))
                    itemName = ""
                    itemPrice = ""
                }
            }) {
                Text("Add Item")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.green.opacity(0.95), Color.mint.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(.white.opacity(0.10))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
    
    var itemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Items")
                        .font(.headline)
                        .foregroundColor(.white)

                    if items.isEmpty {
                        Text("No items yet")
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        ForEach(items) { item in
                            HStack {
                                Text(item.name)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("$\(item.price)")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.vertical, 4)
                        }                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(.white.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }

#Preview {
    ContentView()
}
