//
//  LocationWeatherView.swift
//  Weather
//

import SwiftUI

struct LocationWeatherView: View {
    let location: SavedLocation
    let weatherManager: WeatherManager
    @State private var weather: ResponseBody?
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                .ignoresSafeArea()
            
            if isLoading {
                LoadingView()
            } else if let weather = weather {
                WeatherView(weather: weather)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("Failed to load weather data")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    Button {
                        Task {
                            await loadWeather()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .task {
            await loadWeather()
        }
    }
    
    private func loadWeather() async {
        isLoading = true
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

// Preview
struct LocationWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationWeatherView(
                location: SavedLocation(
                    name: "London",
                    latitude: 51.5074,
                    longitude: -0.1278
                ),
                weatherManager: WeatherManager()
            )
        }
    }
}
