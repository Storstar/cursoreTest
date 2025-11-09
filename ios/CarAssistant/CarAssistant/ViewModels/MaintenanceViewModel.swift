import Foundation
import CoreData
import SwiftUI
import Vision
import VisionKit
import UserNotifications

@MainActor
class MaintenanceViewModel: ObservableObject {
    @Published var maintenanceRecords: [MaintenanceRecord] = []
    @Published var upcomingServices: [MaintenanceRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }
    
    private var allRecords: [MaintenanceRecord] = []
    
    // Загрузить записи ТО для автомобиля
    func loadMaintenanceRecords(for car: Car) {
        let fetchRequest: NSFetchRequest<MaintenanceRecord> = MaintenanceRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "car == %@", car)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MaintenanceRecord.date, ascending: false)]
        fetchRequest.fetchBatchSize = 20 // Оптимизация для больших списков
        // Оптимизация: не загружаем documentImageData в память сразу (lazy loading)
        fetchRequest.includesPropertyValues = true
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            allRecords = try context.fetch(fetchRequest)
            // Разделяем на выполненные и запланированные
            maintenanceRecords = allRecords.filter { !$0.isPlanned }
            updateUpcomingServices()
        } catch {
            errorMessage = "Ошибка загрузки записей ТО: \(error.localizedDescription)"
        }
    }
    
    // Создать запись ТО
    func createMaintenanceRecord(
        date: Date,
        mileage: Int32,
        serviceType: String?,
        description: String?,
        worksPerformed: String?,
        documentImageData: Data?,
        extractedText: String?,
        isPlanned: Bool = false,
        plannedDate: Date? = nil,
        plannedMileage: Int32? = nil,
        for car: Car
    ) {
        let record = MaintenanceRecord(context: context)
        record.id = UUID()
        record.date = date
        record.mileage = mileage
        record.serviceType = serviceType
        record.serviceDescription = description
        record.worksPerformed = worksPerformed
        // Оптимизируем изображение перед сохранением
        if let documentImageData = documentImageData, let image = UIImage(data: documentImageData) {
            record.documentImageData = ImageOptimizer.shared.optimizeImage(image, maxDimension: 1200, compressionQuality: 0.7)
        } else {
            record.documentImageData = documentImageData
        }
        record.extractedText = extractedText
        record.isPlanned = isPlanned
        record.car = car
        
        if isPlanned {
            // Если это запланированная работа, используем указанные дату и пробег
            let targetDate = plannedDate ?? date
            record.nextServiceDate = targetDate
            record.nextServiceMileage = plannedMileage ?? 0
            record.date = targetDate // Дата запланированной работы
            
            // Планируем уведомления
            scheduleNotifications(for: record)
        } else {
            // Если это выполненная работа, вычисляем следующее ТО на основе типа обслуживания
            calculateNextService(for: record)
            
            // Автоматически создаем запланированную работу на следующее ТО
            createPlannedWorkFromCompleted(for: record, car: car)
        }
        
        CoreDataManager.shared.save()
        loadMaintenanceRecords(for: car)
    }
    
    // Создать запланированную работу на основе выполненной
    // ВАЖНО: Создается ПОЛНОСТЬЮ НЕЗАВИСИМАЯ запись в Core Data.
    // После создания запланированная работа не имеет никакой связи с исходной,
    // кроме того, что обе относятся к одному автомобилю.
    // Редактирование запланированной работы НЕ затрагивает исходную выполненную работу.
    private func createPlannedWorkFromCompleted(for completedRecord: MaintenanceRecord, car: Car) {
        guard let nextDate = completedRecord.nextServiceDate,
              let serviceType = completedRecord.serviceType else { return }
        
        // Проверяем, не существует ли уже такая запланированная работа
        let fetchRequest: NSFetchRequest<MaintenanceRecord> = MaintenanceRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "car == %@ AND isPlanned == YES AND nextServiceDate == %@", car, nextDate as NSDate)
        
        do {
            let existing = try context.fetch(fetchRequest)
            if !existing.isEmpty {
                // Уже есть запланированная работа на эту дату
                return
            }
        } catch {
            print("Ошибка проверки существующих запланированных работ: \(error)")
        }
        
        // Создаем НОВУЮ НЕЗАВИСИМУЮ запись запланированной работы
        // Это отдельная запись в Core Data с собственным UUID
        let plannedRecord = MaintenanceRecord(context: context)
        plannedRecord.id = UUID() // Уникальный ID, отличный от исходной записи
        plannedRecord.date = nextDate // Дата запланированной работы
        plannedRecord.mileage = completedRecord.mileage // Текущий пробег (будет обновлен при выполнении)
        plannedRecord.serviceType = serviceType
        plannedRecord.serviceDescription = "Автоматически создано на основе выполненного ТО"
        plannedRecord.nextServiceDate = nextDate
        plannedRecord.nextServiceMileage = completedRecord.nextServiceMileage
        plannedRecord.isPlanned = true
        plannedRecord.car = car // Связь только с автомобилем, НЕ с исходной записью
        
        // Планируем уведомления
        scheduleNotifications(for: plannedRecord)
        
        // После создания запланированная работа полностью независима от исходной
        // Редактирование plannedRecord НЕ затрагивает completedRecord
    }
    
    // Планировать уведомления для запланированной работы
    private func scheduleNotifications(for record: MaintenanceRecord) {
        guard let serviceType = record.serviceType,
              let car = record.car else { return }
        
        // Для запланированных работ используем date, для остальных - nextServiceDate
        let targetDate = record.isPlanned ? record.date : (record.nextServiceDate ?? record.date)
        
        // Не планируем уведомления для просроченных работ
        if targetDate < Date() {
            return
        }
        
        let carName = "\(car.brand ?? "") \(car.model ?? "")"
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Запрос разрешения на уведомления
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            
            // Уведомление за неделю
            let weekBefore = Calendar.current.date(byAdding: .day, value: -7, to: targetDate)
            if let weekBefore = weekBefore, weekBefore > Date() {
                let content = UNMutableNotificationContent()
                content.title = "Напоминание о работах"
                content.body = "Через неделю запланирована работа для \(carName): \(serviceType)"
                content.sound = .default
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: weekBefore)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "maintenance_\(record.id.uuidString)_week",
                    content: content,
                    trigger: trigger
                )
                
                notificationCenter.add(request)
            }
            
            // Уведомление за сутки
            let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: targetDate)
            if let dayBefore = dayBefore, dayBefore > Date() {
                let content = UNMutableNotificationContent()
                content.title = "Напоминание о работах"
                content.body = "Завтра запланирована работа для \(carName): \(serviceType)"
                content.sound = .default
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dayBefore)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "maintenance_\(record.id.uuidString)_day",
                    content: content,
                    trigger: trigger
                )
                
                notificationCenter.add(request)
            }
        }
    }
    
    // Обновить запись ТО
    // ВАЖНО: При редактировании запланированной работы (isPlanned == true)
    // изменяется ТОЛЬКО эта запись. Исходная выполненная работа, из которой
    // она была создана, остается полностью неизменной.
    func updateMaintenanceRecord(
        _ record: MaintenanceRecord,
        date: Date,
        mileage: Int32,
        serviceType: String?,
        description: String?,
        worksPerformed: String?,
        documentImageData: Data?,
        extractedText: String?
    ) {
        // Редактируем ТОЛЬКО переданную запись record
        // Это отдельная запись в Core Data, никак не связанная с исходной
        record.date = date
        record.mileage = mileage
        record.serviceType = serviceType
        record.serviceDescription = description
        record.worksPerformed = worksPerformed
        // Оптимизируем изображение перед сохранением
        if let documentImageData = documentImageData, let image = UIImage(data: documentImageData) {
            record.documentImageData = ImageOptimizer.shared.optimizeImage(image, maxDimension: 1200, compressionQuality: 0.7)
        } else {
            record.documentImageData = documentImageData
        }
        record.extractedText = extractedText
        
        if record.isPlanned {
            // ЗАПЛАНИРОВАННАЯ РАБОТА: редактируется только эта запись
            // Обновляем nextServiceDate на новую дату запланированной работы
            record.nextServiceDate = date
            // НЕ пересчитываем следующее ТО
            // НЕ создаем новые запланированные работы
            // НЕ затрагиваем исходную выполненную работу
        } else {
            // ВЫПОЛНЕННАЯ РАБОТА: пересчитываем следующее ТО
            // Это может создать новую запланированную работу
            calculateNextService(for: record)
        }
        
        CoreDataManager.shared.save()
        if let car = record.car {
            loadMaintenanceRecords(for: car)
        }
    }
    
    // Удалить запись ТО
    func deleteMaintenanceRecord(_ record: MaintenanceRecord) {
        let car = record.car
        context.delete(record)
        CoreDataManager.shared.save()
        if let car = car {
            loadMaintenanceRecords(for: car)
        }
    }
    
    // Вычислить следующее ТО на основе типа обслуживания
    private func calculateNextService(for record: MaintenanceRecord) {
        guard let serviceType = record.serviceType else { return }
        
        let calendar = Calendar.current
        var nextDate: Date?
        var nextMileage: Int32 = 0
        
        // Стандартные интервалы ТО
        switch serviceType.lowercased() {
        case "плановое то", "техническое обслуживание", "то":
            // Каждые 15,000 км или 12 месяцев
            nextMileage = record.mileage + 15000
            nextDate = calendar.date(byAdding: .month, value: 12, to: record.date)
        case "замена масла", "масло":
            // Каждые 10,000 км или 6 месяцев
            nextMileage = record.mileage + 10000
            nextDate = calendar.date(byAdding: .month, value: 6, to: record.date)
        case "замена фильтров", "фильтры":
            // Каждые 15,000 км или 12 месяцев
            nextMileage = record.mileage + 15000
            nextDate = calendar.date(byAdding: .month, value: 12, to: record.date)
        case "замена тормозов", "тормоза":
            // Каждые 50,000 км или 3 года
            nextMileage = record.mileage + 50000
            nextDate = calendar.date(byAdding: .year, value: 3, to: record.date)
        case "замена шин", "шины":
            // Каждые 50,000 км или 4 года
            nextMileage = record.mileage + 50000
            nextDate = calendar.date(byAdding: .year, value: 4, to: record.date)
        case "диагностика", "осмотр":
            // Каждые 10,000 км или 6 месяцев
            nextMileage = record.mileage + 10000
            nextDate = calendar.date(byAdding: .month, value: 6, to: record.date)
        default:
            // По умолчанию: каждые 15,000 км или 12 месяцев
            nextMileage = record.mileage + 15000
            nextDate = calendar.date(byAdding: .month, value: 12, to: record.date)
        }
        
        record.nextServiceDate = nextDate
        record.nextServiceMileage = nextMileage
    }
    
    // Обновить список предстоящих ТО
    private func updateUpcomingServices() {
        upcomingServices = allRecords.filter { record in
            // Показываем только запланированные работы (включая просроченные)
            guard record.isPlanned else { return false }
            return record.nextServiceDate != nil
        }.sorted { record1, record2 in
            let date1 = record1.nextServiceDate ?? Date.distantFuture
            let date2 = record2.nextServiceDate ?? Date.distantFuture
            return date1 < date2
        }
    }
    
    // Распознать текст с изображения
    func recognizeText(from image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }
        
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                let fullText = recognizedStrings.joined(separator: "\n")
                continuation.resume(returning: fullText.isEmpty ? nil : fullText)
            }
            
            request.recognitionLanguages = ["ru-RU", "en-US"]
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }
    
    // Извлечь информацию о ТО из распознанного текста
    func extractMaintenanceInfo(from text: String) -> (serviceType: String?, worksPerformed: String?, mileage: Int32?) {
        var serviceType: String?
        var worksPerformed: String?
        var mileage: Int32?
        
        let lowerText = text.lowercased()
        
        // Определяем тип обслуживания
        if lowerText.contains("плановое то") || lowerText.contains("техническое обслуживание") {
            serviceType = "Плановое ТО"
        } else if lowerText.contains("замена масла") || lowerText.contains("масло") {
            serviceType = "Замена масла"
        } else if lowerText.contains("замена фильтров") || lowerText.contains("фильтр") {
            serviceType = "Замена фильтров"
        } else if lowerText.contains("замена тормозов") || lowerText.contains("тормоз") {
            serviceType = "Замена тормозов"
        } else if lowerText.contains("замена шин") || lowerText.contains("шины") {
            serviceType = "Замена шин"
        } else if lowerText.contains("диагностика") || lowerText.contains("осмотр") {
            serviceType = "Диагностика"
        }
        
        // Извлекаем пробег
        let mileagePattern = #"(\d+)\s*(?:км|km|тыс|тысяч)"#
        if let regex = try? NSRegularExpression(pattern: mileagePattern, options: .caseInsensitive) {
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                let matchedString = nsString.substring(with: match.range)
                if let number = Int32(matchedString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    mileage = number
                }
            }
        }
        
        // Извлекаем выполненные работы (первые 500 символов)
        if text.count > 50 {
            worksPerformed = String(text.prefix(500))
        } else {
            worksPerformed = text
        }
        
        return (serviceType, worksPerformed, mileage)
    }
    
    // Удалить запись ТО
    func deleteMaintenanceRecord(_ record: MaintenanceRecord, for car: Car) {
        context.delete(record)
        CoreDataManager.shared.save()
        loadMaintenanceRecords(for: car)
    }
}

