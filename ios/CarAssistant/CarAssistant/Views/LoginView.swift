import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @Binding var navigationPath: NavigationPath
    
    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String?
    @State private var passwordError: String?
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                if let error = emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                SecureField("Пароль", text: $password)
                    .textContentType(.password)
                
                if let error = passwordError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            if let error = authViewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button(action: {
                    emailError = Validators.validateEmail(email)
                    passwordError = Validators.validatePassword(password)
                    
                    if emailError == nil && passwordError == nil {
                        authViewModel.login(email: email, password: password)
                        // Закрываем экран входа после успешного входа
                        if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                            // Загружаем машину пользователя
                            carViewModel.loadCar(for: user)
                            // Очищаем навигацию для возврата на главный экран
                            navigationPath = NavigationPath()
                        }
                    }
                }) {
                    Text("Войти")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Вход")
    }
}
