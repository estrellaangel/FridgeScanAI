//
//  ContentView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/7/25.
//

import SwiftUI
import FirebaseAuth

enum Tab {
    case fridge, recipes, scan, cart, settings
}

struct HomeView: View {
    @State private var selectedTab: Tab = .fridge
    @State private var isRecording = false
    @State private var videoURL: URL? = nil
    @State private var didFinishRecording = false
    
    //USER = ANONYMOUS
    @State private var userID: String = Auth.auth().currentUser?.uid ?? "anonymous"
    
    //MOST UP TO DATE SCAN
    @EnvironmentObject var scanSession: ScanSessionViewModel
    
    //SABRINA ADDED FOR SHOPPING LIST UPDATE AFTER SCAN
    @EnvironmentObject var favoriteVM: FavoriteIngredientsViewModel
    @EnvironmentObject var shoppingListVM: ShoppingListViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            CurrentFridgeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("", systemImage: "refrigerator")
                }
                .tag(Tab.fridge)

            RecipesView()
                .tabItem {
                    Label("", systemImage: "fork.knife.circle")
                }
                .tag(Tab.recipes)

            ScanViewWrapper(
                isRecording: $isRecording,
                videoURL: $videoURL,
                didFinishRecording: $didFinishRecording,
                userID: $userID,
                selectedTab: $selectedTab
            )
                .tabItem {
                    Label("", systemImage: "camera")
                }
                .tag(Tab.scan)

            ShoppingListView()
                .tabItem {
                    Label("", systemImage: "pencil.and.list.clipboard")
                }
                .tag(Tab.cart)

            SettingsView()
                .tabItem {
                    Label("", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .onAppear {
            //SABRINA ADDED PARAMETERS FOR SHOPPING LIST FUNCTIONALITY
            scanSession.fetchLatestScan(favoriteVM: favoriteVM, shoppingListVM: shoppingListVM) //get the previous latest scan
            tryToRunModel()
        }
    }
}

