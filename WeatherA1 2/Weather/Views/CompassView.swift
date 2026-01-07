//
//  CompassView.swift
//  Weather
//

import SwiftUI

struct CompassView: View {
    @StateObject private var compassManager = CompassManager()
    let windDirection: Double
    let windSpeed: Double
    
    init(windDirection: Double = 0, windSpeed: Double = 0) {
        self.windDirection = windDirection
        self.windSpeed = windSpeed
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0/255, green: 0/255, blue: 139/255) // Navy blue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Compass")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                Text("\(Int(round(compassManager.heading)))°")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                // Compass circle
                ZStack {
                    // Outer circle
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 280, height: 280)
                    
                    // Cardinal and intercardinal points
                    ForEach(["N", "NE", "E", "SE", "S", "SW", "W", "NW"], id: \.self) { direction in
                        let angle = getAngle(for: direction)
                        Text(direction)
                            .foregroundColor(.white)
                            .font(.system(size: direction.count == 1 ? 20 : 16))
                            .offset(y: -120)
                            .rotationEffect(.degrees(angle))
                    }
                    
                    // North triangle (red)
                    Triangle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .offset(y: -120)
                        .rotationEffect(.degrees(-compassManager.heading))
                    
                    // Center dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    
                    // North-South arrow (red)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2, height: 200)
                        .rotationEffect(.degrees(-compassManager.heading))
                    
                    // Wind direction arrow (blue)
                    if windSpeed > 0 {
                        WindArrow()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                            .offset(y: -120)
                            .rotationEffect(.degrees(windDirection - compassManager.heading))
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 2, height: 200)
                            .rotationEffect(.degrees(windDirection - compassManager.heading))
                    }
                }
                .frame(width: 280, height: 280)
                
                if windSpeed > 0 {
                    VStack(spacing: 5) {
                        Text("Wind Direction: \(Int(windDirection))°")
                            .foregroundColor(.white)
                        Text("Wind Speed: \(String(format: "%.1f", windSpeed)) m/s")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            compassManager.startUpdatingHeading()
        }
        .onDisappear {
            compassManager.stopUpdatingHeading()
        }
    }
    
    private func getAngle(for direction: String) -> Double {
        switch direction {
        case "N": return 0
        case "NE": return 45
        case "E": return 90
        case "SE": return 135
        case "S": return 180
        case "SW": return 225
        case "W": return 270
        case "NW": return 315
        default: return 0
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct WindArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView(windDirection: 45, windSpeed: 5.5)
    }
}
