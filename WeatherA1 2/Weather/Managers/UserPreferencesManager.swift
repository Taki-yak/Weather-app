//
//  UserPreferencesManager.swift
//  Weather
//

import Foundation
import Combine

class UserPreferencesManager: ObservableObject {
    static let shared = UserPreferencesManager()
    
    @Published private(set) var preferences: UserPreferences = .default
    private let userDefaults = UserDefaults.standard
    private let preferencesKey = "userPreferences"
    
    private init() {
        // Load saved preferences from UserDefaults when initializing
        loadPreferences()
    }
    
    func savePreferences(isCelsius: Bool, isDarkMode: Bool, locations: [String]) {
        // Update the preferences
        preferences = UserPreferences(
            isCelsius: isCelsius,
            isDarkMode: isDarkMode,
            locations: locations
        )
        
        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(preferences) {
            userDefaults.set(data, forKey: preferencesKey)
            // Notify observers that preferences have been updated
            objectWillChange.send()
        }
    }
    
    // Load preferences from UserDefaults
    private func loadPreferences() {
        if let data = userDefaults.data(forKey: preferencesKey),
           let savedPreferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            preferences = savedPreferences
        }
    }
    
    // Get current preferences
    func getPreferences() -> UserPreferences {
        return preferences
    }
    
    // Reset preferences to default values
    func resetPreferences() {
        preferences = .default
        if let data = try? JSONEncoder().encode(preferences) {
            userDefaults.set(data, forKey: preferencesKey)
            objectWillChange.send()
        }
    }
}
