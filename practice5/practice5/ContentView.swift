//
//  ContentView.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        TabView {
            HomeView(locationManager: locationManager)
                .tabItem { Label("Home", systemImage: "house.fill") }

            MapScreenView(locationManager: locationManager)
                .tabItem { Label("Map", systemImage: "map.fill") }

            SavedPlacesView(locationManager: locationManager)
                .tabItem { Label("Saved Places", systemImage: "list.bullet") }
        }
    }
}

#Preview {
    ContentView()
}
