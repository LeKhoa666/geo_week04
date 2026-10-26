//
//  PlaceDetailView.swift
//  practice4
//
//  Created by MAY 05 on 26/10/26.
//


import SwiftUI

struct PlaceDetailView: View {
    let place: Place
    let distanceText: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue.gradient, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.title2)
                        .bold()
                    Text(place.address ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
            }

            HStack {
                Image(systemName: "figure.walk")
                Text(distanceText)
                    .font(.title3)
                    .bold()
                Text("from your location")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.blue)

            HStack(spacing: 20) {
                Label(String(format: "%.4f", place.latitude), systemImage: "location")
                Label(String(format: "%.4f", place.longitude), systemImage: "location")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Button {
                place.openInAppleMaps()
            } label: {
                Label("Show on Map", systemImage: "mappin.and.ellipse")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview {
    PlaceDetailView(place: samplePlaces[0], distanceText: "5.42 km")
}
