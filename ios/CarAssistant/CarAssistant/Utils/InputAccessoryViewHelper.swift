//
//  InputAccessoryViewHelper.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - InputAccessoryViewHelper

/// UIViewRepresentable для установки inputAccessoryView на UITextView
struct InputAccessoryViewHelper: UIViewRepresentable {
    let inputBar: ChatInputBar
    @Binding var container: InputAccessoryContainerView?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.frame = .zero
        view.isHidden = true
        
        // Создаем контейнер для inputAccessoryView если его еще нет
        if container == nil {
            let containerView = InputAccessoryContainerView()
            containerView.setup(with: inputBar)
            container = containerView
        }
        
        // Устанавливаем inputAccessoryView на все UITextView в иерархии
        if let containerView = container {
            DispatchQueue.main.async {
                setupInputAccessoryView(containerView)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Обновляем контейнер при изменении inputBar
        if let containerView = container {
            containerView.setup(with: inputBar)
            setupInputAccessoryView(containerView)
        } else {
            // Если контейнер еще не создан, создаем его
            let containerView = InputAccessoryContainerView()
            containerView.setup(with: inputBar)
            container = containerView
            DispatchQueue.main.async {
                setupInputAccessoryView(containerView)
            }
        }
    }
    
    private func setupInputAccessoryView(_ accessoryView: InputAccessoryContainerView) {
        // Находим все UITextView в иерархии и устанавливаем inputAccessoryView
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            findAndSetupTextViews(in: rootViewController, accessoryView: accessoryView)
        }
    }
    
    private func findAndSetupTextViews(in viewController: UIViewController, accessoryView: InputAccessoryContainerView) {
        // Рекурсивно ищем UITextView в иерархии
        viewController.view.subviews.forEach { subview in
            if let textView = subview as? UITextView {
                textView.inputAccessoryView = accessoryView
            }
        }
        
        viewController.children.forEach { child in
            findAndSetupTextViews(in: child, accessoryView: accessoryView)
        }
    }
}

