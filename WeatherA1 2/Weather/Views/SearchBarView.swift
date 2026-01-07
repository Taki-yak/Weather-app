//
//  SearchBarView.swift
//  Weather
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    let isSearching: Bool
    let onSubmit: () -> Void
    @State private var isFocused = false
    @State private var showClearButton = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                        .scaleEffect(isFocused ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: isFocused)
                    
                    TextField("Search location...", text: $searchText, onEditingChanged: { editing in
                        withAnimation(.spring(response: 0.3)) {
                            isFocused = editing
                        }
                        if editing {
                            HapticManager.shared.impact(style: .light)
                        }
                    })
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit {
                        onSubmit()
                        HapticManager.shared.impact(style: .medium)
                    }
                    .onChange(of: searchText) { newValue in
                        withAnimation(.spring(response: 0.3)) {
                            showClearButton = !newValue.isEmpty
                        }
                    }
                    
                    if showClearButton {
                        Button(action: {
                            searchText = ""
                            HapticManager.shared.impact(style: .light)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 16))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(isFocused ? 0.3 : 0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(isFocused ? 0.5 : 0), lineWidth: 2)
                )
                .animation(.spring(response: 0.3), value: isFocused)
                
                if isFocused && !searchText.isEmpty {
                    Button(action: {
                        onSubmit()
                        isFocused = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                      to: nil, from: nil, for: nil)
                        HapticManager.shared.notification(type: .success)
                    }) {
                        Text("Search")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if isSearching {
                HStack {
                    RefreshIndicator()
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: showClearButton)
        .animation(.spring(response: 0.3), value: isSearching)
    }
}

// Preview
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(hue: 0.63, saturation: 1.0, brightness: 0.49)
                .ignoresSafeArea()
            
            SearchBarView(
                searchText: .constant(""),
                isSearching: false,
                onSubmit: {}
            )
        }
    }
}
