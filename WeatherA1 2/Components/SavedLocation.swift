//
//  SavedLocation.swift
//  Weather
//

import Foundation

struct SavedLocation: Codable, Identifiable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    
    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct LocationSearchResult {
    let name: String
    let latitude: Double
    let longitude: Double
}
