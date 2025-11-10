//
//  ChatViewModel.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import Foundation
import CoreData
import SwiftUI

// MARK: - ChatViewModel

/// ViewModel для управления чатами и сообщениями
@MainActor
class ChatViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Список всех чатов пользователя
    @Published var chats: [Chat] = []
    
    /// Текущий открытый чат
    @Published var currentChat: Chat?
    
    /// Сообщения текущего чата
    @Published var currentChatMessages: [ChatMessage] = []
    
    /// Флаг загрузки данных
    @Published var isLoading = false
    
    /// Сообщение об ошибке (если есть)
    @Published var errorMessage: String?
    
    /// Флаг ожидания ответа от ИИ
    @Published var isWaitingForResponse = false
    
    /// Флаг загрузки истории сообщений
    @Published var isLoadingHistory = false
    
    /// Флаг, загружены ли все сообщения
    @Published var hasLoadedAllMessages = false
    
    // MARK: - Private Properties
    
    /// Фразы для отображения во время загрузки ответа
    private let loadingPhrases = [
        "Анализируем запрос…",
        "Ищу решение…",
        "Изучаю проблему…",
        "Подбираю ответ…",
        "Генерирую подсказку…",
        "Думаю над вашим вопросом…",
        "Собираю информацию…"
    ]
    
    /// Core Data контекст
    private var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }
    
    /// Кэш для оптимизации загрузки чатов
    private var lastLoadedUserId: UUID?
    private var lastLoadTime: Date?
    private let cacheTimeout: TimeInterval = 5.0
    
    /// Количество сообщений, загружаемых при первом открытии чата
    private let initialMessagesCount = 20
    
    /// Количество сообщений, загружаемых при подгрузке истории
    private let historyBatchSize = 20
    
    /// Все сообщения текущего чата (для ленивой загрузки)
    private var allChatMessages: [ChatMessage] = []
    
    // MARK: - Public Methods
    
    /// Инвалидировать кэш (принудительно перезагрузить чаты)
    func invalidateCache() {
        lastLoadedUserId = nil
        lastLoadTime = nil
    }
    
    /// Обновить сообщение в текущем чате
    /// - Parameter updatedMessage: Обновленное сообщение
    func updateMessage(_ updatedMessage: ChatMessage) {
        if let index = currentChatMessages.firstIndex(where: { $0.id == updatedMessage.id }) {
            currentChatMessages[index] = updatedMessage
        }
    }
    
    /// Загрузить все чаты пользователя
    /// - Parameters:
    ///   - user: Пользователь
    ///   - car: Автомобиль (опционально, для фильтрации)
    func loadChats(for user: User, car: Car? = nil) {
        // Проверка кэша
        if let lastUserId = lastLoadedUserId,
           let lastTime = lastLoadTime,
           lastUserId == user.id,
           Date().timeIntervalSince(lastTime) < cacheTimeout,
           !chats.isEmpty {
            if let car = car {
                let currentChatsCarId = chats.first?.requests.first?.car?.id
                if currentChatsCarId == car.id {
                    return // Используем кэшированные данные
                }
            } else {
                return // Используем кэшированные данные
            }
        }
        
        let fetchRequest: NSFetchRequest<Request> = Request.fetchRequest()
        
        // Фильтрация по пользователю и автомобилю
        if let car = car {
            fetchRequest.predicate = NSPredicate(format: "user == %@ AND car == %@", user, car)
        } else {
            fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Request.createdAt, ascending: false)]
        fetchRequest.fetchBatchSize = 20
        
        do {
            let requests = try context.fetch(fetchRequest)
            
            // Группировка запросов по chatId
            var chatDict: [UUID: [Request]] = [:]
            
            for request in requests {
                let chatId = request.chatId ?? request.id
                
                if chatDict[chatId] == nil {
                    chatDict[chatId] = []
                }
                chatDict[chatId]?.append(request)
            }
            
            // Создание Chat объектов из сгруппированных запросов
            chats = chatDict.map { chatId, requests in
                let sortedRequests = requests.sorted { $0.createdAt < $1.createdAt }
                let firstRequest = sortedRequests.first
                let lastRequest = sortedRequests.last
                
                let title = firstRequest?.text?.prefix(50) ?? "Новый чат"
                let lastMessage: String? = {
                    if let response = lastRequest?.response {
                        return String(response.text.prefix(50))
                    } else if let text = lastRequest?.text {
                        return String(text.prefix(50))
                    }
                    return nil
                }()
                
                return Chat(
                    id: chatId,
                    title: String(title),
                    lastMessage: lastMessage,
                    lastMessageDate: lastRequest?.createdAt ?? Date(),
                    requests: sortedRequests
                )
            }.sorted { $0.lastMessageDate > $1.lastMessageDate }
            
            // Обновление кэша
            lastLoadedUserId = user.id
            lastLoadTime = Date()
            
        } catch {
            errorMessage = "Ошибка загрузки чатов: \(error.localizedDescription)"
        }
    }
    
    /// Открыть чат
    /// - Parameter chat: Чат для открытия
    func openChat(_ chat: Chat) {
        currentChat = chat
        loadMessages(for: chat)
    }
    
    /// Загрузить сообщения для чата (ленивая загрузка - только последние N сообщений)
    /// - Parameter chat: Чат, для которого нужно загрузить сообщения
    func loadMessages(for chat: Chat) {
        var messages: [ChatMessage] = []
        messages.reserveCapacity(chat.requests.count * 2)
        
        for request in chat.requests {
            // Сообщение пользователя
            if let text = request.text {
                messages.append(ChatMessage(
                    text: text,
                    imageData: request.imageData,
                    isFromUser: true,
                    timestamp: request.createdAt
                ))
            } else if request.imageData != nil {
                messages.append(ChatMessage(
                    text: nil,
                    imageData: request.imageData,
                    isFromUser: true,
                    timestamp: request.createdAt
                ))
            }
            
            // Ответ ИИ
            if let response = request.response {
                messages.append(ChatMessage(
                    text: response.text,
                    isFromUser: false,
                    timestamp: response.createdAt
                ))
            } else {
                // Индикатор загрузки, если ответ еще не получен
                messages.append(ChatMessage(
                    text: nil,
                    isFromUser: false,
                    timestamp: request.createdAt,
                    isLoading: true,
                    loadingText: getRandomLoadingPhrase()
                ))
            }
        }
        
        // Сохраняем все сообщения для ленивой загрузки
        allChatMessages = messages.sorted { $0.timestamp < $1.timestamp }
        
        // Загружаем только последние N сообщений для оптимизации
        let sortedMessages = allChatMessages
        if sortedMessages.count <= initialMessagesCount {
            // Если сообщений меньше или равно лимиту, загружаем все
            currentChatMessages = sortedMessages
            hasLoadedAllMessages = true
        } else {
            // Загружаем только последние N сообщений
            currentChatMessages = Array(sortedMessages.suffix(initialMessagesCount))
            hasLoadedAllMessages = false
        }
    }
    
    /// Загрузить больше сообщений из истории (при скролле вверх)
    func loadMoreMessages() {
        // Если уже загружены все сообщения или идет загрузка, ничего не делаем
        guard !hasLoadedAllMessages && !isLoadingHistory else { return }
        
        // Если все сообщения уже загружены
        if currentChatMessages.count >= allChatMessages.count {
            hasLoadedAllMessages = true
            return
        }
        
        isLoadingHistory = true
        
        // Находим индекс первого текущего сообщения в полном списке
        guard let firstMessage = currentChatMessages.first,
              let firstIndex = allChatMessages.firstIndex(where: { $0.id == firstMessage.id }) else {
            isLoadingHistory = false
            return
        }
        
        // Вычисляем, сколько сообщений нужно загрузить
        let startIndex = max(0, firstIndex - historyBatchSize)
        let endIndex = firstIndex
        
        // Загружаем предыдущие сообщения
        let newMessages = Array(allChatMessages[startIndex..<endIndex])
        
        // Добавляем их в начало списка
        currentChatMessages = newMessages + currentChatMessages
        
        // Проверяем, загружены ли все сообщения
        if startIndex == 0 {
            hasLoadedAllMessages = true
        }
        
        isLoadingHistory = false
    }
    
    /// Создать новый чат
    /// - Parameter title: Заголовок чата (опционально)
    /// - Returns: Созданный чат
    func createNewChat(title: String? = nil) -> Chat {
        let newChat = Chat(
            id: UUID(),
            title: title ?? "Новый чат",
            lastMessageDate: Date()
        )
        chats.insert(newChat, at: 0)
        currentChat = newChat
        currentChatMessages = []
        return newChat
    }
    
    /// Отправить сообщение в текущий чат
    /// - Parameters:
    ///   - text: Текст сообщения (опционально)
    ///   - imageData: Данные изображения (опционально)
    ///   - requestViewModel: ViewModel для создания запроса
    ///   - user: Пользователь
    ///   - car: Автомобиль (опционально)
    func sendMessage(
        text: String?,
        imageData: Data?,
        requestViewModel: RequestViewModel,
        for user: User,
        car: Car?
    ) async {
        isLoading = true
        errorMessage = nil
        
        let chatId: UUID? = currentChat?.id
        
        // Добавление сообщения пользователя и индикатора загрузки
        if let text = text, !text.isEmpty {
            let userMessage = ChatMessage(
                text: text,
                isFromUser: true,
                timestamp: Date()
            )
            currentChatMessages.append(userMessage)
            
            let loadingMessage = ChatMessage(
                text: nil,
                isFromUser: false,
                timestamp: Date(),
                isLoading: true,
                loadingText: getRandomLoadingPhrase()
            )
            currentChatMessages.append(loadingMessage)
        } else if let imageData = imageData {
            let userMessage = ChatMessage(
                imageData: imageData,
                isFromUser: true,
                timestamp: Date()
            )
            currentChatMessages.append(userMessage)
            
            let loadingMessage = ChatMessage(
                text: nil,
                isFromUser: false,
                timestamp: Date(),
                isLoading: true,
                loadingText: getRandomLoadingPhrase()
            )
            currentChatMessages.append(loadingMessage)
        }
        
        // Построение истории чата для контекста ИИ
        let chatHistory = buildChatHistory()
        
        // Создание запроса через RequestViewModel
        if let imageData = imageData {
            await requestViewModel.createPhotoRequest(
                imageData: imageData,
                for: user,
                car: car,
                chatId: chatId,
                chatHistory: chatHistory
            )
        } else if let text = text, !text.isEmpty {
            await requestViewModel.createTextRequest(
                text: text,
                for: user,
                car: car,
                chatId: chatId,
                chatHistory: chatHistory
            )
        }
        
        // Ожидание ответа от ИИ - упрощенная логика
        isWaitingForResponse = true
        let savedChatId = chatId ?? currentChat?.id
        
        // Ждем немного перед первой проверкой
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
        
        // Обновляем чаты и сообщения
        invalidateCache()
        loadChats(for: user, car: car)
        
        // Проверяем наличие ответа
        if let savedChatId = savedChatId,
           let updatedChat = chats.first(where: { $0.id == savedChatId }) {
            currentChat = updatedChat
            loadMessages(for: updatedChat)
            
            // Проверяем, есть ли ответ
            if let lastRequest = updatedChat.requests.last,
               let response = lastRequest.response,
               !response.text.isEmpty {
                replaceLoadingIndicator(with: response.text)
                isWaitingForResponse = false
                isLoading = false
                return
            }
        } else if let firstChat = chats.first {
            currentChat = firstChat
            loadMessages(for: firstChat)
            
            // Проверяем, есть ли ответ в первом чате
            if let lastRequest = firstChat.requests.last,
               let response = lastRequest.response,
               !response.text.isEmpty {
                replaceLoadingIndicator(with: response.text)
                isWaitingForResponse = false
                isLoading = false
                return
            }
        }
        
        // Если ответа нет, ждем и проверяем еще раз
        var attempts = 0
        let maxAttempts = 40
        let checkInterval: UInt64 = 500_000_000 // 0.5 секунды
        
        while isWaitingForResponse && attempts < maxAttempts {
            try? await Task.sleep(nanoseconds: checkInterval)
            
            // Обновляем чаты и сообщения
            invalidateCache()
            loadChats(for: user, car: car)
            
            // Проверяем наличие ответа
            if let savedChatId = savedChatId,
               let updatedChat = chats.first(where: { $0.id == savedChatId }) {
                currentChat = updatedChat
                loadMessages(for: updatedChat)
                
                // Проверяем, есть ли ответ
                if let lastRequest = updatedChat.requests.last,
                   let response = lastRequest.response,
                   !response.text.isEmpty {
                    replaceLoadingIndicator(with: response.text)
                    isWaitingForResponse = false
                    isLoading = false
                    return
                }
            } else if let firstChat = chats.first {
                currentChat = firstChat
                loadMessages(for: firstChat)
                
                // Проверяем, есть ли ответ в первом чате
                if let lastRequest = firstChat.requests.last,
                   let response = lastRequest.response,
                   !response.text.isEmpty {
                    replaceLoadingIndicator(with: response.text)
                    isWaitingForResponse = false
                    isLoading = false
                    return
                }
            }
            
            // Проверяем ошибку
            if let error = requestViewModel.errorMessage, !error.isEmpty {
                replaceLoadingIndicator(with: "Ошибка: \(error)")
                errorMessage = error
                isWaitingForResponse = false
                isLoading = false
                return
            }
            
            attempts += 1
        }
        
        // Финальное обновление после таймаута
        isWaitingForResponse = false
        invalidateCache()
        loadChats(for: user, car: car)
        
        if let savedChatId = savedChatId,
           let updatedChat = chats.first(where: { $0.id == savedChatId }) {
            currentChat = updatedChat
            loadMessages(for: updatedChat)
            
            // Проверяем, есть ли ответ
            if let lastRequest = updatedChat.requests.last,
               let response = lastRequest.response,
               !response.text.isEmpty {
                replaceLoadingIndicator(with: response.text)
            } else {
                replaceLoadingIndicator(with: "Не удалось получить ответ. Попробуйте позже.")
            }
        } else if let firstChat = chats.first {
            currentChat = firstChat
            loadMessages(for: firstChat)
        }
        
        if let error = requestViewModel.errorMessage {
            errorMessage = error
        }
        
        isLoading = false
    }
    
    /// Удалить чат
    /// - Parameters:
    ///   - chat: Чат для удаления
    ///   - user: Пользователь
    ///   - car: Автомобиль (опционально)
    func deleteChat(_ chat: Chat, for user: User, car: Car?) {
        // Удаление всех запросов и ответов из Core Data
        for request in chat.requests {
            if let response = request.response {
                context.delete(response)
            }
            context.delete(request)
        }
        
        CoreDataManager.shared.save()
        
        // Удаление чата из списка
        chats.removeAll { $0.id == chat.id }
        
        // Очистка текущего чата, если он был удален
        if currentChat?.id == chat.id {
            currentChat = nil
            currentChatMessages = []
        }
        
        // Перезагрузка чатов
        loadChats(for: user, car: car)
    }
    
    // MARK: - Private Methods
    
    /// Получить случайную фразу для статуса загрузки
    /// - Returns: Случайная фраза
    private func getRandomLoadingPhrase() -> String {
        return loadingPhrases.randomElement() ?? "Ищу решение…"
    }
    
    /// Построить историю чата для передачи в ИИ
    /// - Returns: Массив кортежей (роль, содержимое)
    private func buildChatHistory() -> [(role: String, content: String)] {
        var history: [(role: String, content: String)] = []
        
        // Пропускаем последние два сообщения (новое сообщение пользователя и индикатор загрузки)
        let messagesToProcess = currentChatMessages.dropLast(2)
        
        for message in messagesToProcess {
            if message.isLoading {
                continue
            }
            
            if message.isFromUser {
                if let text = message.text, !text.isEmpty {
                    history.append((role: "user", content: text))
                } else if message.imageData != nil {
                    history.append((role: "user", content: "[Изображение]"))
                }
            } else {
                if let text = message.text, !text.isEmpty {
                    history.append((role: "assistant", content: text))
                }
            }
        }
        
        return history
    }
    
    /// Заменить индикатор загрузки на реальный ответ
    /// - Parameter text: Текст ответа
    private func replaceLoadingIndicator(with text: String) {
        if let lastIndex = currentChatMessages.lastIndex(where: { $0.isLoading }) {
            currentChatMessages[lastIndex] = ChatMessage(
                text: text,
                isFromUser: false,
                timestamp: Date()
            )
        }
    }
}
