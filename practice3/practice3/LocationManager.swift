//
//  LocationManager.swift
//  practice3
//
//  Created by MAY 05 on 26/10/26.
//


import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var currentLocation: CLLocation?
    @Published var previousLocation: CLLocation?
    @Published var lastUpdateTime: Date?
    @Published var isTracking = false
    @Published var errorMessage: String?
    @Published var path: [CLLocationCoordinate2D] = []

    @Published var desiredAccuracy = kCLLocationAccuracyBest
    @Published var distanceFilter: CLLocationDistance = 10

    @Published var totalDistance: CLLocationDistance = 0
    @Published var lastDistance: CLLocationDistance = 0

    private let minDistanceThreshold: CLLocationDistance = 5
    private let maxAcceptedAccuracy: CLLocationAccuracy = 100
    private var startWhenAuthorized = false

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = desiredAccuracy
        manager.distanceFilter = distanceFilter
        manager.allowsBackgroundLocationUpdates = false
    }

    func requestCurrentLocation() {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            print("Location permission not granted.")
        }
    }

    func startTracking() {
        errorMessage = nil

        switch manager.authorizationStatus {
        case .notDetermined:
            startWhenAuthorized = true
            manager.requestWhenInUseAuthorization()
            return
        case .restricted, .denied:
            print("Location permission not granted.")
            errorMessage = "Location permission denied. Go to Settings > Privacy & Security > Location Services to allow access."
            return
        default:
            break
        }

        resetDistance()
        manager.startUpdatingLocation()
        isTracking = true
        print("Started location tracking.")
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        isTracking = false
        startWhenAuthorized = false
        print("Stopped location tracking.")
    }

    func updateTrackingSettings(accuracy: CLLocationAccuracy, distance: CLLocationDistance) {
        desiredAccuracy = accuracy
        distanceFilter = distance
        manager.desiredAccuracy = accuracy
        manager.distanceFilter = distance
    }

    func resetDistance() {
        totalDistance = 0
        lastDistance = 0
        previousLocation = nil
        currentLocation = nil
        lastUpdateTime = nil
        path = []
    }

    private func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        from.distance(from: to)
    }

    private func isValidLocation(_ location: CLLocation) -> Bool {
        if location.horizontalAccuracy < 0 {
            return false
        }
        if location.horizontalAccuracy > maxAcceptedAccuracy {
            return false
        }
        if let previous = currentLocation {
            let distance = location.distance(from: previous)
            if distance < minDistanceThreshold {
                return false
            }
        }
        return true
    }

    private func updateLocationInfo(_ location: CLLocation) {
        previousLocation = currentLocation
        currentLocation = location
        lastUpdateTime = Date()
        path.append(location.coordinate)
    }

    private func handleNewLocation(_ newLocation: CLLocation) {
        if !isValidLocation(newLocation) {
            print("Ignored invalid location.")
            return
        }

        if let previous = currentLocation {
            let distance = calculateDistance(from: previous, to: newLocation)
            if distance >= minDistanceThreshold {
                lastDistance = distance
                totalDistance += distance
            }
        }

        updateLocationInfo(newLocation)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.authorizationStatus = status
            guard self.startWhenAuthorized else { return }
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startWhenAuthorized = false
                self.startTracking()
            case .denied, .restricted:
                self.startWhenAuthorized = false
                self.errorMessage = "Location permission denied."
            default:
                break
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            print("No location data received.")
            return
        }
        DispatchQueue.main.async {
            self.handleNewLocation(newLocation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to get location: \(error)")
        let message: String
        if let clError = error as? CLError {
            switch clError.code {
            case .denied: message = "Location permission denied."
            case .locationUnknown: message = "Location unknown. Waiting for GPS signal..."
            case .network: message = "Network error. Check your internet connection."
            default: message = "Failed to get location: \(error.localizedDescription)"
            }
        } else {
            message = "Failed to get location: \(error.localizedDescription)"
        }
        DispatchQueue.main.async {
            self.errorMessage = message
            if let clError = error as? CLError, clError.code == .denied {
                self.stopTracking()
            }
        }
    }
}
