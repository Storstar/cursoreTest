//
//  ChatData.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import Foundation

// MARK: - Chat Model

/// Модель чата, группирующая запросы и ответы в единый диалог
struct Chat: Identifiable {
    /// Уникальный идентификатор чата
    let id: UUID
    
    /// Краткое описание проблемы/темы чата
    var title: String
    
    /// Последнее сообщение для превью в списке чатов
    var lastMessage: String?
    
    /// Дата последнего сообщения
    var lastMessageDate: Date
    
    /// Все запросы в этом чате
    var requests: [Request]
    
    /// Тема чата (проблема, выбранная пользователем)
    var topic: Topic?
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        title: String,
        lastMessage: String? = nil,
        lastMessageDate: Date = Date(),
        requests: [Request] = [],
        topic: Topic? = nil
    ) {
        self.id = id
        self.title = title
        self.lastMessage = lastMessage
        self.lastMessageDate = lastMessageDate
        self.requests = requests
        self.topic = topic
    }
}

// MARK: - ChatMessage Model

/// Модель сообщения в чате
struct ChatMessage: Identifiable, Equatable {
    /// Уникальный идентификатор сообщения
    let id: UUID
    
    /// Текст сообщения
    let text: String?
    
    /// Данные изображения (если есть) - используется только для новых сообщений
    /// Для старых сообщений используется lazy loading через requestId
    let imageData: Data?
    
    /// ID Request для lazy loading imageData (предотвращает утечки памяти)
    let requestId: UUID?
    
    /// Флаг: сообщение от пользователя или от ИИ
    let isFromUser: Bool
    
    /// Временная метка сообщения
    let timestamp: Date
    
    /// Флаг: сообщение в процессе загрузки
    let isLoading: Bool
    
    /// Текст для отображения во время загрузки
    let loadingText: String?
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        text: String? = nil,
        imageData: Data? = nil,
        requestId: UUID? = nil,
        isFromUser: Bool,
        timestamp: Date = Date(),
        isLoading: Bool = false,
        loadingText: String? = nil
    ) {
        self.id = id
        self.text = text
        self.imageData = imageData
        self.requestId = requestId
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.isLoading = isLoading
        self.loadingText = loadingText
    }
    
    // MARK: - Equatable
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id &&
               lhs.text == rhs.text &&
               lhs.imageData == rhs.imageData &&
               lhs.requestId == rhs.requestId &&
               lhs.isFromUser == rhs.isFromUser &&
               lhs.timestamp == rhs.timestamp &&
               lhs.isLoading == rhs.isLoading &&
               lhs.loadingText == rhs.loadingText
    }
}
