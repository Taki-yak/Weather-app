//
//  MapViewModel.swift
//  Weather
//

import Foundation
import MapKit
import SwiftUI
import Combine

@MainActor
class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @Published private(set) var locations: [WeatherLocation] = []
    @Published private(set) var isSearching = false
    private var searchCancellable: AnyCancellable?
    
    func searchLocation(_ query: String) {
        guard !query.isEmpty else { return }
        
        Task { @MainActor in
            isSearching = true
            
            do {
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = query
                
                let search = MKLocalSearch(request: searchRequest)
                let response = try await search.start()
                
                if let item = response.mapItems.first {
                    let newLocation = WeatherLocation(
                        name: item.name ?? query,
                        lat: item.placemark.coordinate.latitude,
                        lon: item.placemark.coordinate.longitude
                    )
                    
                    withAnimation {
                        self.region = MKCoordinateRegion(
                            center: item.placemark.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                        )
                        
                        if !self.locations.contains(where: { $0.name == newLocation.name }) {
                            self.locations.append(newLocation)
                        }
                    }
                }
            } catch {
                print("Search error: \(error.localizedDescription)")
            }
            
            isSearching = false
        }
    }
}
