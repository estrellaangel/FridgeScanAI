//
//  SettingsView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                Text("User Name")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)

            //TODO : Implement functionality in settings buttons
            Form {
                Section {
                    Button("Past Scans") {}
                    Button("Weekly Grocery Items") {}
                    Button("App Info") {}
                    Button("Help & Support") {}
                    Button("Log Out") {}
                        .foregroundColor(.red)
                }
            }
        }
    } 
}

#Preview {
    SettingsView()
}
