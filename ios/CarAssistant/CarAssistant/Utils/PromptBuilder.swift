//
//  PromptBuilder.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import Foundation

// MARK: - Topic

enum Topic: String {
    case general_question
    case check_engine
    case battery
    case brakes
    case engine
    case transmission
    case suspension
    case electrical
    case air_conditioning
    case tires
}

// MARK: - Vehicle

struct Vehicle {
    let make: String
    let model: String
    let year: String
    let engine: String
    let fuelType: String?
    let drivetrain: String?
    let transmission: String?
    let vin: String?
    let notes: String?
    let hasPhotos: Bool
}

// MARK: - Geo

struct Geo {
    let country: String?
    let city: String?
}

// MARK: - MaintenanceRecordData

struct MaintenanceRecordData {
    let date: String
    let mileageKm: String
    let type: String
    let workDone: String
    let description: String
}

// MARK: - UserContent

enum UserContent {
    case text(String)
    case images(imagesBase64: [String], text: String?)
}

// MARK: - Prompt Templates

private let baseSystemPromptTemplate = """
Ты — автомобильный ассистент, эксперт по диагностике, ремонту и эксплуатации авто. Отвечай понятно, подробно, дружелюбно и с пошаговыми действиями.

ПОЛНАЯ ИНФОРМАЦИЯ ОБ АВТОМОБИЛЕ (используй ВСЕ эти данные для персонализированных рекомендаций):

=== ДАННЫЕ ОБ АВТО ===
Марка: {MAKE}
Модель: {MODEL}
Год выпуска: {YEAR}
Двигатель: {ENGINE}
Тип топлива: {FUEL}
Привод: {DRIVETRAIN}
Коробка передач: {TRANSMISSION}
VIN: {VIN}
Дополнительная информация: {NOTES}
Фото автомобиля: {HAS_PHOTOS}
Геопозиция пользователя: {COUNTRY}, {CITY}

=== ИСТОРИЯ ОБСЛУЖИВАНИЯ ===
{MAINTENANCE_HISTORY}

ВАЖНО:
- Не запрашивай повторно данные, уже указанные выше.
- Учитывай регион пользователя при рекомендациях сервисов, запчастей и стандартов.
- Дай: вероятные причины, пошаговую диагностику (от простого к сложному), какие инструменты нужны, ориентир стоимости/времени, уровень срочности и "можно ли ездить".
- Если доступен инструмент веб‑поиска, выполни целенаправленный поиск по марке/модели/году и тематике вопроса; процитируй ключевые источники. Если недоступен — опирайся на свои знания и прямо это укажи в ответе.

{ANALYZE_IMAGES_BLOCK}

=== ТЕКУЩИЙ ФОКУС ТЕМЫ ===
{TOPIC_ADDON}
"""

private let analyzeImagesBlock = """
АНАЛИЗ ИЗОБРАЖЕНИЙ: внимательно изучай все приложенные фотографии автомобиля и его деталей. Обращай внимание на:
- Кузов: повреждения, коррозия, зазоры
- Шины/диски/колодки/диски тормозные
- Подкапотное пространство: течи, следы перегрева, ремни, патрубки, разъёмы
- Панель приборов/индикаторы/ошибки
- Салон/шумы/вибрации (по косвенным признакам)
- Фары/стёкла/фонари/трещины

Если видишь проблему — опиши, как её подтвердить и устранить, укажи приоритет и риски.
"""

// MARK: - Topic Add-ons

private let addonGeneral = """
Фокус: общий вопрос по автомобилю.
- Учитывай специфику {MAKE} {MODEL} {YEAR} с двигателем {ENGINE}.
- Дай чёткий ответ и варианты решения. Если вопрос широкий — структурируй по блокам (диагностика, обслуживание, эксплуатация, стоимость).
- Веб‑поиск (если доступен): проверь руководства по обслуживанию, типовые вопросы владельцев, распространённые TSB/отзывы по этой модели.
"""

