//
//  FeedbackComponents.swift
//  Weather
//
//  Created by Akram El Gouri on 29/6/2025.
//

import Foundation
//
//  FeedbackComponents.swift
//  Weather
//
//  Visual and haptic feedback components
//

import SwiftUI

// MARK: - Haptic Feedback Manager
class HapticManager {
    static let shared = HapticManager()
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

// MARK: - Loading Button
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isLoading {
                action()
                HapticManager.shared.impact(style: .medium)
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                }
            }
            .frame(minWidth: 120, minHeight: 44)
            .padding(.horizontal, 20)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(22)
            .opacity(isLoading ? 0.7 : 1.0)
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Animated Button
struct AnimatedButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            action()
        }) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)
            .foregroundColor(Color(hue: 0.63, saturation: 1.0, brightness: 0.49))
            .cornerRadius(25)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: { }
        )
    }
}

// MARK: - Success Animation View
struct SuccessAnimationView: View {
    @State private var show = false
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green, lineWidth: 4)
                .frame(width: 80, height: 80)
                .scaleEffect(scale)
                .opacity(show ? 0 : 1)
            
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.green)
                .scaleEffect(show ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                show = true
                scale = 1.5
            }
            
            HapticManager.shared.notification(type: .success)
        }
    }
}

// MARK: - Interactive Tab Item
struct InteractiveTabItem: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            .onChange(of: isSelected) { newValue in
                if newValue {
                    HapticManager.shared.impact(style: .light)
                }
            }
    }
}

// MARK: - Refresh Indicator
struct RefreshIndicator: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "arrow.clockwise")
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}
