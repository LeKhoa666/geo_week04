//
//  SavedPlacesView.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//


import SwiftUI
import CoreLocation

struct SavedPlacesView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var showAddAlert = false
    @State private var newPlaceName = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(locationManager.places) { place in
                    NavigationLink {
                        PlaceDetailView(place: place, userLocation: locationManager.currentLocation)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.name)
                                    .font(.headline)
                                Text(String(format: "%.4f, %.4f", place.latitude, place.longitude))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .onDelete(perform: deletePlace)
            }
            .overlay {
                if locationManager.places.isEmpty {
                    ContentUnavailableView("No Saved Places",
                                           systemImage: "mappin.slash",
                                           description: Text("Tap + to save your current location."))
                }
            }
            .navigationTitle("Saved Places")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
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
                Text("Start tracking on the Home tab to get your current location.")
            }
        }
    }

    private func deletePlace(at offsets: IndexSet) {
        locationManager.deletePlaces(at: offsets)
    }
}
