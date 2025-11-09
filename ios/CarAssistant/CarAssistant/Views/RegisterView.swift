import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var navigationPath: NavigationPath
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var usernameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    
    var body: some View {
        Form {
            Section {
                TextField("Имя пользователя", text: $username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                
                if let error = usernameError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
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
                    .textContentType(.newPassword)
                
                if let error = passwordError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                SecureField("Подтвердите пароль", text: $confirmPassword)
                    .textContentType(.newPassword)
                
                if let error = confirmPasswordError {
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
                    usernameError = Validators.validateUsername(username)
                    emailError = Validators.validateEmail(email)
                    passwordError = Validators.validatePassword(password)
                    
                    if password != confirmPassword {
                        confirmPasswordError = "Пароли не совпадают"
                    } else {
                        confirmPasswordError = nil
                    }
                    
                    if usernameError == nil && emailError == nil && passwordError == nil && confirmPasswordError == nil {
                        authViewModel.register(username: username, email: email, password: password)
                        // ContentView автоматически переключится на нужный экран
                    }
                }) {
                    Text("Зарегистрироваться")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Регистрация")
    }
}
