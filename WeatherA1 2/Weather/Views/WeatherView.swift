//
//  WeatherView.swift
//  Weather
//

import SwiftUI

struct WeatherView: View {
    var weather: ResponseBody
    @State private var lastUpdated = Date()
    @State private var showToast = false
    var onRefresh: (() async -> Void)?
    
    // Time formatter
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    // Function to get the appropriate weather icon
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
            return "cloud.fill" // Default icon
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    // Last updated indicator
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("Updated: \(lastUpdated, formatter: timeFormatter)")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 10)
                    
                    // Top section with location and date
                    VStack(alignment: .leading, spacing: 5) {
                        Text(weather.name)
                            .bold()
                            .font(.title)
                        
                        Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                            .fontWeight(.light)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 30)
                    
                    Spacer(minLength: 50)
                    
                    // Middle section with weather icon and temperature
                    VStack {
                        HStack {
                            VStack(spacing: 20) {
                                Image(systemName: getWeatherIcon(condition: weather.weather[0].description))
                                    .font(.system(size: 50))
                                
                                Text(weather.weather[0].main)
                            }
                            .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            Text(weather.main.feelsLike.roundDouble() + "°")
                                .font(.system(size: 100))
                                .fontWeight(.bold)
                                .padding()
                        }
                        
                        Spacer()
                            .frame(height: 50)
                        
                        // City image
                        AsyncImage(url: URL(string: "https://cdn.pixabay.com/photo/2018/12/10/16/22/city-3867295_1280.png")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 350)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .padding(.bottom, 200) // Add padding for the weather details panel
            }
            .refreshable {
                if let onRefresh = onRefresh {
                    await onRefresh()
                    lastUpdated = Date()
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    // Show toast
                    withAnimation {
                        showToast = true
                    }
                }
            }
            
            // Bottom white panel with weather details
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weather now")
                        .bold()
                        .padding(.bottom)
                    
                    HStack {
                        WeatherRow(logo: "thermometer.low",
                                 name: "Min temp",
                                 value: weather.main.tempMin.roundDouble() + "°")
                        
                        Spacer()
                        
                        WeatherRow(logo: "thermometer.high",
                                 name: "Max temp",
                                 value: weather.main.tempMax.roundDouble() + "°")
                    }
                    
                    HStack {
                        WeatherRow(logo: "wind",
                                 name: "Wind speed",
                                 value: weather.wind.speed.roundDouble() + " m/s")
                        
                        Spacer()
                        
                        WeatherRow(logo: "humidity",
                                 name: "Humidity",
                                 value: weather.main.humidity.roundDouble() + "%")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 20)
                .foregroundColor(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
                .background(.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .padding(.bottom, 80)
            }
            
            // Toast notification
            VStack {
                if showToast {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Weather updated")
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
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
        .preferredColorScheme(.dark)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(weather: previewWeather)
    }
}
