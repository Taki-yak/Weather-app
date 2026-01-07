//
//  WeatherManager.swift
//  Weather
//

import Foundation
import CoreLocation

class WeatherManager {
    private let apiKey = "11eab88c1bd74be6473bc44adfd3b504"
    
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric") else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                return try JSONDecoder().decode(ResponseBody.self, from: data)
            case 404:
                throw WeatherError.apiError(404)
            case 401:
                throw WeatherError.apiError(401)
            case 500...599:
                throw WeatherError.apiError(httpResponse.statusCode)
            default:
                throw WeatherError.invalidResponse
            }
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw WeatherError.networkError("No internet connection")
            case .timedOut:
                throw WeatherError.networkError("Request timed out")
            default:
                throw WeatherError.networkError(error.localizedDescription)
            }
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.invalidData
        }
    }
    
    func getForecast(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ForecastResponse {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric") else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                return try JSONDecoder().decode(ForecastResponse.self, from: data)
            case 404:
                throw WeatherError.apiError(404)
            case 401:
                throw WeatherError.apiError(401)
            case 500...599:
                throw WeatherError.apiError(httpResponse.statusCode)
            default:
                throw WeatherError.invalidResponse
            }
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw WeatherError.networkError("No internet connection")
            case .timedOut:
                throw WeatherError.networkError("Request timed out")
            default:
                throw WeatherError.networkError(error.localizedDescription)
            }
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.invalidData
        }
    }
}

// Current Weather Response Model
struct ResponseBody: Codable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse
    
    struct CoordinatesResponse: Codable {
        var lon: Double
        var lat: Double
    }
    
    struct WeatherResponse: Codable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }
    
    struct MainResponse: Codable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }
    
    struct WindResponse: Codable {
        var speed: Double
        var deg: Double
    }
}

// Forecast Response Models
struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
    
    struct City: Codable {
        let name: String
        let country: String
        let coord: Coord
        let timezone: Int
        
        struct Coord: Codable {
            let lat: Double
            let lon: Double
        }
    }
}

struct ForecastItem: Codable, Identifiable {
    var id: Int { dt }  // Using dt (timestamp) as id
    let dt: Int
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let dt_txt: String
    
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Double
        let humidity: Double
        let sea_level: Double?
        let grnd_level: Double?
    }
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Clouds: Codable {
        let all: Int
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Double
        let gust: Double?
    }
}

extension ResponseBody.MainResponse {
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}
