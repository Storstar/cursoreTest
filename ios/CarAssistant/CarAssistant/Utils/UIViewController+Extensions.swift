//
//  UIViewController+Extensions.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import UIKit

extension UIViewController {
    /// Найти TabBarController в иерархии
    func findTabBarController() -> UITabBarController? {
        if let tabBarController = self as? UITabBarController {
            return tabBarController
        }
        
        for child in children {
            if let tabBarController = child.findTabBarController() {
                return tabBarController
            }
        }
        
        return nil
    }
}

