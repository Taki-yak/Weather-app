//
//  UserPreferences.swift
//  Weather
//
//  Created by Akram El Gouri on 23/1/2025.
//

//
//  UserPreferences.swift
//  Weather
//

import Foundation

struct UserPreferences: Codable {
    var isCelsius: Bool
    var isDarkMode: Bool
    var locations: [String]
    
    static var `default`: UserPreferences {
        UserPreferences(
            isCelsius: true,
            isDarkMode: false,
            locations: ["San Francisco", "New York", "Paris"]
        )
    }
}