private let addonCheckEngine = """
Фокус: индикатор Check Engine (MIL).
- Если есть коды OBD‑II/DTC и freeze‑frame — учитывай их. Без кодов предложи быстрый способ считать их (OBD‑сканер/сервис).
- Сгруппируй вероятные причины по системам (воздух/топливо/зажигание/выхлоп/EGR/EVAP/датчики/проводка).
- Дай пошаговую диагностику: визуальный осмотр, чтение кодов, живые параметры (STFT/LTFT, MAP/MAF, O2/AFR, ECT, RPM), дым‑тест EVAP, тест герметичности впуска.
- Укажи, можно ли продолжать движение по типичным кодам (P0300, P0420, P0171/174, P0401, P044x и т.д.).
- Для {MAKE} {MODEL} {YEAR}: перечисли частые причины Check Engine и известные бюллетени/кампании (если найдёшь).
- Веб‑поиск (если доступен): запросы вида
  - "{MAKE} {MODEL} {YEAR} check engine common issues"
  - "site:forums {MAKE} {MODEL} P0xxx"
  - "TSB {MAKE} {MODEL} {YEAR} EVAP/EGR misfire"
Собери 3–5 релевантных источников, процитируй ключ и сделай вывод.
"""

private let addonBattery = """
Фокус: питание/заряд 12В, пуск и генератор.
- Нормы: 12.6–12.8В покой, <12.2В — разряд; при пуске не ниже ~9.6В; зарядка 13.8–14.7В.
- Чек‑лист: тест под нагрузкой, утечка тока (порядка <50 мА норм), визуальный осмотр клемм/массы, измерить падение напряжения по массе/плюсу.
- Отдельно проверь генератор/регулятор, ремень, шкив свободного хода.
- Для {MAKE} {MODEL} {YEAR}: отметь типичные слабые места по электропитанию.
- Веб‑поиск (если доступен): common battery drain/alternator issues для этой модели.
"""

private let addonBrakes = """
Фокус: тормоза/ABS.
- Минимум: толщина колодок ≥3 мм, диски без гребня/биения; жидкость DOT по спецификации, срок замены 2 года (ориентир).
- Диагностика: шумы/биение руля, измерение биения дисков, направляющие суппортов, состояние пыльников, ручник/тросы, датчики ABS.
- Тест‑драйв: замедление, увод, ABS‑срабатывание.
- Для {MAKE} {MODEL} {YEAR}: частые проблемы (закисание направляющих, задние суппорты, датчики ABS и т.п.).
- Веб‑поиск (если доступен): "{MAKE} {MODEL} brake shudder common causes", "ABS sensor {YEAR}".
"""

private let addonEngine = """
Фокус: механика и системы двигателя.
- Алгоритм: осмотр (утечки/шумы), базовая механика (компрессия/утечки), впуск/выпуск, топливо/искра, датчики, давление топлива, вакуум (17–22 inHg на холостых — ориентир).
- Обратить внимание на ГРМ/цепь/ремень, фазы, подсос воздуха, PCV.
- Для {MAKE} {MODEL} {YEAR}: перечисли типичные слабые места двигателя/мод. года.
- Веб‑поиск (если доступен): common engine issues, TSBs по мотору.
"""

private let addonTransmission = """
Фокус: АКПП/CVT/МКПП.
- АКПП: уровень/состояние ATF (цвет/запах), адаптации, ошибки P07xx; признаки перегрева/проскальзывания, точки переключений.
- CVT: свист/пробуксовка, давление, ремень/цепь, требования к жидкости.
- МКПП/сцепление: выжим, толчки, шум выжимного, уровень масла.
- Для {MAKE} {MODEL} {YEAR}: известные проблемы коробки/прошивки/соленоидов.
- Веб‑поиск (если доступен): "{MAKE} {MODEL} transmission problems {YEAR}", TSB/recall.
"""

private let addonSuspension = """
Фокус: подвеска/рулевое.
- Симптомы: стуки/скрипы/уводы/вибрации.
- Проверить: шаровые/сайлентблоки/стойки стабилизатора/амортизаторы (bounce‑test)/подшипники ступиц/углы установки колёс.
- Дорожный тест: разные покрытия/скорости.
- Для {MAKE} {MODEL} {YEAR}: типовые слабые места.
- Веб‑поиск (если доступен): common suspension clunk issues for {MAKE} {MODEL}.
"""

