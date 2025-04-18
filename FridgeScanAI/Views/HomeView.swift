//
//  ContentView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI
import SwiftData

enum Tab {
    case fridge, recipes, scan, cart, settings
}

struct HomeView: View {
    @State private var selectedTab: Tab = .fridge
    @State private var isRecording = true
    @State private var videoURL: URL? = nil
    

    var body: some View {
        TabView(selection: $selectedTab) {
            CurrentFridgeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Current Fridge", systemImage: "refrigerator")
                }
                .tag(Tab.fridge)

            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife.circle")
                }
                .tag(Tab.recipes)

            ScanViewWrapper(isRecording: $isRecording, videoURL: $videoURL)
                .tabItem {
                    Label("Scan Fridge", systemImage: "camera")
                }
                .tag(Tab.scan)

            ShoppingListView()
                .tabItem {
                    Label("Shopping List", systemImage: "pencil.and.list.clipboard")
                }
                .tag(Tab.cart)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    HomeView()
}
