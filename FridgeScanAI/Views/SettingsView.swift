//
//  SettingsView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showFavorites = false

    var body: some View {
        NavigationStack {
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

                Form {
                    Section {
                        Button("Past Scans") {
                            showAlertWith(message: "To be Implemented")
                        }

                        Button("My Favorite Ingredients") {
                            showFavorites = true
                        }

                        Button("App Info") {
                            showAlertWith(message: "To be Implemented")
                        }

                        Button("Help & Support") {
                            showAlertWith(message: "To be Implemented")
                        }

                        Button("Log Out") {
                            showAlertWith(message: "To be Implemented")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
            .navigationDestination(isPresented: $showFavorites) {
                FavoriteIngredientsView()
            }
        }
    }

    private func showAlertWith(message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    SettingsView()
}