private let addonElectrical = """
Фокус: электрика/проводка/CAN.
- Алгоритм: предохранители/реле, масса/питание, просадка под нагрузкой, коррозия разъёмов, диагностика по схемам, чтение ошибок по модулям (BCM/ABS/SRS/…).
- Дай таблицу "что проверить" с мультиметром и номиналами.
- Для {MAKE} {MODEL} {YEAR}: известные электрические слабые места.
- Веб‑поиск (если доступен): "{MAKE} {MODEL} wiring issue", "ground points locations".
"""

private let addonAC = """
Фокус: A/C, климат.
- Проверить: муфта компрессора, давление на СТО (ориентиры при ~25°C: низкая 25–45 psi, высокая 150–250 psi — зависят от модели), утечки/UV‑краситель, вентиляторы, датчики (датчик давления/температуры), фильтр салона.
- Учесть тип хладагента (R134a/R1234yf) по спецификации для {MAKE} {MODEL} {YEAR}.
- Симптом‑ориентированная диагностика: слабо холодит / периодически отключается / шум компрессора.
- Веб‑поиск (если доступен): common AC issues for {MAKE} {MODEL} {YEAR}.
"""

private let addonTires = """
Фокус: шины/баланс/развал/TPMS.
- Давление: по стикеру на стойке двери; износ: остаточная глубина ≥1.6 мм (лучше ≥3 мм), равномерность износа.
- Симптомы: вибрация (дисбаланс/биение), увод (схождение/кастер/кэмбер), неравномерный износ (давление/подвеска/амортизаторы).
- Ротация, свежесть (DOT), соответствие размерности/индекса.
- Для {MAKE} {MODEL} {YEAR}: типовые размеры/рекомендации.
- Веб‑поиск (если доступен): tire cupping/feathering issues for this model.
"""

// MARK: - PromptBuilder

final class PromptBuilder {
    
    private let topicAddons: [Topic: String] = [
        .general_question: addonGeneral,
        .check_engine: addonCheckEngine,
        .battery: addonBattery,
        .brakes: addonBrakes,
        .engine: addonEngine,
        .transmission: addonTransmission,
        .suspension: addonSuspension,
        .electrical: addonElectrical,
        .air_conditioning: addonAC,
        .tires: addonTires
    ]
    
    /// Строит system prompt с данными об автомобиле, истории обслуживания и тематическим add-on
    func buildSystemPrompt(
        vehicle: Vehicle,
        records: [MaintenanceRecordData],
        geo: Geo,
        topic: Topic,
        hasImages: Bool
    ) -> String {
        // Формируем историю обслуживания
        let history = records.isEmpty ? "Нет записей" : records.map { record in
            "— дата: \(record.date); пробег: \(record.mileageKm); тип: \(record.type); работы: \(record.workDone); описание: \(record.description)"
        }.joined(separator: "\n")
        
        // Получаем add-on для темы
        var topicAddon = topicAddons[topic] ?? ""
        
        // Заменяем плейсхолдеры в add-on
        topicAddon = topicAddon
            .replacingOccurrences(of: "{MAKE}", with: vehicle.make)
            .replacingOccurrences(of: "{MODEL}", with: vehicle.model)
            .replacingOccurrences(of: "{YEAR}", with: vehicle.year)
            .replacingOccurrences(of: "{ENGINE}", with: vehicle.engine)
        
        // Заменяем плейсхолдеры в базовом шаблоне
        let replacements: [String: String] = [
            "{MAKE}": vehicle.make,
            "{MODEL}": vehicle.model,
            "{YEAR}": vehicle.year,
            "{ENGINE}": vehicle.engine,
            "{FUEL}": vehicle.fuelType ?? "Не указан",
            "{DRIVETRAIN}": vehicle.drivetrain ?? "Не указан",
            "{TRANSMISSION}": vehicle.transmission ?? "Не указана",
            "{VIN}": vehicle.vin ?? "Не указан",
            "{NOTES}": vehicle.notes ?? "Нет",
            "{HAS_PHOTOS}": vehicle.hasPhotos ? "Есть" : "Нет",
            "{COUNTRY}": geo.country ?? "Не указана",
            "{CITY}": geo.city ?? "",
            "{MAINTENANCE_HISTORY}": history,
            "{ANALYZE_IMAGES_BLOCK}": hasImages ? analyzeImagesBlock : "",
            "{TOPIC_ADDON}": topicAddon
        ]
        
        var systemPrompt = baseSystemPromptTemplate
        for (key, value) in replacements {
            systemPrompt = systemPrompt.replacingOccurrences(of: key, with: value)
        }
        
        return systemPrompt
    }
    
