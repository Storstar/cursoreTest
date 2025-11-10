//
//  InputAccessoryView.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - InputAccessoryView

/// UIView для inputAccessoryView (инпут-бар над клавиатурой)
class InputAccessoryContainerView: UIView {
    private var hostingController: UIHostingController<AnyView>?
    
    func setup(with inputBar: ChatInputBar) {
        // Удаляем старый hosting controller если есть
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Создаем новый hosting controller с AnyView для поддержки модификаторов
        let wrappedView = AnyView(inputBar.background(.ultraThinMaterial))
        let controller = UIHostingController(rootView: wrappedView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем view
        addSubview(controller.view)
        
        // Устанавливаем constraints
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        hostingController = controller
        
        // Временный яркий фон для диагностики
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        
        // Логируем создание
        print("📱 InputAccessoryContainerView setup, height: \(intrinsicContentSize.height)")
    }
    
    override var intrinsicContentSize: CGSize {
        // Вычисляем высоту на основе контента
        hostingController?.view.setNeedsLayout()
        hostingController?.view.layoutIfNeeded()
        
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        let contentHeight = hostingController?.view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height ?? 52
        
        // Минимальная высота ~48-52pt для 1 строки
        let minHeight: CGFloat = 52
        let finalHeight = max(minHeight, contentHeight)
        
        // Safe area bottom будет добавлен системой автоматически
        return CGSize(width: UIView.noIntrinsicMetric, height: finalHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}

