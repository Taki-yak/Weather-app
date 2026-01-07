import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @Binding var isLoggedIn: Bool // Connects to the main app state
    
    var body: some View {
        ZStack {
            // Background gradient matching your weather theme
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Weather App")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    // Logic for multiple users
                    let user1 = (username.lowercased() == "taki" && password == "2002")
                    let user2 = (username.lowercased() == "massi" && password == "massi1")
                    
                    if user1 || user2 {
                        withAnimation {
                            isLoggedIn = true
                        }
                    } else {
                        showAlert = true
                    }
                }) {
                    Text("Login")
                        .bold()
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Login Failed"),
                message: Text("Incorrect username or password."),
                dismissButton: .default(Text("Try Again"))
            )
        }
    }
}
