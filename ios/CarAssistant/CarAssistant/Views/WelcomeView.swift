import SwiftUI

struct WelcomeView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("CarAssistant")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Ваш помощник по автомобилям")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    navigationPath.append("login")
                }) {
                    Text("Вход")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    navigationPath.append("register")
                }) {
                    Text("Регистрация")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
