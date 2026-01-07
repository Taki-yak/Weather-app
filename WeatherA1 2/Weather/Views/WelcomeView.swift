//
//  WelcomeView.swift
//  Weather
//

import SwiftUI
import CoreLocationUI

struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        ZStack {
            // Background color
            Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Welcome to Weather App")
                    .bold()
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("Please share your current location to get precise weather information for your area")
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                // Custom location button
                // Replace the location button in WelcomeView with this:

                AnimatedButton(
                    title: "Share Location",
                    icon: "location.fill",
                    action: {
                        locationManager.requestLocation()
                    }
                )
                .padding(.top, 20)
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                        Text("Share Location")
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }


#Preview {
    WelcomeView()
        .environmentObject(LocationManager())
}
