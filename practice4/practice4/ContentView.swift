//
//  ContentView.swift
//  practice4
//
//  Created by MAY 05 on 26/10/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            PlaceListView()
                .tabItem {
                    Label("Places", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
}
