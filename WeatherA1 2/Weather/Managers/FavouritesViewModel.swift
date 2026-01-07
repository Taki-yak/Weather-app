//
//  FavouritesViewModel.swift
//  Weather
//

import Foundation
import CoreLocation

class FavouritesViewModel: ObservableObject {
    @Published var savedLocations: [SavedLocation] = []
    @Published var searchResults: [LocationSearchResult]?
    @Published var isSearching = false
    private let geocoder = CLGeocoder()
    
    init() {
        loadSavedLocations()
        if savedLocations.isEmpty {
            addDefaultCities()
        }
    }
    
    private func addDefaultCities() {
        let defaultCities = [
            (name: "London", lat: 51.5074, lon: -0.1278),
            (name: "Paris", lat: 48.8566, lon: 2.3522),
            (name: "New York", lat: 40.7128, lon: -74.0060),
            (name: "Tokyo", lat: 35.6762, lon: 139.6503),
            (name: "Sydney", lat: -33.8688, lon: 151.2093),
            (name: "Dubai", lat: 25.2048, lon: 55.2708),
            (name: "Singapore", lat: 1.3521, lon: 103.8198),
            (name: "Rome", lat: 41.9028, lon: 12.4964),
            (name: "Cairo", lat: 30.0444, lon: 31.2357),
            (name: "Rio de Janeiro", lat: -22.9068, lon: -43.1729)
        ]
        
        for city in defaultCities {
            addLocation(name: city.name, latitude: city.lat, longitude: city.lon)
        }
    }
    
    func performSearch(_ query: String) {
        isSearching = true
        geocoder.geocodeAddressString(query) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSearching = false
                
                if let placemarks = placemarks {
                    self.searchResults = placemarks.compactMap { placemark in
                        guard let name = placemark.name ?? placemark.locality,
                              let location = placemark.location else { return nil }
                        
                        return LocationSearchResult(
                            name: name,
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    }
                }
            }
        }
    }
    
    func addLocation(name: String, latitude: Double, longitude: Double) {
        let newLocation = SavedLocation(name: name, latitude: latitude, longitude: longitude)
        savedLocations.append(newLocation)
        saveToDisk()
    }
    
    func removeLocation(_ location: SavedLocation) {
        savedLocations.removeAll { $0.id == location.id }
        saveToDisk()
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedLocations) {
            UserDefaults.standard.set(encoded, forKey: "savedLocations")
        }
    }
    
    private func loadSavedLocations() {
        if let data = UserDefaults.standard.data(forKey: "savedLocations"),
           let decoded = try? JSONDecoder().decode([SavedLocation].self, from: data) {
            savedLocations = decoded
        }
    }
}
