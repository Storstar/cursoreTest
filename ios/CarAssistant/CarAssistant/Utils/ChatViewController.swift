//
//  ChatViewController.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - ChatViewController

/// UIViewController для чата
class ChatViewController: UIViewController {
    // MARK: - Properties
    
    private var hostingController: UIHostingController<ChatContentView>?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    // MARK: - Setup
    
    func embedChatContent(_ contentView: ChatContentView) {
        // Удаляем старый hosting controller если есть
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Создаем новый hosting controller
        let controller = UIHostingController(rootView: contentView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем как child
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        // Устанавливаем constraints
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController = controller
    }
}
