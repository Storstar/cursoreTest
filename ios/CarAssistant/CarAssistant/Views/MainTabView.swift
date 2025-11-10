//
//  MainTabView.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - MainTabView

/// Главный экран с табами приложения
struct MainTabView: View {
    // MARK: - Environment Objects
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    
    // MARK: - State Properties
    
    @State private var selectedTab: Tab = .chats
    @State private var showTabBar = true
    
    // MARK: - Tab Enum
    
    /// Перечисление вкладок приложения
    enum Tab: String, CaseIterable {
        case chats = "Чаты"
        case maintenance = "ТО"
        case profile = "Профиль"
        
        /// Иконка для вкладки
        var icon: String {
            switch self {
            case .chats:
                return "bubble.left.and.bubble.right.fill"
            case .maintenance:
                return "wrench.and.screwdriver.fill"
            case .profile:
                return "person.fill"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Красивый градиентный фон для всего приложения (авто ассистент)
            appGradientBackground
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                chatsTab
                maintenanceTab
                profileTab
            }
            .task {
                loadInitialData()
            }
            .onAppear {
                updateTabBarVisibility()
                configureTabBarAppearance()
            }
            .onChange(of: showTabBar) { _ in
                updateTabBarVisibility()
            }
            .background(TabBarAccessor { tabBar in
                tabBar.isHidden = !showTabBar
                configureTabBarAppearance()
            })
        }
    }
    
    /// Градиентный фон приложения (авто ассистент)
    private var appGradientBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.97, blue: 1.0),      // Светло-голубой (верх)
                Color(red: 0.92, green: 0.95, blue: 0.98),    // Светло-серо-голубой (середина)
                Color(red: 0.88, green: 0.92, blue: 0.96)     // Светло-серый (низ)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Настроить внешний вид TabBar (убрать цветной фон)
    private func configureTabBarAppearance() {
        DispatchQueue.main.async {
            // Настраиваем прозрачный appearance для TabBar
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            
            // Настраиваем для всех состояний
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Делаем TabBar прозрачным
            UITabBar.appearance().isTranslucent = true
        }
    }
    
    /// Обновить видимость TabBar
    private func updateTabBarVisibility() {
        // Обновление через UIKit
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController?.findTabBarController() {
                tabBarController.tabBar.isHidden = !showTabBar
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Вкладка "Чаты"
    private var chatsTab: some View {
        ChatView(onChatStateChange: { isActiveChat in
            // Скрываем TabBar когда открыт активный чат
            showTabBar = !isActiveChat
        })
        .tabItem {
            Label(Tab.chats.rawValue, systemImage: Tab.chats.icon)
        }
        .tag(Tab.chats)
    }
    
    /// Вкладка "ТО"
    private var maintenanceTab: some View {
        MaintenanceView()
            .tabItem {
                Label(Tab.maintenance.rawValue, systemImage: Tab.maintenance.icon)
            }
            .tag(Tab.maintenance)
    }
    
    /// Вкладка "Профиль"
    private var profileTab: some View {
        SettingsView()
            .tabItem {
                Label(Tab.profile.rawValue, systemImage: Tab.profile.icon)
            }
            .tag(Tab.profile)
    }
    
    // MARK: - Helper Methods
    
    /// Загрузить начальные данные
    private func loadInitialData() {
        guard let user = authViewModel.currentUser else { return }
        
        Task {
            // Загружаем автомобили и восстанавливаем сохраненный выбор активного авто
            await carViewModel.loadCarsAsync(for: user)
            carViewModel.loadCar(for: user)
        }
    }
}
