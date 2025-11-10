//
//  AIService.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import Foundation

// MARK: - AIService

/// Сервис для работы с OpenRouter.ai API
class AIService {
    // MARK: - Singleton
    
    static let shared = AIService()
    
    // MARK: - Constants
    
    /// OpenRouter API endpoint
    private let apiURL = "https://openrouter.ai/api/v1/chat/completions"
    
    /// Модель через OpenRouter (GPT-4o с поддержкой vision)
    /// Правильный формат для OpenRouter: "openai/gpt-4o"
    /// GPT-4o поддерживает анализ изображений и является самой продвинутой моделью OpenAI
    private let model = "openai/gpt-4o"
    
    // MARK: - Configuration
    
    /// API ключ OpenRouter
    private var apiKey: String {
        // Сначала пытаемся получить из Info.plist
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let key = plist["OpenRouterAPIKey"] as? String,
           !key.isEmpty {
            return key
        }
        
        // Если не найден в Info.plist, используем хардкод (для разработки)
        return "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"
    }
    
    /// Referer для OpenRouter
    private var referer: String {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let ref = plist["OpenRouterReferer"] as? String,
           !ref.isEmpty {
            return ref
        }
        return "https://carassistant.app/"
    }
    
    /// Название приложения для OpenRouter
    private var appTitle: String {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let title = plist["OpenRouterAppTitle"] as? String,
           !title.isEmpty {
            return title
        }
        return "Car Assistant"
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Отправить текстовое сообщение с контекстом автомобиля
    /// - Parameters:
    ///   - userMessage: Вопрос пользователя
    ///   - carModel: Марка/модель авто (например: "Audi A6")
    ///   - carYear: Год выпуска (например: "2022")
    ///   - serviceHistory: История обслуживания (дата, что делали)
    ///   - fullCarContext: Полный контекст автомобиля (все данные)
    ///   - userLocation: Геопозиция пользователя (страна, город)
    ///   - chatHistory: История чата для контекста
    /// - Returns: Ответ от ИИ
    func sendMessageWithCarContext(
        userMessage: String,
        carModel: String,
        carYear: String,
        serviceHistory: String,
        fullCarContext: String,
        userLocation: String,
        chatHistory: [(role: String, content: String)] = []
    ) async throws -> String {
        // Проверяем наличие API ключа
        guard !apiKey.isEmpty else {
            throw AIServiceError.apiKeyNotSet
        }
        
        // Формируем system prompt согласно требованиям
        // Включаем ВСЕ данные об автомобиле в промпт
        let systemPrompt = """
        Ты автомобильный помощник, эксперт по ремонту и лучший эксплуатации авто.
        
        Модель авто пользователя: \(carModel), год выпуска: \(carYear), история обслуживания: \(serviceHistory).
        
        ПОЛНАЯ ИНФОРМАЦИЯ ОБ АВТОМОБИЛЕ (используй ВСЕ эти данные для точных рекомендаций):
        \(fullCarContext)
        
        Геопозиция пользователя: \(userLocation)
        
        ВАЖНО: Используй ВСЕ указанные выше данные об автомобиле (марка, модель, год, двигатель, тип топлива, привод, коробка передач, VIN, дополнительные заметки) для персонализированных рекомендаций. Учитывай геопозицию пользователя при рекомендации сервисов и запчастей, чтобы ответы были географически актуальны.
        
        Отвечай понятно, подробно, дружелюбно и с примером действий.
        """
        
        // Формируем массив сообщений с историей чата
        var messages: [[String: Any]] = [
            [
                "role": "system",
                "content": systemPrompt
            ]
        ]
        
        // Добавляем историю чата перед текущим сообщением
        for historyItem in chatHistory {
            messages.append([
                "role": historyItem.role,
                "content": historyItem.content
            ])
        }
        
        // Добавляем текущее сообщение пользователя
        messages.append([
            "role": "user",
            "content": userMessage
        ])
        
        // Формируем тело запроса согласно формату
        let requestBody: [String: Any] = [
            "model": self.model,
            "messages": messages
        ]
        
        return try await sendRequest(requestBody: requestBody)
    }
    
    /// Отправить запрос с изображением
    /// - Parameters:
    ///   - imageData: Данные изображения
    ///   - userMessage: Опциональный текст сообщения
    ///   - carModel: Марка/модель авто
    ///   - carYear: Год выпуска
    ///   - serviceHistory: История обслуживания
    ///   - fullCarContext: Полный контекст автомобиля
    ///   - userLocation: Геопозиция пользователя
    ///   - chatHistory: История чата для контекста
    /// - Returns: Ответ от ИИ
    func sendPhotoRequest(
        imageData: Data,
        userMessage: String? = nil,
        carModel: String,
        carYear: String,
        serviceHistory: String,
        fullCarContext: String,
        userLocation: String,
        chatHistory: [(role: String, content: String)] = []
    ) async throws -> String {
        // Проверяем наличие API ключа
        guard !apiKey.isEmpty else {
            throw AIServiceError.apiKeyNotSet
        }
        
        // Конвертируем изображение в base64
        let base64Image = imageData.base64EncodedString()
        let imageURL = "data:image/jpeg;base64,\(base64Image)"
        
        // Формируем system prompt согласно требованиям
        // Включаем ВСЕ данные об автомобиле в промпт
        let systemPrompt = """
        Ты автомобильный помощник, эксперт по ремонту и лучший эксплуатации авто.
        
        Модель авто пользователя: \(carModel), год выпуска: \(carYear), история обслуживания: \(serviceHistory).
        
        ПОЛНАЯ ИНФОРМАЦИЯ ОБ АВТОМОБИЛЕ (используй ВСЕ эти данные для точных рекомендаций):
        \(fullCarContext)
        
        Геопозиция пользователя: \(userLocation)
        
        ВАЖНО: Используй ВСЕ указанные выше данные об автомобиле (марка, модель, год, двигатель, тип топлива, привод, коробка передач, VIN, дополнительные заметки) для персонализированных рекомендаций. Учитывай геопозицию пользователя при рекомендации сервисов и запчастей, чтобы ответы были географически актуальны. 
        
        АНАЛИЗ ИЗОБРАЖЕНИЙ: Тщательно анализируй все приложенные изображения автомобиля и его деталей. Обращай внимание на:
        - Состояние кузова, наличие повреждений, царапин, вмятин
        - Состояние шин, дисков, тормозных колодок
        - Состояние двигателя, подкапотного пространства
        - Состояние салона, приборной панели, индикаторов
        - Любые видимые проблемы, утечки, износ деталей
        - Состояние фар, фонарей, стекол
        
        Отвечай понятно, подробно, дружелюбно и с примером действий. Если видишь проблемы на изображении, опиши их детально и дай конкретные рекомендации по ремонту.
        """
        
        // Формируем сообщение пользователя с изображением
        var contentArray: [[String: Any]] = []
        
        // Добавляем изображение
        contentArray.append([
            "type": "image_url",
            "image_url": [
                "url": imageURL
            ]
        ])
        
        // Добавляем текст, если есть
        let messageText = userMessage ?? "Проанализируй это изображение автомобиля и дай рекомендации."
        contentArray.append([
            "type": "text",
            "text": messageText
        ])
        
        // Формируем массив сообщений с историей чата
        var messages: [[String: Any]] = [
            [
                "role": "system",
                "content": systemPrompt
            ]
        ]
        
        // Добавляем историю чата перед текущим сообщением
        for historyItem in chatHistory {
            messages.append([
                "role": historyItem.role,
                "content": historyItem.content
            ])
        }
        
        // Добавляем текущее сообщение пользователя с изображением
        messages.append([
            "role": "user",
            "content": contentArray
        ])
        
        // Формируем тело запроса согласно формату
        let requestBody: [String: Any] = [
            "model": self.model,
            "messages": messages
        ]
        
        return try await sendRequest(requestBody: requestBody)
    }
    
    /// Отправить запрос используя PromptBuilder
    /// - Parameters:
    ///   - messages: Массив сообщений, сформированный PromptBuilder
    ///   - model: Модель ИИ (по умолчанию используется модель из конфигурации)
    /// - Returns: Ответ от ИИ
    func sendRequestWithMessages(
        messages: [[String: Any]],
        model: String? = nil
    ) async throws -> String {
        // Проверяем наличие API ключа
        guard !apiKey.isEmpty else {
            throw AIServiceError.apiKeyNotSet
        }
        
        // Используем переданную модель или модель по умолчанию
        let modelToUse = model ?? self.model
        
        // Формируем тело запроса
        let requestBody: [String: Any] = [
            "model": modelToUse,
            "messages": messages
        ]
        
        return try await sendRequest(requestBody: requestBody)
    }
    
    // MARK: - Private Methods
    
    /// Отправить HTTP запрос к OpenRouter API
    /// - Parameter requestBody: Тело запроса
    /// - Returns: Текст ответа от ИИ
    private func sendRequest(requestBody: [String: Any]) async throws -> String {
        // Создаем URL запрос
        guard let url = URL(string: apiURL) else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Устанавливаем заголовки для OpenRouter
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue(referer, forHTTPHeaderField: "HTTP-Referer")
        request.setValue(appTitle, forHTTPHeaderField: "X-Title")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Кодируем тело запроса
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AIServiceError.encodingError
        }
        
        // Отправляем запрос
        do {
            print("🌐 Отправка HTTP запроса к OpenRouter API...")
            print("   Модель: \(self.model)")
            print("   URL: \(apiURL)")
            
            // Логируем тело запроса для отладки
            if let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody),
               let requestBodyString = String(data: requestBodyData, encoding: .utf8) {
                print("   Тело запроса: \(requestBodyString.prefix(500))...")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Проверяем статус ответа
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Неверный формат HTTP ответа")
                throw AIServiceError.invalidResponse
            }
            
            print("📥 HTTP статус: \(httpResponse.statusCode)")
            
            // Логируем ответ для отладки
            if let responseString = String(data: data, encoding: .utf8) {
                print("   Ответ API: \(responseString.prefix(500))...")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                // Пытаемся извлечь сообщение об ошибке
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("❌ Данные об ошибке: \(errorData)")
                    if let error = errorData["error"] as? [String: Any],
                       let errorMessage = error["message"] as? String {
                        print("   Сообщение об ошибке: \(errorMessage)")
                        throw AIServiceError.apiError(errorMessage)
                    }
                }
                print("❌ HTTP ошибка: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("   Полный ответ: \(responseString)")
                }
                throw AIServiceError.httpError(httpResponse.statusCode)
            }
            
