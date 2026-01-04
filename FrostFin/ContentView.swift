//
//  ContentView.swift
//  FrostFin
//
//  Created by Simon Bakhanets on 04.01.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    
    var body: some View {
        if hasCompletedOnboarding {
            mainTabView
        } else {
            OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .accentColor(.frostAccent)
    }
}

#Preview {
    ContentView()
}
