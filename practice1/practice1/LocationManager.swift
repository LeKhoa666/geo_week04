//
//  LocationManager.swift
//  practice1
//
//  Created by MAY 05 on 26/10/26.
//


import Foundation
import CoreLocation
import Combine
import SwiftUI

class LocationManager: NSObject, ObservableObject {

    private let manager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var servicesEnabled: Bool

    override init() {
        authorizationStatus = manager.authorizationStatus
        servicesEnabled = true // updated right after by refreshServicesEnabled()
        super.init()
        manager.delegate = self
        refreshServicesEnabled()
    }

    /// Ask the user for "When In Use" authorization.
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func refreshStatus() {
        authorizationStatus = manager.authorizationStatus
        refreshServicesEnabled()
    }


    private func refreshServicesEnabled() {
        DispatchQueue.global(qos: .userInitiated).async {
            let enabled = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                self.servicesEnabled = enabled
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        refreshServicesEnabled()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}
