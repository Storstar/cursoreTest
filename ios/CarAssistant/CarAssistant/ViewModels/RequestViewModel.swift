import Foundation
import CoreData
import SwiftUI

@MainActor
class RequestViewModel: ObservableObject {
    @Published var requests: [Request] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }
    
    // Кэш для избежания лишних запросов
    private var lastLoadedUserId: UUID?
    private var lastLoadTime: Date?
    private let cacheTimeout: TimeInterval = 3.0 // 3 секунды кэш
    
    func loadRequests(for user: User) {
        // Проверяем кэш
        if let lastUserId = lastLoadedUserId,
           let lastTime = lastLoadTime,
           lastUserId == user.id,
           Date().timeIntervalSince(lastTime) < cacheTimeout,
           !requests.isEmpty {
            return // Используем кэшированные данные
        }
        
        let fetchRequest: NSFetchRequest<Request> = Request.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Request.createdAt, ascending: false)]
        fetchRequest.fetchBatchSize = 20 // Оптимизация для больших списков
        
        do {
            requests = try context.fetch(fetchRequest)
            lastLoadedUserId = user.id
            lastLoadTime = Date()
        } catch {
            errorMessage = "Ошибка загрузки запросов: \(error.localizedDescription)"
        }
    }
    
    func createTextRequest(text: String, for user: User, car: Car?, chatId: UUID? = nil, chatHistory: [(role: String, content: String)] = []) async {
        errorMessage = nil
        
        if let error = Validators.validateRequestText(text) {
            errorMessage = error
            return
        }
        
        isLoading = true
        
        // ВАЖНО: Сначала сохраняем запрос пользователя, чтобы он сразу появился в чате
        let request = Request(context: context)
        request.id = UUID()
        request.text = text
        request.type = "text"
        request.createdAt = Date()
        request.user = user
        request.car = car // Связываем запрос с автомобилем
        request.chatId = chatId // Связываем запрос с чатом (если указан)
        
        // Сохраняем запрос БЕЗ ответа (ответ добавим позже)
        // Это позволит показать сообщение пользователя и индикатор загрузки
        CoreDataManager.shared.save()
        
        // Обновляем контекст, чтобы изменения были видны
        context.refresh(request, mergeChanges: true)
        
        // Теперь пытаемся получить ответ от AI
        do {
            // Извлекаем данные об автомобиле для нового формата
            let (carModel, carYear, serviceHistory, fullCarContext, userLocation) = extractCarData(for: car, user: user)
            
            print("📤 Отправка запроса к OpenRouter...")
            print("   Модель: \(carModel), Год: \(carYear)")
            
            // Отправляем запрос с новым форматом, включая историю чата
            let responseText = try await AIService.shared.sendMessageWithCarContext(
                userMessage: text,
                carModel: carModel,
                carYear: carYear,
                serviceHistory: serviceHistory,
                fullCarContext: fullCarContext,
                userLocation: userLocation,
                chatHistory: chatHistory
            )
            
            print("✅ Получен ответ от OpenRouter: \(responseText.prefix(100))...")
            
            // Создаем ответ и связываем с запросом
            let response = Response(context: context)
            response.id = UUID()
            response.text = responseText
            response.createdAt = Date()
            response.request = request
            
            CoreDataManager.shared.save()
            
            // Уведомляем об изменении после получения ответа
            await MainActor.run {
                loadRequests(for: user)
            }
            
        } catch {
            // Логируем ошибку для отладки
            print("❌ Ошибка при запросе к OpenRouter: \(error)")
            
            // Обрабатываем ошибки AIService
            var errorMsg: String
            if let aiError = error as? AIServiceError {
                errorMsg = aiError.errorDescription ?? "Ошибка создания запроса"
                print("   Тип ошибки: \(aiError)")
            } else {
                errorMsg = "Ошибка создания запроса: \(error.localizedDescription)"
            }
            
            errorMessage = errorMsg
            
            // Создаем ответ с ошибкой, чтобы пользователь видел, что запрос был отправлен
            let errorResponse = Response(context: context)
            errorResponse.id = UUID()
            errorResponse.text = "Не удалось получить ответ. Попробуйте позже."
            errorResponse.createdAt = Date()
            errorResponse.request = request
            
            CoreDataManager.shared.save()
            
            // Уведомляем об изменении после ошибки
            await MainActor.run {
                loadRequests(for: user)
            }
        }
        
        isLoading = false
    }
    
    // Извлекает данные об автомобиле для нового формата API
    private func extractCarData(for car: Car?, user: User) -> (carModel: String, carYear: String, serviceHistory: String, fullCarContext: String, userLocation: String) {
        // Извлекаем модель и год
        let carModel: String
        let carYear: String
        
        if let car = car {
            let brand = car.brand ?? ""
            let model = car.model ?? ""
            carModel = brand.isEmpty && model.isEmpty ? "Не указана" : "\(brand) \(model)".trimmingCharacters(in: .whitespaces)
            carYear = car.year > 0 ? "\(car.year)" : "Не указан"
        } else {
            carModel = "Не указана"
            carYear = "Не указан"
        }
        
        // Извлекаем историю обслуживания
        let serviceHistory = buildServiceHistory(for: car)
        
        // Формируем полный контекст (все данные об авто)
        let fullCarContext = buildFullCarContext(for: car)
        
        // Извлекаем геопозицию
        var locationParts: [String] = []
        if let country = user.country, !country.isEmpty {
            locationParts.append(country)
        }
        if let city = user.city, !city.isEmpty {
            locationParts.append(city)
        }
        let userLocation = locationParts.isEmpty ? "Не указана" : locationParts.joined(separator: ", ")
        
        return (carModel, carYear, serviceHistory, fullCarContext, userLocation)
    }
    
    // Формирует полный контекст автомобиля для AI (все данные)
    private func buildFullCarContext(for car: Car?) -> String {
        var contextParts: [String] = []
        
        // Данные об автомобиле - ВСЕ поля обязательно
        if let car = car {
            contextParts.append("=== ДАННЫЕ ОБ АВТОМОБИЛЕ ===")
            
            // Обязательные поля
            contextParts.append("Марка: \(car.brand.isEmpty ? "Не указана" : car.brand)")
            contextParts.append("Модель: \(car.model.isEmpty ? "Не указана" : car.model)")
            contextParts.append("Год выпуска: \(car.year > 0 ? "\(car.year)" : "Не указан")")
            contextParts.append("Двигатель: \(car.engine.isEmpty ? "Не указан" : car.engine)")
            
            // Опциональные поля - включаем все, даже если пустые
            if let fuelType = car.fuelType, !fuelType.isEmpty {
                contextParts.append("Тип топлива: \(fuelType)")
            } else {
                contextParts.append("Тип топлива: Не указан")
            }
            
            if let driveType = car.driveType, !driveType.isEmpty {
                contextParts.append("Привод: \(driveType)")
            } else {
                contextParts.append("Привод: Не указан")
            }
            
            if let transmission = car.transmission, !transmission.isEmpty {
                contextParts.append("Коробка передач: \(transmission)")
            } else {
                contextParts.append("Коробка передач: Не указана")
            }
            
            if let vin = car.vin, !vin.isEmpty {
                contextParts.append("VIN: \(vin)")
            } else {
                contextParts.append("VIN: Не указан")
            }
            
            if let notes = car.notes, !notes.isEmpty {
                contextParts.append("Дополнительная информация: \(notes)")
            } else {
                contextParts.append("Дополнительная информация: Нет")
            }
            
            // Фото автомобиля (если есть)
            if car.photoData != nil {
                contextParts.append("Фото автомобиля: Есть")
            } else {
                contextParts.append("Фото автомобиля: Нет")
            }
        } else {
            contextParts.append("=== ДАННЫЕ ОБ АВТОМОБИЛЕ ===")
            contextParts.append("Автомобиль не выбран")
        }
        
        return contextParts.joined(separator: "\n")
    }
    
    // Формирует строку с историей обслуживания из MaintenanceRecord
    // Берет ВСЮ историю обслуживания для максимального контекста
    private func buildServiceHistory(for car: Car?) -> String {
        guard let car = car else {
            return "Нет данных об обслуживании"
        }
        let fetchRequest: NSFetchRequest<MaintenanceRecord> = MaintenanceRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "car == %@", car)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MaintenanceRecord.date, ascending: false)]
        // Берем ВСЕ записи, без ограничений
        
        do {
            let records = try context.fetch(fetchRequest)
            
            if records.isEmpty {
                return "Нет данных об обслуживании"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.locale = Locale(identifier: "ru_RU")
            
            var historyParts: [String] = []
            
            // Сортируем по дате (от старых к новым для хронологического порядка)
            let sortedRecords = records.sorted { $0.date < $1.date }
            
            for (index, record) in sortedRecords.enumerated() {
                var recordParts: [String] = []
                
                // Номер записи для удобства
                recordParts.append("Запись \(index + 1)")
                
                // Дата
                let dateStr = dateFormatter.string(from: record.date)
                recordParts.append("дата: \(dateStr)")
                
                // Пробег
                if record.mileage > 0 {
                    recordParts.append("пробег: \(record.mileage) км")
                }
                
                // Тип обслуживания
                if let serviceType = record.serviceType, !serviceType.isEmpty {
                    recordParts.append("тип обслуживания: \(serviceType)")
                }
                
                // Описание работ
                if let worksPerformed = record.worksPerformed, !worksPerformed.isEmpty {
                    recordParts.append("выполненные работы: \(worksPerformed)")
                }
                
                // Описание
                if let description = record.serviceDescription, !description.isEmpty {
                    recordParts.append("описание: \(description)")
                }
                
                // Следующее ТО (если указано)
                if let nextServiceDate = record.nextServiceDate {
                    let nextDateStr = dateFormatter.string(from: nextServiceDate)
                    recordParts.append("следующее ТО: \(nextDateStr)")
                }
                
                if record.nextServiceMileage > 0 {
                    recordParts.append("следующий пробег: \(record.nextServiceMileage) км")
                }
                
                if !recordParts.isEmpty {
                    historyParts.append(recordParts.joined(separator: "; "))
                }
            }
            
            return historyParts.isEmpty ? "Нет данных об обслуживании" : historyParts.joined(separator: "\n")
            
        } catch {
            print("Ошибка загрузки истории обслуживания: \(error)")
            return "Ошибка загрузки данных об обслуживании"
        }
    }
    
    func createVoiceRequest(audioData: Data, for user: User, car: Car?, chatId: UUID? = nil) async {
        errorMessage = nil
        isLoading = true
        
        do {
            let responseText = try await AIService.shared.sendVoiceRequest(audioData)
            
            let request = Request(context: context)
            request.id = UUID()
            request.type = "voice"
            request.createdAt = Date()
            request.user = user
            request.car = car // Связываем запрос с автомобилем
            request.chatId = chatId // Связываем запрос с чатом (если указан)
            
            let response = Response(context: context)
            response.id = UUID()
            response.text = responseText
            response.createdAt = Date()
            response.request = request
            
            CoreDataManager.shared.save()
            await loadRequests(for: user)
        } catch {
            errorMessage = "Ошибка создания голосового запроса: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func createPhotoRequest(imageData: Data, userMessage: String? = nil, for user: User, car: Car?, chatId: UUID? = nil, chatHistory: [(role: String, content: String)] = []) async {
        errorMessage = nil
        isLoading = true
        
        do {
            // Извлекаем данные об автомобиле для нового формата
            let (carModel, carYear, serviceHistory, fullCarContext, userLocation) = extractCarData(for: car, user: user)
            
            print("📤 Отправка фото запроса к OpenRouter...")
            print("   Модель: \(carModel), Год: \(carYear)")
            if let userMessage = userMessage, !userMessage.isEmpty {
                print("   Текст пользователя: \(userMessage.prefix(50))...")
            }
            
            // Отправляем запрос с новым форматом, включая историю чата и текст пользователя
            let responseText = try await AIService.shared.sendPhotoRequest(
                imageData: imageData,
                userMessage: userMessage,
                carModel: carModel,
                carYear: carYear,
                serviceHistory: serviceHistory,
                fullCarContext: fullCarContext,
                userLocation: userLocation,
                chatHistory: chatHistory
            )
            
            print("✅ Получен ответ от OpenRouter: \(responseText.prefix(100))...")
            
            let request = Request(context: context)
            request.id = UUID()
            request.imageData = imageData
            // Сохраняем текст, если он есть
            if let userMessage = userMessage, !userMessage.isEmpty {
                request.text = userMessage
            }
            request.type = "photo"
            request.createdAt = Date()
            request.user = user
            request.car = car // Связываем запрос с автомобилем
            request.chatId = chatId // Связываем запрос с чатом (если указан)
            
            let response = Response(context: context)
            response.id = UUID()
            response.text = responseText
            response.createdAt = Date()
            response.request = request
            
            CoreDataManager.shared.save()
            await loadRequests(for: user)
        } catch {
            errorMessage = "Ошибка создания фото запроса: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
