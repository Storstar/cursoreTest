//
//  TabBarAccessor.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - TabBarAccessor

/// Вспомогательный компонент для доступа к TabBar в SwiftUI
struct TabBarAccessor: UIViewControllerRepresentable {
    let callback: (UITabBar) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        DispatchQueue.main.async {
            if let tabBarController = viewController.tabBarController {
                callback(tabBarController.tabBar)
            } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let tabBarController = window.rootViewController?.findTabBarController() {
                callback(tabBarController.tabBar)
            }
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            if let tabBarController = uiViewController.tabBarController {
                callback(tabBarController.tabBar)
            } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let tabBarController = window.rootViewController?.findTabBarController() {
                callback(tabBarController.tabBar)
            }
        }
    }
}

