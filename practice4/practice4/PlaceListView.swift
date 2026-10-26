//
//  PlaceListView.swift
//  practice4
//
//  Created by MAY 05 on 26/10/26.
//


import SwiftUI

struct PlaceListView: View {
    let places: [Place] = samplePlaces

    var body: some View {
        NavigationStack {
            List(places) { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.headline)
                    if let address = place.address {
                        Text(address)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .navigationTitle("Saved Places")
        }
    }
}

#Preview {
    PlaceListView()
}
