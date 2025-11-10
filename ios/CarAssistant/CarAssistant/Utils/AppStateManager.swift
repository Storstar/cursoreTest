//
//  AppStateManager.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import Foundation
import SwiftUI

/// Менеджер для сохранения и восстановления состояния приложения
@MainActor
class AppStateManager: ObservableObject {
    // MARK: - Singleton
    
    static let shared = AppStateManager()
    
    // MARK: - Published Properties
    
    /// Показывать ли список чатов (true) или активный чат (false)
    @Published var showChatHistory: Bool = false
    
    /// ID текущего открытого чата (если есть)
    @Published var currentChatId: UUID?
    
    /// Флаг холодного старта приложения
    @Published var isColdStart: Bool = true
    
    /// Флаг запуска через диплинк/пуш
    @Published var isDeepLinkLaunch: Bool = false
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let showChatHistoryKey = "AppStateManager.showChatHistory"
    private let currentChatIdKey = "AppStateManager.currentChatId"
    private let wasInBackgroundKey = "AppStateManager.wasInBackground"
    
    // MARK: - Initialization
    
    private init() {
        // При инициализации загружаем сохраненное состояние
        loadState()
        
        // Проверяем, было ли приложение в фоне перед запуском
        let wasInBackground = userDefaults.bool(forKey: wasInBackgroundKey)
        if wasInBackground {
            // Приложение было в фоне - это не холодный старт
            isColdStart = false
        } else {
            // Приложение не было в фоне - это холодный старт
            isColdStart = true
        }
    }
    
    // MARK: - Public Methods
    
    /// Сохранить состояние приложения
    func saveState(showChatHistory: Bool, currentChatId: UUID?) {
        self.showChatHistory = showChatHistory
        self.currentChatId = currentChatId
        
        userDefaults.set(showChatHistory, forKey: showChatHistoryKey)
        if let chatId = currentChatId {
            userDefaults.set(chatId.uuidString, forKey: currentChatIdKey)
        } else {
            userDefaults.removeObject(forKey: currentChatIdKey)
        }
    }
    
    /// Загрузить сохраненное состояние
    func loadState() {
        showChatHistory = userDefaults.bool(forKey: showChatHistoryKey)
        
        if let chatIdString = userDefaults.string(forKey: currentChatIdKey),
           let chatId = UUID(uuidString: chatIdString) {
            currentChatId = chatId
        } else {
            currentChatId = nil
        }
    }
    
    /// Очистить сохраненное состояние (для холодного старта)
    func clearState() {
        showChatHistory = false
        currentChatId = nil
        
        userDefaults.removeObject(forKey: showChatHistoryKey)
        userDefaults.removeObject(forKey: currentChatIdKey)
    }
    
    /// Отметить холодный старт (вызывается при запуске приложения)
    func markColdStart() {
        // Проверяем, было ли приложение в фоне перед запуском
        let wasInBackground = userDefaults.bool(forKey: wasInBackgroundKey)
        if wasInBackground {
            // Приложение было в фоне - это не холодный старт
            isColdStart = false
            // Сбрасываем флаг, так как приложение теперь активно
            userDefaults.set(false, forKey: wasInBackgroundKey)
        } else {
            // Приложение не было в фоне - это холодный старт
            isColdStart = true
            clearState()
        }
    }
    
    /// Отметить, что приложение ушло в фон
    func markEnteredBackground() {
        // Сохраняем флаг, что приложение было в фоне
        userDefaults.set(true, forKey: wasInBackgroundKey)
    }
    
    /// Отметить, что приложение запущено через диплинк/пуш
    func markDeepLinkLaunch() {
        isDeepLinkLaunch = true
        isColdStart = false
        // Сбрасываем флаг, так как приложение теперь активно
        userDefaults.set(false, forKey: wasInBackgroundKey)
    }
    
    /// Отметить, что приложение восстановлено из фона
    func markResumeFromBackground() {
        isColdStart = false
        isDeepLinkLaunch = false
        // Сбрасываем флаг, так как приложение теперь активно
        userDefaults.set(false, forKey: wasInBackgroundKey)
        loadState()
    }
}

