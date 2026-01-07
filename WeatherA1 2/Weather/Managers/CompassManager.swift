//
//  CompassManager.swift
//  Weather
//

import Foundation
import CoreLocation
import Combine

class CompassManager: NSObject, ObservableObject {
    private let locationManager: CLLocationManager
    @Published var heading: Double = 0.0
    @Published var isCalibrating = false
    @Published var isAuthorized = false
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.headingFilter = 1
        
        // Configure for background updates
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.showsBackgroundLocationIndicator = true
        
        checkPermissions()
    }
    
    func checkPermissions() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            startUpdatingHeading()
        default:
            isAuthorized = false
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func startUpdatingHeading() {
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
}

extension CompassManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = newHeading.magneticHeading
            self.isCalibrating = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Compass error: \(error.localizedDescription)")
        if let error = error as? CLError, error.code == .headingFailure {
            DispatchQueue.main.async {
                self.isCalibrating = true
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkPermissions()
    }
}
