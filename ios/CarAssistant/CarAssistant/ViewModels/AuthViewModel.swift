import Foundation
import CoreData
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }
    
    init() {
        // Не проверяем аутентификацию при инициализации - это может блокировать UI
    }
    
    func register(username: String, email: String, password: String) {
        errorMessage = nil
        
        if let error = Validators.validateUsername(username) {
            errorMessage = error
            return
        }
        
        if let error = Validators.validateEmail(email) {
            errorMessage = error
            return
        }
        
        if let error = Validators.validatePassword(password) {
            errorMessage = error
            return
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                errorMessage = "Пользователь с таким email уже существует"
                return
            }
        } catch {
            errorMessage = "Ошибка проверки пользователя: \(error.localizedDescription)"
            return
        }
        
        let newUser = User(context: context)
        newUser.id = UUID()
        newUser.username = username
        newUser.email = email
        newUser.password = password
        
        CoreDataManager.shared.save()
        
        currentUser = newUser
        isAuthenticated = true
    }
    
    func login(email: String, password: String) {
        errorMessage = nil
        
        if let error = Validators.validateEmail(email) {
            errorMessage = error
            return
        }
        
        if let error = Validators.validatePassword(password) {
            errorMessage = error
            return
        }
        
        // Сначала проверяем, существует ли пользователь с таким email
        let emailFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        emailFetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let usersByEmail = try context.fetch(emailFetchRequest)
            
            if usersByEmail.isEmpty {
                // Если пользователя нет, создаем тестового пользователя для admin@admin.com
                if email == "admin@admin.com" && password == "admin1" {
                    CoreDataManager.shared.createTestUserIfNeeded()
                    // Небольшая задержка для сохранения
                    try? context.save()
                    // Повторно проверяем после создания
                    let retryUsers = try context.fetch(emailFetchRequest)
                    if let user = retryUsers.first, user.password == password {
                        context.refresh(user, mergeChanges: true)
                        currentUser = user
                        isAuthenticated = true
                        return
                    }
                }
                errorMessage = "Неверный email или пароль"
                return
            }
            
            // Проверяем пароль
            let passwordFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            passwordFetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)
            
            let users = try context.fetch(passwordFetchRequest)
            if let user = users.first {
                // Обновляем контекст, чтобы связи были видны
                context.refresh(user, mergeChanges: true)
                // Присваиваем пользователя - это автоматически обновит UI через @Published
                currentUser = user
                isAuthenticated = true
            } else {
                errorMessage = "Неверный email или пароль"
            }
        } catch {
            errorMessage = "Ошибка входа: \(error.localizedDescription)"
            print("Ошибка входа: \(error)")
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func checkAuthentication() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            print("Ошибка проверки аутентификации: \(error.localizedDescription)")
        }
    }
    
    // Асинхронная версия проверки аутентификации
    func checkAuthenticationAsync() async {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        await Task.detached { [weak self] in
            guard let self = self else { return }
            
            let backgroundContext = CoreDataManager.shared.persistentContainer.newBackgroundContext()
            
            do {
                let users = try backgroundContext.fetch(fetchRequest)
                if let user = users.first {
                    let userObjectID = user.objectID
                    
                    await MainActor.run {
                        let mainContext = CoreDataManager.shared.viewContext
                        if let mainUser = try? mainContext.existingObject(with: userObjectID) as? User {
                            self.currentUser = mainUser
                            self.isAuthenticated = true
                        }
                    }
                }
            } catch {
                print("Ошибка проверки аутентификации: \(error.localizedDescription)")
            }
        }.value
    }
}
