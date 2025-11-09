import Foundation
import SwiftUI
import Combine

struct Validators {
    static func validateEmail(_ email: String) -> String? {
        if email.isEmpty {
            return "Email не может быть пустым"
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: email) {
            return "Некорректный формат email"
        }
        
        return nil
    }
    
    static func validatePassword(_ password: String) -> String? {
        if password.isEmpty {
            return "Пароль не может быть пустым"
        }
        
        if password.count < 6 {
            return "Пароль должен содержать минимум 6 символов"
        }
        
        return nil
    }
    
    static func validateUsername(_ username: String) -> String? {
        if username.isEmpty {
            return "Имя пользователя не может быть пустым"
        }
        
        if username.count < 3 {
            return "Имя пользователя должно содержать минимум 3 символа"
        }
        
        return nil
    }
    
    static func validateBrand(_ brand: String) -> String? {
        if brand.isEmpty {
            return "Марка не может быть пустой"
        }
        return nil
    }
    
    static func validateModel(_ model: String) -> String? {
        if model.isEmpty {
            return "Модель не может быть пустой"
        }
        return nil
    }
    
    static func validateYear(_ year: Int16) -> String? {
        let currentYear = Int16(Calendar.current.component(.year, from: Date()))
        if year < 1900 || year > currentYear {
            return "Год должен быть от 1900 до \(currentYear)"
        }
        return nil
    }
    
    static func validateEngine(_ engine: String) -> String? {
        if engine.isEmpty {
            return "Двигатель не может быть пустым"
        }
        return nil
    }
    
    static func validateRequestText(_ text: String) -> String? {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Текст запроса не может быть пустым"
        }
        return nil
    }
}
