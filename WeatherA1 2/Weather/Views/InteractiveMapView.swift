//
//  InteractiveMapView.swift
//  Weather
//

import SwiftUI
import MapKit

struct InteractiveMapView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @State private var searchText = ""
    @State private var showingWeatherSheet = false
    @State private var selectedLocation: WeatherLocation?
    let weatherManager: WeatherManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(coordinateRegion: $mapViewModel.region,
                    annotationItems: mapViewModel.locations) { location in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: location.lat,
                        longitude: location.lon
                    )) {
                        LocationMapMarker(location: location) {
                            selectedLocation = location
                            showingWeatherSheet = true
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    SearchBarView(
                        searchText: $searchText,
                        isSearching: mapViewModel.isSearching
                    ) {
                        mapViewModel.searchLocation(searchText)
                    }
                    .padding(.top)
                    
                    Spacer()
                }
            }
            .navigationTitle("Weather Map")
            .sheet(isPresented: $showingWeatherSheet) {
                if let location = selectedLocation {
                    WeatherSheetView(
                        location: location,
                        weatherManager: weatherManager,
                        isPresented: $showingWeatherSheet
                    )
                }
            }
        }
    }
}

struct LocationMapMarker: View {
    let location: WeatherLocation
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                
                Text(location.name)
                    .font(.caption)
                    .padding(4)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(4)
            }
        }
    }
}

struct WeatherSheetView: View {
    let location: WeatherLocation
    let weatherManager: WeatherManager
    @Binding var isPresented: Bool
    @State private var weather: ResponseBody?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    LoadingView()
                } else if let weather = weather {
                    WeatherView(weather: weather)
                } else {
                    Text("Failed to load weather data")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle(location.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .task {
                do {
                    weather = try await weatherManager.getCurrentWeather(
                        latitude: location.lat,
                        longitude: location.lon
                    )
                } catch {
                    print("Error fetching weather: \(error)")
                }
                isLoading = false
            }
        }
    }
}

struct InteractiveMapView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveMapView(weatherManager: WeatherManager())
    }
}
