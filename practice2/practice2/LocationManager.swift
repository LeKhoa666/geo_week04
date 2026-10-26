//
//  LocationManager.swift
//  practice2
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
    @Published var errorMessage: String?
    @Published var isRequesting = false

    private var completionHandler: ((CLLocation?) -> Void)?
    private var pendingRequest = false

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }

    func requestCurrentLocation(completion: ((CLLocation?) -> Void)? = nil) {
        errorMessage = nil

        switch manager.authorizationStatus {
        case .notDetermined:
            pendingRequest = true
            completionHandler = completion
            isRequesting = true
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location permission not granted.")
            errorMessage = "Location permission denied. Go to Settings > Privacy & Security > Location Services to allow access."
            isRequesting = false
            completion?(nil)
        case .authorizedWhenInUse, .authorizedAlways:
            completionHandler = completion
            isRequesting = true
            manager.requestLocation()
        @unknown default:
            print("Unknown authorization status")
            completion?(nil)
        }
    }

    func startUpdatingLocation() {
        guard manager.authorizationStatus == .authorizedWhenInUse
                || manager.authorizationStatus == .authorizedAlways else {
            print("Location permission not granted.")
            return
        }
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }

        guard pendingRequest else { return }
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            pendingRequest = false
            manager.requestLocation()
        case .denied, .restricted:
            pendingRequest = false
            DispatchQueue.main.async {
                self.isRequesting = false
                self.errorMessage = "Location permission denied."
                self.completionHandler?(nil)
                self.completionHandler = nil
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("No location received")
            return
        }

        let coordinate = location.coordinate
        print("Lat: \(coordinate.latitude)")
        print("Lng: \(coordinate.longitude)")
        print("Accuracy: \(location.horizontalAccuracy) m")

        DispatchQueue.main.async {
            self.currentLocation = location
            self.errorMessage = nil
            self.isRequesting = false
            self.completionHandler?(location)
            self.completionHandler = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to get location: \(error)")
        DispatchQueue.main.async {
            self.currentLocation = nil
            self.errorMessage = self.message(for: error)
            self.isRequesting = false
            self.completionHandler?(nil)
            self.completionHandler = nil
        }
    }

    private func message(for error: Error) -> String {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied: return "Location permission denied."
            case .locationUnknown: return "Location unknown. Try moving to an open area."
            case .network: return "Network error. Check your internet connection and try again."
            default: return "Failed to get location: \(error.localizedDescription)"
            }
        }
        return "Failed to get location: \(error.localizedDescription)"
    }
}