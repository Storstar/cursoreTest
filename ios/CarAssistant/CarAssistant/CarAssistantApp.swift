import SwiftUI

@main
struct CarAssistantApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var carViewModel = CarViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - App State Manager
    
    private var appStateManager: AppStateManager {
        AppStateManager.shared
    }
    
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(carViewModel)
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    // Отмечаем холодный старт при первом запуске
                    appStateManager.markColdStart()
                }
                .onChange(of: scenePhase) { newPhase in
                    handleScenePhaseChange(newPhase)
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    // MARK: - Private Methods
    
    /// Обработать изменение фазы сцены
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            // Приложение ушло в фон - сохраняем состояние и освобождаем ресурсы
            // Состояние уже сохраняется в ChatView при изменениях
            appStateManager.markEnteredBackground()
            
            // Освобождаем память при переходе в фон
            // Очищаем кэш автомобилей для экономии памяти
            carViewModel.invalidateCache()
            
            // Уведомляем об освобождении памяти
            NotificationCenter.default.post(name: NSNotification.Name("AppDidEnterBackground"), object: nil)
        case .inactive:
            // Приложение стало неактивным (переход между состояниями)
            break
        case .active:
            // Приложение стало активным
            if appStateManager.isColdStart {
                // Если это холодный старт, состояние уже установлено
                // Сбрасываем флаг после первого запуска
                appStateManager.markColdStart()
            } else {
                // Восстановление из фона - восстанавливаем состояние
                appStateManager.markResumeFromBackground()
            }
        @unknown default:
            break
        }
    }
    
    /// Обработать диплинк
    private func handleDeepLink(_ url: URL) {
        // Отмечаем, что приложение запущено через диплинк
        appStateManager.markDeepLinkLaunch()
        
        // Парсим URL для определения, какой экран открыть
        // Пример: carassistant://chat/{chatId}
        let components = url.pathComponents
        
        if components.count >= 2 && components[1] == "chat" {
            // Открываем конкретный чат
            if components.count >= 3,
               let chatIdString = components.last,
               let chatId = UUID(uuidString: chatIdString) {
                // Сохраняем ID чата для открытия
                appStateManager.currentChatId = chatId
                appStateManager.saveState(showChatHistory: false, currentChatId: chatId)
            }
        }
        // Можно добавить обработку других типов диплинков
    }
}
