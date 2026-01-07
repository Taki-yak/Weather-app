//
//  FavouritesView.swift
//  Weather
//

import SwiftUI

struct FavouritesView: View {
    @StateObject private var viewModel = FavouritesViewModel()
    @State private var showingAddLocation = false
    @State private var selectedLocation: SavedLocation?
    @State private var showTutorialAlert = false
    let weatherManager = WeatherManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        Text("Favourites")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            HapticManager.shared.impact(style: .light)
                            showingAddLocation = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .scaleEffect(showingAddLocation ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: showingAddLocation)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    
                    if viewModel.savedLocations.isEmpty {
                        // Empty State
                        EmptyFavouritesView()
                    } else {
                        // Cities Grid
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ForEach(viewModel.savedLocations) { location in
                                    CityCard(location: location) {
                                        selectedLocation = location
                                    } onDelete: {
                                        withAnimation(.spring()) {
                                            viewModel.removeLocation(location)
                                        }
                                    }
                                }
                            }
                            .padding()
                            
                            // Help Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Help")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                
                                Button(action: {
                                    HapticManager.shared.impact(style: .light)
                                    showTutorialAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "questionmark.circle")
                                            .font(.title3)
                                        Text("View Tutorial Again")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView(viewModel: viewModel)
            }
            .sheet(item: $selectedLocation) { location in
                NavigationView {
                    LocationWeatherView(
                        location: location,
                        weatherManager: weatherManager
                    )
                }
            }
            .alert("View Tutorial", isPresented: $showTutorialAlert) {
                Button("Cancel", role: .cancel) { }
                Button("View") {
                    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                    HapticManager.shared.notification(type: .success)
                }
            } message: {
                Text("The tutorial will be shown when you restart the app.")
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyFavouritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "star.slash")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No Favourite Locations")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Text("Tap the + button to add your first location")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - City Card
struct CityCard: View {
    let location: SavedLocation
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var isPressed = false
    @State private var showDeleteConfirm = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            onTap()
        }) {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Content
                VStack {
                    // Delete button
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.shared.impact(style: .medium)
                            showDeleteConfirm = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .scaleEffect(showDeleteConfirm ? 1.2 : 1.0)
                                .animation(.spring(), value: showDeleteConfirm)
                        }
                    }
                    
                    Spacer()
                    
                    // City Name
                    Text(location.name)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // View Weather Text with icon
                    HStack(spacing: 4) {
                        Image(systemName: "cloud.sun.fill")
                            .font(.caption)
                        Text("View Weather")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 10)
                }
            }
            .frame(height: 140)
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: { }
        )
        .confirmationDialog("Delete \(location.name)?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                withAnimation(.spring()) {
                    HapticManager.shared.notification(type: .warning)
                    onDelete()
                }
            }
        }
    }
}

// MARK: - Add Location View
struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FavouritesViewModel
    @State private var searchText = ""
    @State private var showSuccess = false
    @State private var selectedResult: LocationSearchResult?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBarView(
                        searchText: $searchText,
                        isSearching: viewModel.isSearching
                    ) {
                        viewModel.performSearch(searchText)
                    }
                    .padding(.top)
                    
                    // Content
                    if viewModel.isSearching {
                        // Loading State
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Searching...")
                                .foregroundColor(.white)
                                .padding(.top)
                            Spacer()
                        }
                    } else if let searchResults = viewModel.searchResults, !searchResults.isEmpty {
                        // Search Results
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(searchResults, id: \.name) { result in
                                    SearchResultRow(
                                        result: result,
                                        isSelected: selectedResult?.name == result.name,
                                        showSuccess: showSuccess && selectedResult?.name == result.name
                                    ) {
                                        selectedResult = result
                                        HapticManager.shared.notification(type: .success)
                                        viewModel.addLocation(
                                            name: result.name,
                                            latitude: result.latitude,
                                            longitude: result.longitude
                                        )
                                        
                                        // Show success feedback
                                        withAnimation {
                                            showSuccess = true
                                        }
                                        
                                        // Dismiss after delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                            dismiss()
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    } else if viewModel.searchResults?.isEmpty == true {
                        // No Results
                        VStack {
                            Spacer()
                            Image(systemName: "magnifyingglass.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            Text("No locations found")
                                .font(.title3)
                                .foregroundColor(.white)
                            Text("Try searching for a different location")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 5)
                            Spacer()
                        }
                    } else {
                        // Initial State
                        VStack {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            Text("Search for a location")
                                .font(.title3)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Add City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticManager.shared.impact(style: .light)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let result: LocationSearchResult
    let isSelected: Bool
    let showSuccess: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let country = result.country {
                        Text(country)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                if showSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.white.opacity(isSelected ? 0.2 : 0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(isSelected ? 0.3 : 0), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 0.98 : 1.0)
        }
        .animation(.spring(response: 0.3), value: isSelected)
        .animation(.spring(response: 0.3), value: showSuccess)
    }
}

// Update LocationSearchResult to include country
extension LocationSearchResult {
    var country: String? {
        // This would be populated from the geocoding results
        return nil
    }
}

// MARK: - Previews
struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesView()
    }
}
