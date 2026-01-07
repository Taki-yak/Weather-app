//
//  ErrorHandlingViews.swift
//  Weather
//
//  Error handling components for Weather app
//

import SwiftUI

// MARK: - Weather Error Types
enum WeatherError: LocalizedError {
    case networkError(String)
    case locationError
    case apiError(Int)
    case noData
    case invalidURL
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Connection Problem"
        case .locationError:
            return "Location Access Needed"
        case .apiError(let code):
            return "Weather Service Error (\(code))"
        case .noData:
            return "No Data Available"
        case .invalidURL:
            return "Invalid Request"
        case .invalidResponse:
            return "Invalid Response"
        case .invalidData:
            return "Invalid Data"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again"
        case .locationError:
            return "Enable location services in Settings to see weather for your area"
        case .apiError(let code) where code == 404:
            return "Location not found. Please try searching again"
        case .apiError(let code) where code == 401:
            return "Authentication error. Please contact support"
        case .apiError(let code) where code >= 500:
            return "The weather service is temporarily unavailable"
        case .noData:
            return "Pull down to refresh"
        case .invalidURL, .invalidResponse, .invalidData:
            return "Something went wrong. Please try again"
        default:
            return "Please try again later"
        }
    }
    
    var icon: String {
        switch self {
        case .networkError:
            return "wifi.slash"
        case .locationError:
            return "location.slash"
        case .apiError:
            return "exclamationmark.icloud"
        case .noData:
            return "arrow.clockwise"
        case .invalidURL, .invalidResponse, .invalidData:
            return "exclamationmark.triangle"
        }
    }
}

// MARK: - Friendly Error View
struct FriendlyErrorView: View {
    let error: WeatherError
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: error.icon)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.8))
                .symbolRenderingMode(.hierarchical)
            
            Text(error.errorDescription ?? "Something went wrong")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Text(error.recoverySuggestion ?? "Please try again")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundColor(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
                .cornerRadius(25)
                .shadow(radius: 5)
            }
            .padding(.top, 10)
            
            if case .locationError = error {
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Settings")
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
    }
}

// MARK: - Enhanced Loading View
struct EnhancedLoadingView: View {
    @State private var loadingText = "Loading weather data"
    @State private var dots = ""
    @State private var timeoutReached = false
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            if !timeoutReached {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(loadingText + dots)
                    .foregroundColor(.white)
                    .font(.body)
            } else {
                Image(systemName: "hourglass")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text("This is taking longer than expected")
                    .foregroundColor(.white)
                    .font(.title3)
                    .bold()
                
                Text("Please check your connection")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.body)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
        .onReceive(timer) { _ in
            if dots.count < 3 {
                dots += "."
            } else {
                dots = ""
            }
        }
        .onAppear {
            // Show timeout message after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation {
                    timeoutReached = true
                }
            }
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: String
    let icon: String
    let isError: Bool
    @Binding var show: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
            Text(message)
                .font(.body)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(isError ? Color.red.opacity(0.9) : Color.black.opacity(0.8))
        .cornerRadius(25)
        .shadow(radius: 10)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    show = false
                }
            }
        }
    }
}
