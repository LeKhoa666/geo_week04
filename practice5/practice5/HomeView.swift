//
//  HomeView.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//


import SwiftUI
import CoreLocation
struct HomeView: View {
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Smart Location Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(locationManager.isTracking ? Color.green : Color.gray)
                            .frame(width: 10, height: 10)
                        Text(locationManager.isTracking ? "Tracking Active" : "Not Tracking")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    LocationInfoView(locationManager: locationManager)

                    HStack(spacing: 16) {
                        Button(action: {
                            locationManager.startUpdatingLocation()
                        }) {
                            Label("Start Tracking", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(locationManager.isTracking)

                        Button(action: {
                            locationManager.stopUpdatingLocation()
                        }) {
                            Label("Stop Tracking", systemImage: "stop.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!locationManager.isTracking)
                    }
                    .controlSize(.large)

                    if locationManager.authorizationStatus == .denied {
                        Text("Location access is denied. Enable it in Settings > Privacy & Security > Location Services.")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