    /// Строит массив сообщений для OpenAI-совместимого API
    /// - Parameters:
    ///   - systemPrompt: Сформированный system prompt
    ///   - chatHistory: История чата в формате [{"role": "user"/"assistant", "content": "..."}]
    ///   - userContent: Текущее сообщение пользователя (текст или изображения + опциональный текст)
    /// - Returns: Массив сообщений для API
    func buildMessages(
        systemPrompt: String,
        chatHistory: [[String: String]],
        userContent: UserContent
    ) -> [[String: Any]] {
        var messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Добавляем историю чата
        for historyItem in chatHistory {
            if let role = historyItem["role"], let content = historyItem["content"] {
                messages.append([
                    "role": role,
                    "content": content
                ])
            }
        }
        
        // Добавляем текущее сообщение пользователя
        switch userContent {
        case .text(let text):
            messages.append([
                "role": "user",
                "content": text
            ])
            
        case .images(let imagesBase64, let text):
            var contentArray: [[String: Any]] = []
            
            // Добавляем изображения
            for imageBase64 in imagesBase64 {
                contentArray.append([
                    "type": "image_url",
                    "image_url": [
                        "url": "data:image/jpeg;base64,\(imageBase64)"
                    ]
                ])
            }
            
            // Добавляем текст, если есть
            if let text = text, !text.isEmpty {
                contentArray.append([
                    "type": "text",
                    "text": text
                ])
            }
            
            messages.append([
                "role": "user",
                "content": contentArray
            ])
        }
        
        return messages
    }
}

// MARK: - Extensions for Core Data Models

extension PromptBuilder {
    /// Конвертирует Car в Vehicle
    static func vehicle(from car: Car?) -> Vehicle? {
        guard let car = car else { return nil }
        
        return Vehicle(
            make: car.brand ?? "",
            model: car.model ?? "",
            year: car.year > 0 ? "\(car.year)" : "",
            engine: car.engine,
            fuelType: car.fuelType,
            drivetrain: car.driveType,
            transmission: car.transmission,
            vin: car.vin,
            notes: car.notes,
            hasPhotos: car.photoData != nil
        )
    }
    
    /// Конвертирует User в Geo
    static func geo(from user: User) -> Geo {
        return Geo(
            country: user.country,
            city: user.city
        )
    }
    
    /// Конвертирует массив MaintenanceRecord (Core Data) в массив MaintenanceRecordData (PromptBuilder)
    static func maintenanceRecords(from records: [MaintenanceRecord]) -> [MaintenanceRecordData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return records.map { record in
            MaintenanceRecordData(
                date: dateFormatter.string(from: record.date),
                mileageKm: record.mileage > 0 ? "\(record.mileage)" : "0",
                type: record.serviceType ?? "Не указан",
                workDone: record.worksPerformed ?? "",
                description: record.serviceDescription ?? ""
            )
        }
    }
    
    /// Конвертирует Topic из строки кнопки
    static func topic(from buttonTitle: String) -> Topic? {
        switch buttonTitle.lowercased() {
        case "general question":
            return .general_question
        case "check engine":
            return .check_engine
        case "battery":
            return .battery
        case "brake system":
            return .brakes
        case "engine":
            return .engine
        case "transmission":
            return .transmission
        case "suspension":
            return .suspension
        case "electrical":
            return .electrical
        case "ac system":
            return .air_conditioning
        case "tires":
            return .tires
        default:
            return nil
        }
    }
}

