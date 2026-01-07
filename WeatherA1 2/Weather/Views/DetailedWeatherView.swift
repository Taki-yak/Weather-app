//
//  DetailedWeatherView.swift
//  Weather
//

import SwiftUI

struct DetailedWeatherView: View {
    let weatherManager: WeatherManager
    let latitude: Double
    let longitude: Double
    @State private var forecast: ForecastResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var lastUpdated = Date()
    @State private var showToast = false
    
    // Time formatter
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    // Function to get day name
    func getDayName(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "EEEE" // Full day name
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    // Function to get weather icon
    func getWeatherIcon(condition: String) -> String {
        switch condition.lowercased() {
        case let condition where condition.contains("clear"):
            return "sun.max.fill"
        case let condition where condition.contains("cloud"):
            if condition.contains("scattered") || condition.contains("few") {
                return "cloud.sun.fill"
            }
            return "cloud.fill"
        case let condition where condition.contains("rain"):
            if condition.contains("light") {
                return "cloud.drizzle.fill"
            }
            return "cloud.rain.fill"
        case let condition where condition.contains("thunder"):
            return "cloud.bolt.rain.fill"
        case let condition where condition.contains("snow"):
            return "cloud.snow.fill"
        case let condition where condition.contains("mist") || condition.contains("fog"):
            return "cloud.fog.fill"
        case let condition where condition.contains("drizzle"):
            return "cloud.drizzle.fill"
        default:
            return "cloud.fill"
        }
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                .ignoresSafeArea()
            
            if isLoading && forecast == nil {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Loading forecast...")
                        .foregroundColor(.white)
                        .font(.body)
                }
            } else if let errorMessage = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Retry") {
                        Task {
                            await loadForecast()
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            } else if let forecast = forecast {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with last updated
                        VStack(spacing: 10) {
                            Text("7-Day Forecast")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("\(forecast.city.name), \(forecast.city.country)")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                            
                            // Last updated indicator
                            HStack {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text("Updated: \(lastUpdated, formatter: timeFormatter)")
                                    .font(.caption)
                            }
                            .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // Filter to get one forecast per day
                        let uniqueDailyForecasts = getDailyForecasts(from: forecast.list)
                        ForEach(uniqueDailyForecasts) { item in
                            DailyForecastCard(
                                item: item,
                                dayName: getDayName(from: item.dt_txt),
                                getWeatherIcon: getWeatherIcon
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .refreshable {
                    await loadForecast()
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    // Show toast
                    withAnimation {
                        showToast = true
                    }
                }
            }
            
            // Toast notification
            VStack {
                if showToast {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Forecast updated")
                            .font(.body)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(25)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 50)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .task {
            await loadForecast()
        }
    }
    
    // Function to get one forecast per day
    private func getDailyForecasts(from forecastList: [ForecastItem]) -> [ForecastItem] {
        var dailyForecasts: [ForecastItem] = []
        var seenDates: Set<String> = []
        
        for item in forecastList {
            let dateString = String(item.dt_txt.prefix(10)) // Get just the date part "YYYY-MM-DD"
            if !seenDates.contains(dateString) {
                seenDates.insert(dateString)
                dailyForecasts.append(item)
            }
        }
        
        return dailyForecasts
    }

    private func loadForecast() async {
        isLoading = true
        errorMessage = nil
        
        do {
            forecast = try await weatherManager.getForecast(
                latitude: latitude,
                longitude: longitude
            )
            lastUpdated = Date()
        } catch {
            errorMessage = "Failed to load forecast. Please try again."
            print("Error fetching forecast: \(error)")
        }
        
        isLoading = false
    }
}

struct DailyForecastCard: View {
    let item: ForecastItem
    let dayName: String
    let getWeatherIcon: (String) -> String
    
    var body: some View {
        HStack {
            // Date and Weather Icon
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(item.dt_txt.prefix(10))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack(spacing: 15) {
                    Image(systemName: getWeatherIcon(item.weather[0].description))
                        .font(.system(size: 25))
                        .symbolRenderingMode(.multicolor)
                    
                    Text(item.weather[0].main)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Temperature and Humidity
            VStack(alignment: .trailing, spacing: 10) {
                HStack {
                    Image(systemName: "thermometer")
                        .foregroundColor(.red)
                    Text("\(Int(round(item.main.temp)))°C")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "humidity")
                        .foregroundColor(.blue)
                    Text("\(Int(round(item.main.humidity)))%")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct DetailedWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedWeatherView(
            weatherManager: WeatherManager(),
            latitude: 37.7749,
            longitude: -122.4194
        )
    }
}
