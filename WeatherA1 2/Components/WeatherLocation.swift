//
//  WeatherLocation.swift
//  Weather
//

import Foundation

struct WeatherLocation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let lat: Double
    let lon: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: WeatherLocation, rhs: WeatherLocation) -> Bool {
        lhs.id == rhs.id
    }
}
