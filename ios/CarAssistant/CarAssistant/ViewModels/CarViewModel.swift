import Foundation
import CoreData
import SwiftUI

@MainActor
class CarViewModel: ObservableObject {
    @Published var car: Car?
    @Published var cars: [Car] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // Ключ для сохранения выбранного авто в UserDefaults
    private let selectedCarIdKey = "selectedCarId"
    
    // Кэш для избежания лишних запросов
    private var lastLoadedUserId: UUID?
    private var lastLoadTime: Date?
    private let cacheTimeout: TimeInterval = 5.0 // 5 секунд кэш
    
    private var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }
    
    let brands = ["Toyota", "Honda", "BMW", "Mercedes-Benz", "Audi", "Volkswagen", "Ford", "Chevrolet", "Nissan", "Hyundai", "Kia", "Mazda", "Subaru", "Lexus", "Volvo"]
    let engines = ["1.0", "1.2", "1.4", "1.6", "1.8", "2.0", "2.2", "2.5", "3.0", "3.5", "4.0", "5.0", "Электрический", "Гибрид"]
    
    var years: [Int16] {
        let currentYear = Int16(Calendar.current.component(.year, from: Date()))
        return Array(stride(from: currentYear, through: 1900, by: -1))
    }
    
    func loadCar(for user: User) {
        // Сначала загружаем все автомобили
        loadCars(for: user)
        
        // Пытаемся загрузить сохраненный выбор пользователя
        if let savedCarIdString = UserDefaults.standard.string(forKey: selectedCarIdKey),
           let savedCarId = UUID(uuidString: savedCarIdString),
           let savedCar = cars.first(where: { $0.id == savedCarId }) {
            car = savedCar
        } else if !cars.isEmpty {
            // Если сохраненного выбора нет, берем первый автомобиль
            car = cars.first
            // Сохраняем выбор
            if let firstCar = cars.first {
                saveSelectedCar(firstCar)
            }
        } else {
            car = nil
        }
    }
    
    // Загрузить все автомобили пользователя (синхронная версия для обратной совместимости)
    func loadCars(for user: User) {
        // Проверяем кэш
        if let lastUserId = lastLoadedUserId,
           let lastTime = lastLoadTime,
           lastUserId == user.id,
           Date().timeIntervalSince(lastTime) < cacheTimeout,
           !cars.isEmpty {
            return // Используем кэшированные данные
        }
        
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Car.year, ascending: false)]
        fetchRequest.fetchBatchSize = 20 // Оптимизация для больших списков
        
        do {
            let fetchedCars = try context.fetch(fetchRequest)
            cars = fetchedCars
            lastLoadedUserId = user.id
            lastLoadTime = Date()
            
            // Загружаем сохраненный выбор пользователя
            if let savedCarIdString = UserDefaults.standard.string(forKey: selectedCarIdKey),
               let savedCarId = UUID(uuidString: savedCarIdString),
               let savedCar = cars.first(where: { $0.id == savedCarId }) {
                car = savedCar
            } else if car == nil && !cars.isEmpty {
                car = cars.first
                if let firstCar = cars.first {
                    saveSelectedCar(firstCar)
                }
            }
        } catch {
            print("Ошибка загрузки автомобилей: \(error.localizedDescription)")
            errorMessage = "Ошибка загрузки автомобилей: \(error.localizedDescription)"
        }
    }
    
    // Асинхронная версия загрузки для лучшей производительности
    func loadCarsAsync(for user: User) async {
        // Проверяем кэш
        if let lastUserId = lastLoadedUserId,
           let lastTime = lastLoadTime,
           lastUserId == user.id,
           Date().timeIntervalSince(lastTime) < cacheTimeout,
           !cars.isEmpty {
            return // Используем кэшированные данные
        }
        
        isLoading = true
        errorMessage = nil
        
        // Используем background context для асинхронной загрузки
        let backgroundContext = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        
        await Task.detached { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user == %@", user)
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Car.year, ascending: false)]
            fetchRequest.fetchBatchSize = 20
            
            do {
                let fetchedCars = try backgroundContext.fetch(fetchRequest)
                let objectIDs = fetchedCars.map { $0.objectID }
                
                await MainActor.run {
                    // Преобразуем objectIDs в объекты главного контекста
                    let mainContext = CoreDataManager.shared.viewContext
                    let mainCars = objectIDs.compactMap { mainContext.object(with: $0) as? Car }
                    
                    self.cars = mainCars
                    self.lastLoadedUserId = user.id
                    self.lastLoadTime = Date()
                    
                    // Загружаем сохраненный выбор пользователя
                    if let savedCarIdString = UserDefaults.standard.string(forKey: self.selectedCarIdKey),
                       let savedCarId = UUID(uuidString: savedCarIdString),
                       let savedCar = mainCars.first(where: { $0.id == savedCarId }) {
                        self.car = savedCar
                    } else if self.car == nil && !self.cars.isEmpty {
                        self.car = self.cars.first
                        if let firstCar = self.cars.first {
                            self.saveSelectedCar(firstCar)
                        }
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Ошибка загрузки автомобилей: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.value
    }
    
    // Инвалидировать кэш
    func invalidateCache() {
        lastLoadedUserId = nil
        lastLoadTime = nil
    }
    
    // Выбрать автомобиль
    func selectCar(_ selectedCar: Car) {
        car = selectedCar
        saveSelectedCar(selectedCar)
    }
    
    // Сохранить выбор автомобиля в UserDefaults
    private func saveSelectedCar(_ car: Car) {
        UserDefaults.standard.set(car.id.uuidString, forKey: selectedCarIdKey)
    }
    
    func saveCar(brand: String, model: String, year: Int16, engine: String, fuelType: String? = nil, driveType: String? = nil, transmission: String? = nil, vin: String? = nil, photoData: Data? = nil, notes: String? = nil, for user: User) {
        errorMessage = nil
        
        if let error = Validators.validateBrand(brand) {
            errorMessage = error
            return
        }
        
        if let error = Validators.validateModel(model) {
            errorMessage = error
            return
        }
        
        if let error = Validators.validateYear(year) {
            errorMessage = error
            return
        }
        
        if let error = Validators.validateEngine(engine) {
            errorMessage = error
            return
        }
        
        // ВАЖНО: Проверяем, что мы НЕ обновляем существующий автомобиль
        let carsCountBefore = cars.count
        let currentCarId = car?.id
        
        // Создаем новый автомобиль (поддержка множественных авто)
        // ВАЖНО: Всегда создаем новый объект, никогда не обновляем существующий
        let newCar = Car(context: context)
        let newCarId = UUID()
        newCar.id = newCarId
        newCar.brand = brand
        newCar.model = model
        newCar.year = year
        newCar.engine = engine
        newCar.fuelType = fuelType
        newCar.driveType = driveType
        newCar.transmission = transmission
        newCar.vin = vin
        // Сжимаем изображение перед сохранением в Core Data для экономии памяти
        // Если photoData уже сжат, используем его, иначе сжимаем
        if let photoData = photoData {
            // Проверяем размер - если больше 500KB, сжимаем еще сильнее
            if photoData.count > 500_000 {
                // Пытаемся создать UIImage и сжать заново
                // Используем downsampling для экономии памяти при проверке размера
                if let image = ImageOptimizer.downsampleImage(data: photoData, to: CGSize(width: 800, height: 800)) {
                    newCar.photoData = ImageOptimizer.compressImage(image, maxDimension: 800, compressionQuality: 0.6)
                } else {
                    newCar.photoData = photoData
                }
            } else {
                newCar.photoData = photoData
            }
        } else {
            newCar.photoData = nil
        }
        newCar.notes = notes
        newCar.user = user
        
        print("🔵 Создан НОВЫЙ автомобиль: \(brand) \(model) \(year)")
        print("🔵 ID нового авто: \(newCarId.uuidString)")
        if let currentId = currentCarId {
            print("🔵 ID текущего авто: \(currentId.uuidString)")
        } else {
            print("🔵 Текущего авто нет")
        }
        print("🔵 Автомобилей ДО сохранения: \(carsCountBefore)")
        
        // Сохраняем изменения
        CoreDataManager.shared.save()
        
        // Инвалидируем кэш и загружаем все автомобили
        invalidateCache()
        loadCars(for: user)
        
        // ВАЖНО: НЕ устанавливаем новый автомобиль как текущий автоматически
        // Пользователь может выбрать его позже
        // car = newCar // Закомментировано, чтобы не переключать текущий авто
        
        let carsCountAfter = cars.count
        print("🔵 Автомобилей ПОСЛЕ сохранения: \(carsCountAfter)")
        
        if carsCountAfter <= carsCountBefore {
            print("❌ ОШИБКА: Количество автомобилей не увеличилось! Возможно, автомобиль не был создан.")
        } else {
            print("✅ Успешно: Количество автомобилей увеличилось с \(carsCountBefore) до \(carsCountAfter)")
        }
        
        // Проверяем, что текущий автомобиль не изменился
        if let currentId = currentCarId, let currentCar = car {
            if currentCar.id != currentId {
                print("⚠️ ВНИМАНИЕ: Текущий автомобиль изменился!")
            } else {
                print("✅ Текущий автомобиль не изменился")
            }
        }
    }
    
    func getModels(for brand: String) -> [String] {
        return CarBrandsData.getModels(for: brand)
    }
    
    // Удалить автомобиль
    func deleteCar(_ car: Car, for user: User) {
        // Сохраняем objectID перед удалением
        let deletedCarObjectID = car.objectID
        let wasCurrentCar = self.car?.objectID == deletedCarObjectID
        
        // Удаляем автомобиль
        context.delete(car)
        
        // Сохраняем изменения
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении после удаления: \(error)")
            return
        }
        
        // Инвалидируем кэш и загружаем обновленный список
        invalidateCache()
        loadCars(for: user)
        
        // Если удалили текущий авто, выбираем первый из оставшихся и сохраняем выбор
        if wasCurrentCar {
            if let firstCar = cars.first {
                self.car = firstCar
                saveSelectedCar(firstCar)
            } else {
                self.car = nil
                // Очищаем сохраненный выбор, если нет автомобилей
                UserDefaults.standard.removeObject(forKey: selectedCarIdKey)
            }
        }
    }
}
