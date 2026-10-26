//
//  ContentView.swift
//  practice3
//
//  Created by MAY 05 on 26/10/26.
//
import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: locationManager.isTracking ? "checkmark.circle.fill" : "location.circle.fill")
                        .font(.system(size: 55))
                        .foregroundStyle(locationManager.isTracking ? .green : .blue)

                    HStack {
                        Circle()
                            .fill(locationManager.isTracking ? Color.green : Color.gray)
                            .frame(width: 10, height: 10)
                        Text(locationManager.isTracking ? "Tracking Active" : "Not Tracking")
                            .font(.headline)
                            .foregroundStyle(locationManager.isTracking ? .green : .secondary)
                    }

                    if locationManager.isTracking && locationManager.currentLocation == nil {
                        ProgressView("Receiving location updates...")
                    }

                    if let error = locationManager.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.center)
                    }

                    if let location = locationManager.currentLocation {
                        TrackingMapView(location: location,
                                        path: locationManager.path,
                                        cameraPosition: $cameraPosition)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        LocationInfoRow(title: "Latitude",
                                        value: locationManager.currentLocation.map { String(format: "%.4f°", $0.coordinate.latitude) } ?? "-")
                        Divider()
                        LocationInfoRow(title: "Longitude",
                                        value: locationManager.currentLocation.map { String(format: "%.4f°", $0.coordinate.longitude) } ?? "-")
                        Divider()
                        LocationInfoRow(title: "Accuracy",
                                        value: locationManager.currentLocation.map { String(format: "± %.0f m", $0.horizontalAccuracy) } ?? "-")
                        Divider()
                        LocationInfoRow(title: "Last update",
                                        value: locationManager.lastUpdateTime?.formatted(date: .omitted, time: .standard) ?? "-")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    HStack(spacing: 16) {
                        DistanceCard(title: "Total Distance",
                                     value: locationManager.totalDistance,
                                     unit: " m",
                                     icon: "point.topleft.down.to.point.bottomright.curvepath.fill",
                                     color: .blue)
                        DistanceCard(title: "Last Movement",
                                     value: locationManager.lastDistance,
                                     unit: " m",
                                     icon: "figure.walk",
                                     color: .green)
                    }

                    SettingsView(locationManager: locationManager)

                    HStack(spacing: 12) {
                        if locationManager.isTracking {
                            Button(action: {
                                locationManager.stopTracking()
                            }) {
                                Label("Stop Tracking", systemImage: "stop.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        } else {
                            Button(action: {
                                locationManager.startTracking()
                            }) {
                                Label("Start Tracking", systemImage: "play.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .controlSize(.large)
                }
                .padding()
            }
            .navigationTitle("Smart Location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LocationInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).monospacedDigit()
        }
        .font(.subheadline)
        .padding(.vertical, 6)
    }
}

struct DistanceCard: View {
    let title: String
    let value: Double
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(String(format: "%.1f", value) + unit)
                .font(.title3.bold())
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct TrackingMapView: View {
    let location: CLLocation
    let path: [CLLocationCoordinate2D]
    @Binding var cameraPosition: MapCameraPosition

    var body: some View {
        Map(position: $cameraPosition) {
            if path.count > 1 {
                MapPolyline(coordinates: path)
                    .stroke(.red, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
            }
            MapCircle(center: location.coordinate, radius: max(location.horizontalAccuracy, 5))
                .foregroundStyle(.blue.opacity(0.2))
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
        .onChange(of: location) { _, newLocation in
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(center: newLocation.coordinate,
                                                            latitudinalMeters: 600,
                                                            longitudinalMeters: 600))
            }
        }
        .onAppear {
            cameraPosition = .region(MKCoordinateRegion(center: location.coordinate,
                                                        latitudinalMeters: 600,
                                                        longitudinalMeters: 600))
        }
    }
}

struct SettingsView: View {
    @ObservedObject var locationManager: LocationManager

    private struct AccuracyOption: Hashable {
        let name: String
        let value: CLLocationAccuracy
    }

    private let accuracyOptions: [AccuracyOption] = [
        AccuracyOption(name: "Best", value: kCLLocationAccuracyBest),
        AccuracyOption(name: "10 m", value: kCLLocationAccuracyNearestTenMeters),
        AccuracyOption(name: "100 m", value: kCLLocationAccuracyHundredMeters),
        AccuracyOption(name: "1 km", value: kCLLocationAccuracyKilometer)
    ]

    private let distanceOptions: [CLLocationDistance] = [0, 5, 10, 50, 100]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tracking Settings")
                .font(.headline)

            Text("Accuracy")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Accuracy", selection: Binding(
                get: { locationManager.desiredAccuracy },
                set: { locationManager.updateTrackingSettings(accuracy: $0, distance: locationManager.distanceFilter) }
            )) {
                ForEach(accuracyOptions, id: \.self) { option in
                    Text(option.name).tag(option.value)
                }
            }
            .pickerStyle(.segmented)

            Text("Distance filter")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Distance filter", selection: Binding(
                get: { locationManager.distanceFilter },
                set: { locationManager.updateTrackingSettings(accuracy: locationManager.desiredAccuracy, distance: $0) }
            )) {
                ForEach(distanceOptions, id: \.self) { value in
                    Text("\(Int(value)) m").tag(value)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
