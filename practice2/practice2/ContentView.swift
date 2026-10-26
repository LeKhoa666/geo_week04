//
//  ContentView.swift
//  practice2
//
//  Created by MAY 05 on 26/10/26.
//
import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 65))
                        .foregroundStyle(.blue)

                    Text("My Current Location")
                        .font(.title2.bold())

                    if locationManager.isRequesting {
                        ProgressView("Requesting location...")
                            .padding()
                    } else if let location = locationManager.currentLocation {
                        LocationMapView(location: location)
                        LocationInfoView(location: location)
                    } else if let error = locationManager.errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.orange)
                            Text("Unable to get your location")
                                .font(.headline)
                            Text(error)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else {
                        Text("Tap the button to get your current location.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                    }

                    Button {
                        locationManager.requestCurrentLocation()
                    } label: {
                        Label("Get Current Location", systemImage: "location.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(locationManager.isRequesting)
                }
                .padding()
            }
            .navigationTitle("Smart Location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Location information card
struct LocationInfoView: View {
    let location: CLLocation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Label("Location received", systemImage: "checkmark.circle.fill")
                .font(.subheadline.bold())
                .foregroundStyle(.green)
                .padding(.bottom, 8)

            infoRow("Latitude", String(format: "%.4f°", location.coordinate.latitude))
            Divider()
            infoRow("Longitude", String(format: "%.4f°", location.coordinate.longitude))
            Divider()
            infoRow("Altitude", String(format: "%.1f m", location.altitude))
            Divider()
            infoRow("Accuracy", String(format: "± %.1f m", location.horizontalAccuracy))
            Divider()
            infoRow("Timestamp", location.timestamp.formatted(date: .abbreviated, time: .standard))
        }
        .padding()
        .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).monospacedDigit()
        }
        .font(.subheadline)
        .padding(.vertical, 6)
    }
}

// MARK: - Map with accuracy circle (Step 5)
struct LocationMapView: View {
    let location: CLLocation

    var body: some View {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: max(location.horizontalAccuracy * 6, 500),
            longitudinalMeters: max(location.horizontalAccuracy * 6, 500)
        )

        Map(position: .constant(.region(region))) {
            MapCircle(center: location.coordinate,
                      radius: max(location.horizontalAccuracy, 5))
                .foregroundStyle(.blue.opacity(0.2))
                .stroke(.blue.opacity(0.5), lineWidth: 1)
            Annotation("", coordinate: location.coordinate) {
                Circle()
                    .fill(.blue)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .shadow(radius: 2)
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
