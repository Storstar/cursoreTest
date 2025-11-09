import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @StateObject private var maintenanceViewModel = MaintenanceViewModel()
    @State private var selectedTab: Tab = .chats
    
    enum Tab: String, CaseIterable {
        case chats = "Чаты"
        case maintenance = "ТО"
        case profile = "Профиль"
        
        var icon: String {
            switch self {
            case .chats: return "message.fill"
            case .maintenance: return "wrench.and.screwdriver.fill"
            case .profile: return "person.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Вкладка "Чаты"
            ChatsListView()
                .tabItem {
                    Label(Tab.chats.rawValue, systemImage: Tab.chats.icon)
                }
                .tag(Tab.chats)
            
            // Вкладка "ТО"
            MaintenanceView()
                .environmentObject(maintenanceViewModel)
                .tabItem {
                    Label(Tab.maintenance.rawValue, systemImage: Tab.maintenance.icon)
                }
                .tag(Tab.maintenance)
            
            // Вкладка "Профиль"
            SettingsView()
                .tabItem {
                    Label(Tab.profile.rawValue, systemImage: Tab.profile.icon)
                }
                .tag(Tab.profile)
        }
        .task {
            // Используем task вместо onAppear для асинхронной загрузки
            guard !Task.isCancelled else { return }
            if let user = authViewModel.currentUser {
                // Загружаем автомобили и восстанавливаем сохраненный выбор активного авто
                await carViewModel.loadCarsAsync(for: user)
                guard !Task.isCancelled else { return }
                carViewModel.loadCar(for: user) // Загружаем сохраненный выбор активного авто
            }
        }
    }
}

