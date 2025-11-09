import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CarAssistant")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error.localizedDescription)")
                return
            }
            // Создаем тестового пользователя admin/admin при первом запуске (асинхронно)
            DispatchQueue.main.async {
                self.createTestUserIfNeeded()
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.undoManager = nil // Отключаем undo для производительности
        // Оптимизация производительности
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error.localizedDescription)")
            }
        }
    }
    
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        save()
    }
    
    func createTestUserIfNeeded() {
        let context = viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", "admin@admin.com")
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if let existingUser = existingUsers.first {
                // Обновляем пароль существующего пользователя
                existingUser.password = "admin1"
                existingUser.username = "admin"
                save()
                print("✅ Тестовый пользователь admin/admin1 обновлен")
            } else {
                // Создаем тестового пользователя admin/admin1
                let testUser = User(context: context)
                testUser.id = UUID()
                testUser.username = "admin"
                testUser.email = "admin@admin.com"
                testUser.password = "admin1"
                save()
                print("✅ Тестовый пользователь admin/admin1 создан")
            }
        } catch {
            print("❌ Ошибка создания тестового пользователя: \(error.localizedDescription)")
        }
    }
}
