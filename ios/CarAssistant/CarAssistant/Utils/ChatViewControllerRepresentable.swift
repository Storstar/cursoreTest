//
//  ChatViewControllerRepresentable.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - ChatViewControllerRepresentable

/// UIViewControllerRepresentable для встраивания ChatViewController в SwiftUI
struct ChatViewControllerRepresentable: UIViewControllerRepresentable {
    let chatContent: ChatContentView
    @Binding var chatViewController: ChatViewController?
    
    func makeUIViewController(context: Context) -> ChatViewController {
        let controller = ChatViewController()
        controller.embedChatContent(chatContent)
        chatViewController = controller
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ChatViewController, context: Context) {
        // Обновляем chatContent при изменении
        uiViewController.embedChatContent(chatContent)
    }
}
