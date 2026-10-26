//
//  LocationManager.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//

import SwiftUI
import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var accuracy: Double = 0.0
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var isTracking: Bool = false
    @Published var places: [Place] = [] {
        didSet { savePlaces() }
    }

    private let locationManager = CLLocationManager()
    private let placesKey = "savedPlaces"

    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        setupLocationManager()
        loadPlaces()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var authorizationStatusText: String {
        switch authorizationStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedWhenInUse, .authorizedAlways: return "Authorized"
        @unknown default: return "Unknown"
        }
    }

    func requestPermission() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func startUpdatingLocation() {
        if locationManager.authorizationStatus == .notDetermined {
            isTracking = true
            locationManager.requestWhenInUseAuthorization()
            return
        }
        guard isAuthorized else {
            print("Location permission not granted.")
            return
        }
        locationManager.startUpdatingLocation()
        isTracking = true
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isTracking = false
    }

    func addPlace(_ place: Place) {
        places.append(place)
    }

    func addCurrentLocation(named name: String) {
        guard let location = currentLocation else { return }
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        addPlace(Place(name: trimmed.isEmpty ? "My Place" : trimmed,
                       latitude: location.coordinate.latitude,
                       longitude: location.coordinate.longitude,
                       address: "Saved from current location"))
    }

    func deletePlace(_ place: Place) {
        places.removeAll { $0.id == place.id }
    }

    func deletePlaces(at offsets: IndexSet) {
        places.remove(atOffsets: offsets)
    }

    private func savePlaces() {
        if let data = try? JSONEncoder().encode(places) {
            UserDefaults.standard.set(data, forKey: placesKey)
        }
    }

    private func loadPlaces() {
        if let data = UserDefaults.standard.data(forKey: placesKey),
           let saved = try? JSONDecoder().decode([Place].self, from: data) {
            places = saved
        } else {
            places = Place.samples
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if self.isTracking {
                if self.isAuthorized {
                    manager.startUpdatingLocation()
                } else if status != .notDetermined {
                    self.isTracking = false
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
            self.accuracy = location.horizontalAccuracy
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
