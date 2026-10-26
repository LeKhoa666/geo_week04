//
//  PlaceDetailView.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//


import SwiftUI
import MapKit
import CoreLocation

struct PlaceDetailView: View {
    let place: Place
    let userLocation: CLLocation?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)

                Text(place.name)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                if let address = place.address {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(title: "Latitude", value: String(format: "%.6f", place.coordinate.latitude))
                    DetailRow(title: "Longitude", value: String(format: "%.6f", place.coordinate.longitude))
                    if let userLocation = userLocation {
                        DetailRow(title: "Distance",
                                  value: String(format: "%.2f km", userLocation.distance(from: place.location) / 1000))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

                Map(initialPosition: .region(MKCoordinateRegion(center: place.coordinate,
                                                                latitudinalMeters: 1500,
                                                                longitudinalMeters: 1500))) {
                    Marker(place.name, coordinate: place.coordinate)
                        .tint(.red)
                }
                .frame(height: 250)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Place Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
}
