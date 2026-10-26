//
//  MapScreenView.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//

import SwiftUI
import CoreLocation
struct MapScreenView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var selectedPlace: Place?
    @State private var showAddAlert = false
    @State private var newPlaceName = ""

    var body: some View {
        NavigationStack {
            MapView(locationManager: locationManager,
                    places: locationManager.places,
                    selectedPlace: $selectedPlace)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom)
                .navigationTitle("Map")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            newPlaceName = ""
                            showAddAlert = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .disabled(locationManager.currentLocation == nil)
                    }
                }
                .alert("Save Current Location", isPresented: $showAddAlert) {
                    TextField("Place name", text: $newPlaceName)
                    Button("Save") {
                        locationManager.addCurrentLocation(named: newPlaceName)
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Add your current location to Saved Places.")
                }
                .sheet(item: $selectedPlace) { place in
                    PlaceSummaryView(place: place, distanceText: distanceText(to: place))
                        .presentationDetents([.height(220)])
                }
                .onAppear {
                    locationManager.requestPermission()
                    if locationManager.isAuthorized && !locationManager.isTracking {
                        locationManager.startUpdatingLocation()
                    }
                }
        }
    }

    private func distanceText(to place: Place) -> String {
        guard let userLocation = locationManager.currentLocation else { return "--" }
        return String(format: "%.2f km", userLocation.distance(from: place.location) / 1000)
    }
}

struct PlaceSummaryView: View {
    let place: Place
    let distanceText: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.title3)
                        .bold()
                    if let address = place.address {
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            Label(String(format: "%.4f, %.4f", place.latitude, place.longitude), systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .monospacedDigit()

            Label("\(distanceText) from you", systemImage: "figure.walk")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .padding()
    }
}
