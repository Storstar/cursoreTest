import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @State private var navigationPath = NavigationPath()
    @State private var hasCheckedAuth = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if authViewModel.isAuthenticated {
                    if let user = authViewModel.currentUser {
                        MainView()
                    } else {
                        WelcomeView(navigationPath: $navigationPath)
                    }
                } else {
                    WelcomeView(navigationPath: $navigationPath)
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "login":
                    LoginView(navigationPath: $navigationPath)
                case "register":
                    RegisterView(navigationPath: $navigationPath)
                case "carInput":
                    CarInputView(navigationPath: $navigationPath)
                default:
                    EmptyView()
                }
            }
        }
        .task {
            // Проверяем аутентификацию только один раз при первом запуске (асинхронно)
            if !hasCheckedAuth {
                await authViewModel.checkAuthenticationAsync()
                if let user = authViewModel.currentUser {
                    await carViewModel.loadCarsAsync(for: user)
                }
                hasCheckedAuth = true
            }
        }
    }
}
