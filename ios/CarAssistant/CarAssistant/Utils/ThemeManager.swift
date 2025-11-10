//
//  ThemeManager.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI

/// Менеджер для управления темой приложения
@MainActor
class ThemeManager: ObservableObject {
    // MARK: - Singleton
    
    static let shared = ThemeManager()
    
    // MARK: - Published Properties
    
    /// Текущая тема приложения
    @Published var colorScheme: ColorScheme? {
        didSet {
            saveTheme()
        }
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "ThemeManager.colorScheme"
    
    // MARK: - Initialization
    
    private init() {
        loadTheme()
    }
    
    // MARK: - Public Methods
    
    /// Переключить тему
    func toggleTheme() {
        if colorScheme == .dark {
            colorScheme = .light
        } else {
            colorScheme = .dark
        }
    }
    
    /// Установить светлую тему
    func setLightTheme() {
        colorScheme = .light
    }
    
    /// Установить темную тему
    func setDarkTheme() {
        colorScheme = .dark
    }
    
    /// Установить системную тему
    func setSystemTheme() {
        colorScheme = nil
    }
    
    // MARK: - Private Methods
    
    /// Загрузить сохраненную тему
    private func loadTheme() {
        if let themeString = userDefaults.string(forKey: themeKey) {
            switch themeString {
            case "light":
                colorScheme = .light
            case "dark":
                colorScheme = .dark
            default:
                colorScheme = .light // По умолчанию светлая тема
            }
        } else {
            colorScheme = .light // По умолчанию светлая тема
        }
    }
    
    /// Сохранить текущую тему
    private func saveTheme() {
        if let scheme = colorScheme {
            switch scheme {
            case .light:
                userDefaults.set("light", forKey: themeKey)
            case .dark:
                userDefaults.set("dark", forKey: themeKey)
            @unknown default:
                userDefaults.set("system", forKey: themeKey)
            }
        } else {
            userDefaults.set("system", forKey: themeKey)
        }
    }
}

