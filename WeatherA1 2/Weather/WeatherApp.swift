import SwiftUI

@main
struct WeatherApp: App {
    // AppStorage saves the login state to the device memory
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                // If logged in, show the main weather dashboard
                ContentView()
                    .transition(.opacity) // Smooth transition into the app
            } else {
                // Otherwise, show the login screen
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}
