//
//  MultilineTextField.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - MultilineTextField

/// Кастомное многострочное текстовое поле (как в Telegram/WhatsApp)
/// При длинном тексте вводимая строка всегда видна, старший текст плавно уходит вверх
struct MultilineTextField: UIViewRepresentable {
    // MARK: - Properties
    
    @Binding var text: String
    let placeholder: String
    let maxLines: Int // Максимум строк до внутреннего скролла (4 для Telegram)
    @Binding var isFocused: Bool
    @Binding var contentHeight: CGFloat // Высота контента для динамического изменения размера
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = .label
        textView.backgroundColor = .clear
        
        // Точные отступы как в Telegram: top/bottom 6pt, left/right 12pt
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        textView.textContainer.lineFragmentPadding = 0
        
        // Максимум строк до внутреннего скролла
        textView.textContainer.maximumNumberOfLines = 0 // Убираем ограничение, управляем через высоту
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        // Включаем скролл, когда контент превышает max
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false // Скрываем индикатор прокрутки
        textView.showsHorizontalScrollIndicator = false
        textView.keyboardDismissMode = .interactive
        textView.returnKeyType = .default
        textView.enablesReturnKeyAutomatically = false
        
        // Включаем allowsNonContiguousLayout для корректной прокрутки к каретке
        textView.layoutManager.allowsNonContiguousLayout = true
        
        // Устанавливаем placeholder
        textView.text = placeholder
        textView.textColor = .placeholderText
        
        // Показываем конец текста, а не начало
        textView.contentInsetAdjustmentBehavior = .never
        
        // Отключаем автоматическое изменение размера
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Защита от циклов перерасчета
        guard !context.coordinator.isUpdating else { return }
        
        // Обновляем parent в coordinator для доступа к актуальным значениям
        context.coordinator.parent = self
        
        // Обновляем текст только если он изменился извне и UITextView не в процессе редактирования
        let currentText = uiView.text ?? ""
        let isEditing = uiView.isFirstResponder
        
        // Placeholder виден только когда поле пустое и не в фокусе
        if !isEditing {
            if text.isEmpty {
                if currentText != placeholder {
                    uiView.text = placeholder
                    uiView.textColor = .placeholderText
                }
            } else {
                // Обновляем текст только если он изменился извне
                if currentText != text && currentText != placeholder {
                    uiView.text = text
                    uiView.textColor = .label
                }
            }
        }
        
        // Обновляем фокус
        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
        
        // Прокручиваем к концу текста при изменении текста извне
        if !text.isEmpty && !isEditing {
            DispatchQueue.main.async {
                let textToScroll = uiView.text ?? ""
                if !textToScroll.isEmpty && textToScroll != placeholder {
                    let bottom = NSRange(location: textToScroll.count, length: 0)
                    uiView.scrollRangeToVisible(bottom)
                }
            }
        }
        
        // Обновляем высоту контента
        DispatchQueue.main.async {
            let textToMeasure = (text.isEmpty || text == placeholder) ? " " : text
            let tempText = uiView.text
            uiView.text = textToMeasure
            let newHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width > 0 ? uiView.bounds.width : UIScreen.main.bounds.width - 100, height: .greatestFiniteMagnitude)).height
            uiView.text = tempText
            
            if abs(context.coordinator.lastContentHeight - newHeight) > 1 {
                context.coordinator.lastContentHeight = newHeight
                context.coordinator.updateContentHeight(newHeight)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, contentHeight: $contentHeight)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextField
        var contentHeight: Binding<CGFloat>
        var isUpdating = false // Защита от циклов перерасчета (internal для доступа из updateUIView)
        var lastContentHeight: CGFloat = 0
        
        init(parent: MultilineTextField, contentHeight: Binding<CGFloat>) {
            self.parent = parent
            self.contentHeight = contentHeight
        }
        
        func updateContentHeight(_ height: CGFloat) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.contentHeight.wrappedValue = height
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Защита от циклов перерасчета
            guard !isUpdating else { return }
            
            let currentText = textView.text ?? ""
            
            // Если текст равен placeholder, очищаем его
            if currentText == parent.placeholder {
                textView.text = ""
                textView.textColor = .label
                parent.text = ""
                return
            }
            
            // Обновляем родительский текст
            isUpdating = true
            parent.text = currentText
            isUpdating = false
            
            // Убеждаемся, что цвет текста правильный
            if !currentText.isEmpty {
                textView.textColor = .label
            }
            
            // Обновляем высоту контента
            DispatchQueue.main.async {
                let width = textView.bounds.width > 0 ? textView.bounds.width : UIScreen.main.bounds.width - 100
                let newHeight = textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
                if abs(self.lastContentHeight - newHeight) > 1 {
                    self.lastContentHeight = newHeight
                    self.updateContentHeight(newHeight)
                }
            }
            
            // Прокручиваем к каретке (scroll to caret) - каретка и последняя строка всегда видны
            // Это обеспечивает, что вводимая строка всегда видна, а старый текст уходит вверх
            DispatchQueue.main.async {
                if !currentText.isEmpty {
                    // Находим позицию каретки
                    let selectedRange = textView.selectedRange
                    let caretLocation = selectedRange.location
                    
                    // Прокручиваем так, чтобы каретка была видна внизу
                    let range = NSRange(location: caretLocation, length: 0)
                    textView.scrollRangeToVisible(range)
                    
                    // Дополнительно прокручиваем к концу, если каретка в конце
                    if caretLocation == currentText.count {
                        let bottom = NSRange(location: currentText.count, length: 0)
                        textView.scrollRangeToVisible(bottom)
                    }
                }
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            let currentText = textView.text ?? ""
            // Если начинаем редактирование и текст равен placeholder, очищаем его
            if currentText == parent.placeholder {
                textView.text = ""
                textView.textColor = .label
                parent.text = ""
            }
            parent.isFocused = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            let currentText = textView.text ?? ""
            // Если текст пустой, показываем placeholder
            if currentText.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .placeholderText
                parent.text = ""
            }
            parent.isFocused = false
        }
    }
}

