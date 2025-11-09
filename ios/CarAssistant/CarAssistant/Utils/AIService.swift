import Foundation

class AIService {
    static let shared = AIService()
    
    // OpenRouter API endpoint
    private let apiURL = "https://openrouter.ai/api/v1/chat/completions"
    
    // Модель через OpenRouter (GPT-5)
    // Если модель недоступна, попробуйте: "openai/gpt-4", "openai/gpt-4-turbo", "openai/gpt-3.5-turbo"
    // Список доступных моделей: https://openrouter.ai/models
    private let model = "openai/gpt-5"
    
    // Получаем конфигурацию из Info.plist
    private var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["OpenRouterAPIKey"] as? String,
              !key.isEmpty else {
            return ""
        }
        return key
    }
    
    private var referer: String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let ref = plist["OpenRouterReferer"] as? String,
              !ref.isEmpty else {
            return "https://carassistant.app/"
        }
        return ref
    }
    
    private var appTitle: String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let title = plist["OpenRouterAppTitle"] as? String,
              !title.isEmpty else {
            return "Car Assistant"
        }
        return title
    }
    
    private init() {}
    
    // Основная функция для отправки сообщения с контекстом автомобиля через OpenRouter
    func sendMessageWithCarContext(
        message: String,
        carContext: String,
        chatHistory: [(role: String, content: String)] = []
    ) async throws -> String {
        // Проверяем наличие API ключа
        guard !apiKey.isEmpty else {
            throw AIServiceError.apiKeyNotSet
        }
        
        // Формируем system prompt с полным контекстом
        let systemPrompt = """
        Ты автомобильный помощник, эксперт по ремонту и эксплуатации авто.
        
        Используй следующую информацию о пользователе и его автомобиле для персонализированных рекомендаций:
        
        \(carContext)
        
        Важно:
        - Учитывай геопозицию пользователя при рекомендации сервисов и запчастей
        - Используй все данные об автомобиле для точных рекомендаций
        - Учитывай историю обслуживания при планировании работ
        - Отвечай понятно, подробно, дружелюбно и с примерами действий
        """
        
        // Формируем массив сообщений: system prompt + история чата + новое сообщение пользователя
        var messages: [[String: String]] = [
            [
                "role": "system",
                "content": systemPrompt
            ]
        ]
        
        // Добавляем историю чата (все предыдущие сообщения)
        for historyItem in chatHistory {
            messages.append([
                "role": historyItem.role,
                "content": historyItem.content
            ])
        }
        
        // Добавляем новое сообщение пользователя
        messages.append([
            "role": "user",
            "content": message
        ])
        
        // Формируем тело запроса для OpenRouter
        let requestBody: [String: Any] = [
            "model": self.model,
            "messages": messages
        ]
        
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
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Проверяем статус ответа
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Неверный формат HTTP ответа")
                throw AIServiceError.invalidResponse
            }
            
            print("📥 HTTP статус: \(httpResponse.statusCode)")
            
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
                throw AIServiceError.httpError(httpResponse.statusCode)
            }
            
            // Парсим ответ
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw AIServiceError.invalidResponse
            }
            
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
    
    // Старая функция для обратной совместимости (использует новую функцию)
    func sendTextRequest(_ text: String) async throws -> String {
        // Для обратной совместимости используем базовую версию без контекста
        return try await sendMessageWithCarContext(
            message: text,
            carContext: "Автомобиль не указан"
        )
    }
    
    func sendVoiceRequest(_ audioData: Data) async throws -> String {
        // TODO: Интеграция с AI backend для голосового запроса
        // Отправить POST запрос с аудио данными на backend API
        // Получить и вернуть ответ от AI
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "Заглушка ответа для голосового запроса"
    }
    
    func sendPhotoRequest(_ imageData: Data) async throws -> String {
        // TODO: Интеграция с AI backend для фото запроса
        // Отправить POST запрос с изображением на backend API
        // Получить и вернуть ответ от AI
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "Заглушка ответа для фото запроса"
    }
}

// Ошибки AIService
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
