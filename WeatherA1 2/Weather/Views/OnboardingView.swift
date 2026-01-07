//
//  OnboardingView.swift
//  Weather
//
//  Created by Akram El Gouri on 29/6/2025.
//

//
//  OnboardingView.swift
//  Weather
//
//  Onboarding flow for first-time users
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    OnboardingPage(
                        icon: "cloud.sun.rain.fill",
                        title: "Welcome to Weather",
                        description: "Get accurate weather forecasts for any location worldwide",
                        showButton: false
                    )
                    .tag(0)
                    
                    // Page 2: Features
                    OnboardingPage(
                        icon: "map.fill",
                        title: "Explore Weather Anywhere",
                        description: "Search locations, view forecasts, and save your favorite places",
                        showButton: false
                    )
                    .tag(1)
                    
                    // Page 3: Compass
                    OnboardingPage(
                        icon: "location.north.circle.fill",
                        title: "Wind & Compass",
                        description: "Track wind direction and speed with our integrated compass",
                        showButton: false
                    )
                    .tag(2)
                    
                    // Page 4: Location
                    OnboardingPage(
                        icon: "location.fill",
                        title: "Enable Location",
                        description: "Allow location access for weather at your current location",
                        showButton: true,
                        buttonAction: {
                            showOnboarding = false
                        }
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Skip button
                if currentPage < 3 {
                    HStack {
                        Button("Skip") {
                            showOnboarding = false
                        }
                        .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let showButton: Bool
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if showButton {
                Button(action: buttonAction ?? {}) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .padding(.top, 30)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}
