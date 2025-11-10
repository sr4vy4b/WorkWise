//
//  WorkWiseApp.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

@main
struct WorkWiseApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var authManager = AuthManager()
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showWelcome = false
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(WorkWiseTheme.primaryGreen)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = UIColor(WorkWiseTheme.primaryGreen)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {

                    ZStack {
                        MainTabView()
                            .environmentObject(dataManager)
                            .environmentObject(authManager)
                        
                        if showWelcome {
                            WelcomeView(showWelcome: $showWelcome)
                                .transition(.opacity)
                                .zIndex(1)
                                .onChange(of: showWelcome) { _, newValue in
                                    if !newValue {
                                        hasSeenWelcome = true
                                    }
                                }
                        }
                    }
                    .onAppear {
                        if !hasSeenWelcome {
                            showWelcome = true
                        }
                    }
                    .transition(.opacity)
                } else {
                    AuthView()
                        .environmentObject(authManager)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            JobsListView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            CompareView()
                .tabItem {
                    Label("Compare", systemImage: "chart.bar.fill")
                }
            
            EducationView()
                .tabItem {
                    Label("Learning", systemImage: "graduationcap.fill")
                }
            
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(WorkWiseTheme.primaryGreen)
    }
}