            // Парсим ответ
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ Не удалось распарсить JSON ответ")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("   Ответ: \(responseString)")
                }
                throw AIServiceError.invalidResponse
            }
            
            print("   JSON ответ получен: \(json.keys.joined(separator: ", "))")
            
            guard let choices = json["choices"] as? [[String: Any]] else {
                print("❌ Нет поля 'choices' в ответе")
                print("   JSON: \(json)")
                throw AIServiceError.invalidResponse
            }
            
            guard let firstChoice = choices.first else {
                print("❌ Массив 'choices' пуст")
                throw AIServiceError.invalidResponse
            }
            
            guard let message = firstChoice["message"] as? [String: Any] else {
                print("❌ Нет поля 'message' в choice")
                print("   Choice: \(firstChoice)")
                throw AIServiceError.invalidResponse
            }
            
            guard let content = message["content"] as? String else {
                print("❌ Нет поля 'content' в message")
                print("   Message: \(message)")
                throw AIServiceError.invalidResponse
            }
            
            print("✅ Получен ответ от OpenRouter API")
            print("   Длина ответа: \(content.count) символов")
            // Возвращаем только текст ответа от ИИ
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as AIServiceError {
            throw error
        } catch {
            // Обработка сетевых ошибок
            if (error as NSError).code == NSURLErrorNotConnectedToInternet ||
               (error as NSError).code == NSURLErrorTimedOut {
                throw AIServiceError.networkError
            }
            throw AIServiceError.unknownError(error.localizedDescription)
        }
    }
    
    // MARK: - Legacy Methods (для обратной совместимости)
    
    /// Отправить текстовый запрос (для обратной совместимости)
    /// - Parameter text: Текст запроса
    /// - Returns: Ответ от ИИ
    func sendTextRequest(_ text: String) async throws -> String {
        return try await sendMessageWithCarContext(
            userMessage: text,
            carModel: "Не указана",
            carYear: "Не указан",
            serviceHistory: "Нет данных",
            fullCarContext: "Автомобиль не указан",
            userLocation: "Не указана"
        )
    }
    
    /// Отправить голосовой запрос (заглушка)
    /// - Parameter audioData: Данные аудио
    /// - Returns: Ответ от ИИ
    func sendVoiceRequest(_ audioData: Data) async throws -> String {
        // TODO: Интеграция с AI backend для голосового запроса
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "Заглушка ответа для голосового запроса"
    }
    
    /// Отправить запрос с фото (старая версия для обратной совместимости)
    /// - Parameter imageData: Данные изображения
    /// - Returns: Ответ от ИИ
    func sendPhotoRequest(_ imageData: Data) async throws -> String {
        return try await sendPhotoRequest(
            imageData: imageData,
            userMessage: nil,
            carModel: "Не указана",
            carYear: "Не указан",
            serviceHistory: "Нет данных",
            fullCarContext: "Автомобиль не указан",
            userLocation: "Не указана"
        )
    }
}

// MARK: - AIServiceError

/// Ошибки AIService
enum AIServiceError: LocalizedError {
    case apiKeyNotSet
    case invalidURL
    case encodingError
    case invalidResponse
    case networkError
    case httpError(Int)
    case apiError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotSet:
            return "API ключ не установлен. Установите ваш OpenRouter API ключ в Info.plist (ключ OpenRouterAPIKey)"
        case .invalidURL:
            return "Неверный URL API"
        case .encodingError:
            return "Ошибка кодирования запроса"
        case .invalidResponse:
            return "Неверный формат ответа от сервера"
        case .networkError:
            return "Сервис временно не отвечает"
        case .httpError(let code):
            return "Ошибка HTTP: \(code)"
        case .apiError(let message):
            return "Ошибка API: \(message)"
        case .unknownError(let message):
            return "Неизвестная ошибка: \(message)"
        }
    }
}
