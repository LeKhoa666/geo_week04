//
//  MapView.swift
//  practice4
//
//  Created by MAY 05 on 26/10/26.
//


import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var selectedPlace: Place?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.8231, longitude: 106.6297),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )

    private let places: [Place] = samplePlaces

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    Map(position: $cameraPosition, selection: $selectedPlace) {
                        ForEach(places) { place in
                            Marker(place.name, systemImage: "mappin", coordinate: place.coordinate)
                                .tint(.red)
                                .tag(place)
                        }
                        UserAnnotation()
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }

                    if locationManager.currentLocation == nil {
                        Text(locationManager.authorizationStatus == .denied
                             ? "Location permission denied"
                             : "Waiting for location...")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.thinMaterial, in: Capsule())
                            .padding(.top, 8)
                    }
                }

                List(places) { place in
                    Button {
                        selectedPlace = place
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(String(format: "%.4f, %.4f", place.latitude, place.longitude))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .listStyle(.plain)
                .frame(height: 210)
            }
            .navigationTitle("Saved Places")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationManager.requestAuthorization()
                locationManager.startUpdatingLocation()
            }
            .onChange(of: selectedPlace) { _, place in
                if let place = place {
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: place.coordinate,
                                latitudinalMeters: 1000,
                                longitudinalMeters: 1000
                            )
                        )
                    }
                }
            }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailView(place: place, distanceText: distanceText(to: place))
                    .presentationDetents([.height(320), .medium])
            }
        }
    }

    private func distanceText(to place: Place) -> String {
        guard let userLocation = locationManager.currentLocation else {
            return "--"
        }
        let distanceInMeters = userLocation.distance(from: place.location)
        let distanceInKilometers = distanceInMeters / 1000.0
        return String(format: "%.2f km", distanceInKilometers)
    }
}

#Preview {
    MapView()
}
