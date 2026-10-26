//
//  LocationInfoView.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//
import SwiftUI
import CoreLocation
struct LocationInfoView: View {
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.blue)

            VStack(spacing: 0) {
                InfoRow(title: "Latitude",
                        value: locationManager.currentLocation.map { String(format: "%.4f", $0.coordinate.latitude) } ?? "--")
                InfoRow(title: "Longitude",
                        value: locationManager.currentLocation.map { String(format: "%.4f", $0.coordinate.longitude) } ?? "--")
                InfoRow(title: "Accuracy",
                        value: locationManager.currentLocation == nil ? "--" : String(format: "%.1f m", locationManager.accuracy))
                InfoRow(title: "Permission",
                        value: locationManager.authorizationStatusText,
                        valueColor: locationManager.isAuthorized ? .green : .red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
    }
}
