//
//  ContentView.swift
//  practice1
//
//  Created by MAY 05 on 26/10/26.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 65))
                    .foregroundStyle(locationManager.servicesEnabled ? .blue : .gray)

                Text("Location Services")
                    .font(.title2.bold())

                Group {
                    statusRow(title: "Services enabled",
                              value: locationManager.servicesEnabled ? "Yes" : "No",
                              color: locationManager.servicesEnabled ? .blue : .red)
                    statusRow(title: "Permission",
                              value: permissionText,
                              color: permissionColor)
                }

                Button("Request Location Permission") {
                    locationManager.requestPermission()
                }
                .buttonStyle(.borderedProminent)
                .disabled(locationManager.authorizationStatus != .notDetermined
                          || !locationManager.servicesEnabled)

                Button("Refresh Status") {
                    locationManager.refreshStatus()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Smart Location")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.refreshStatus()
            }
        }
    }

    // Helper view for status text
    @ViewBuilder
    private func statusRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title + ":")
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(color)
        }
    }

    // Convert authorization status to text
    private var permissionText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedWhenInUse: return "Authorized When In Use"
        case .authorizedAlways: return "Authorized Always"
        @unknown default: return "Unknown"
        }
    }

    private var permissionColor: Color {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: return .green
        case .denied: return .red
        case .restricted: return .orange
        default: return .blue
        }
    }
}

#Preview {
    ContentView()
}
