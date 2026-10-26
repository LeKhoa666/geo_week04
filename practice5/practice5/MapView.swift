//
//  MapView.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//


import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var locationManager: LocationManager
    var places: [Place]
    @Binding var selectedPlace: Place?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedPlace) {
            UserAnnotation()

            ForEach(places) { place in
                Marker(place.name, coordinate: place.coordinate)
                    .tint(.red)
                    .tag(place)
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
            MapCompass()
        }
        .onChange(of: selectedPlace) { _, place in
            if let place = place {
                withAnimation {
                    cameraPosition = .region(MKCoordinateRegion(center: place.coordinate,
                                                                latitudinalMeters: 1500,
                                                                longitudinalMeters: 1500))
                }
            }
        }
    }
}
