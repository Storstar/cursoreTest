//
//  LanguageManager.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import Foundation
import SwiftUI

/// Менеджер для управления языком приложения
class LanguageManager: ObservableObject {
    // MARK: - Singleton
    
    static let shared = LanguageManager()
    
    // MARK: - Published Properties
    
    /// Текущий язык приложения
    @Published var currentLanguage: AppLanguage {
        didSet {
            saveLanguage()
        }
    }
    
    // MARK: - Thread Safety
    
    private let queue = DispatchQueue(label: "com.carassistant.languagemanager", attributes: .concurrent)
    
    // MARK: - Supported Languages
    
    enum AppLanguage: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case hindi = "hi"
        case french = "fr"
        case arabic = "ar"
        case russian = "ru"
        case portuguese = "pt"
        case indonesian = "id"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Español"
            case .hindi: return "हिन्दी"
            case .french: return "Français"
            case .arabic: return "العربية"
            case .russian: return "Русский"
            case .portuguese: return "Português"
            case .indonesian: return "Bahasa Indonesia"
            }
        }
        
        var nativeName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Español"
            case .hindi: return "हिन्दी"
            case .french: return "Français"
            case .arabic: return "العربية"
            case .russian: return "Русский"
            case .portuguese: return "Português"
            case .indonesian: return "Bahasa Indonesia"
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "LanguageManager.currentLanguage"
    private var localizationDictionary: [String: String] = [:]
    
    // MARK: - Initialization
    
    private init() {
        // Загружаем сохраненный язык или используем системный
        let initialLanguage: AppLanguage
        if let savedLanguageString = userDefaults.string(forKey: languageKey),
           let savedLanguage = AppLanguage(rawValue: savedLanguageString) {
            initialLanguage = savedLanguage
        } else {
            // Определяем язык системы
            let systemLanguage = Locale.preferredLanguages.first ?? "ru"
            if let systemLang = AppLanguage(rawValue: String(systemLanguage.prefix(2))) {
                initialLanguage = systemLang
            } else {
                initialLanguage = .russian // По умолчанию русский (как было в приложении)
            }
        }
        
        // Инициализируем синхронно для немедленного использования
        currentLanguage = initialLanguage
        let dictionary = getLocalizationDictionary(for: initialLanguage)
        queue.sync(flags: .barrier) {
            localizationDictionary = dictionary
        }
    }
    
    // MARK: - Public Methods
    
    /// Получить локализованную строку (thread-safe)
    func localizedString(for key: String) -> String {
        return queue.sync {
            return localizationDictionary[key] ?? key
        }
    }
    
    /// Установить язык
    func setLanguage(_ language: AppLanguage) {
        DispatchQueue.main.async { [weak self] in
            self?.currentLanguage = language
            self?.loadLocalizationDictionary()
        }
    }
    
    // MARK: - Private Methods
    
    /// Загрузить словарь локализации (thread-safe)
    private func loadLocalizationDictionary() {
        let language = currentLanguage
        let dictionary = getLocalizationDictionary(for: language)
        queue.async(flags: .barrier) { [weak self] in
            self?.localizationDictionary = dictionary
        }
    }
    
    /// Получить словарь локализации для языка
    private func getLocalizationDictionary(for language: AppLanguage) -> [String: String] {
        switch language {
        case .english:
            return LocalizationStrings.english
        case .spanish:
            return LocalizationStrings.spanish
        case .hindi:
            return LocalizationStrings.hindi
        case .french:
            return LocalizationStrings.french
        case .arabic:
            return LocalizationStrings.arabic
        case .russian:
            return LocalizationStrings.russian
        case .portuguese:
            return LocalizationStrings.portuguese
        case .indonesian:
            return LocalizationStrings.indonesian
        }
    }
    
    /// Сохранить текущий язык
    private func saveLanguage() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
        loadLocalizationDictionary()
    }
}

// MARK: - String Extension

extension String {
    /// Локализованная строка
    var localized: String {
        return LanguageManager.shared.localizedString(for: self)
    }
}

