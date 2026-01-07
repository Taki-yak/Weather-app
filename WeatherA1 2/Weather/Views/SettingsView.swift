//
//  SettingsView.swift
//  Weather
//

import SwiftUI
import CoreLocation

@available(iOS 16.0, *)
struct SettingsView: View {
    @AppStorage("isCelsius") private var isCelsius = true
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingAddLocation = false
    @State private var searchText = ""
    @State private var showingWeatherSheet = false
    @State private var selectedLocation: SavedLocation?
    let weatherManager = WeatherManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Units Section
                        GroupBox {
                            Toggle("Use Celsius", isOn: $isCelsius)
                                .foregroundColor(.white)
                        } label: {
                            Label("Temperature Unit", systemImage: "thermometer")
                                .foregroundColor(.white)
                        }
                        .groupBoxStyle(TransparentGroupBoxStyle())
                        
                        // Favorite Locations Section
                        GroupBox {
                            if viewModel.savedLocations.isEmpty {
                                Text("No saved locations")
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.vertical)
                            } else {
                                ForEach(viewModel.savedLocations) { location in
                                    LocationRow(location: location) {
                                        selectedLocation = location
                                        showingWeatherSheet = true
                                    } onDelete: {
                                        viewModel.removeLocation(location)
                                    }
                                }
                            }
                            
                            Button(action: {
                                showingAddLocation = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Location")
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                            }
                        } label: {
                            Label("Favorite Locations", systemImage: "star.fill")
                                .foregroundColor(.white)
                        }
                        .groupBoxStyle(TransparentGroupBoxStyle())
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingWeatherSheet) {
                if let location = selectedLocation {
                    NavigationView {
                        WeatherSheetView(
                            location: location,
                            weatherManager: weatherManager
                        )
                    }
                }
            }
        }
    }
}

struct LocationRow: View {
    let location: SavedLocation
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onTap) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.white)
                    Text(location.name)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: SettingsViewModel
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                    .ignoresSafeArea()
                
                VStack {
                    SearchBarView(
                        searchText: $searchText,
                        isSearching: isSearching
                    ) {
                        viewModel.searchLocation(searchText)
                    }
                    
                    if let searchResults = viewModel.searchResults {
                        List(searchResults, id: \.name) { result in
                            Button(action: {
                                viewModel.addLocation(name: result.name, latitude: result.latitude, longitude: result.longitude)
                                dismiss()
                            }) {
                                Text(result.name)
                                    .foregroundColor(.white)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Add Location")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct WeatherSheetView: View {
    let location: SavedLocation
    let weatherManager: WeatherManager
    @State private var weather: ResponseBody?
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
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
                    dismiss()
                }
            }
        }
        .task {
            do {
                weather = try await weatherManager.getCurrentWeather(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            } catch {
                print("Error fetching weather: \(error)")
            }
            isLoading = false
        }
    }
}

struct TransparentGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
                .padding(.bottom, 4)
            
            configuration.content
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// View Model
class SettingsViewModel: ObservableObject {
    @Published var savedLocations: [SavedLocation] = []
    @Published var searchResults: [LocationSearchResult]?
    
    init() {
        loadSavedLocations()
    }
    
    func searchLocation(_ query: String) {
        // Implement location search using CLGeocoder
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let placemarks = placemarks {
                    self?.searchResults = placemarks.compactMap { placemark in
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

struct SavedLocation: Codable, Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

struct LocationSearchResult {
    let name: String
    let latitude: Double
    let longitude: Double
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            SettingsView()
        }
    }
}
