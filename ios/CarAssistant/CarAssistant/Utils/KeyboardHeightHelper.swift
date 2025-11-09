import SwiftUI
import UIKit
import Combine

// Helper для отслеживания высоты клавиатуры
class KeyboardHeightHelper: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var isKeyboardVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Отслеживаем появление клавиатуры
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let self = self,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                let height = keyboardFrame.height
                self.keyboardHeight = height
                self.isKeyboardVisible = true
            }
            .store(in: &cancellables)
        
        // Отслеживаем скрытие клавиатуры
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.keyboardHeight = 0
                self.isKeyboardVisible = false
            }
            .store(in: &cancellables)
        
        // Отслеживаем изменение размера клавиатуры (например, при переключении панели подсказок)
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                guard let self = self,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                let height = keyboardFrame.height
                self.keyboardHeight = height
            }
            .store(in: &cancellables)
    }
    
    deinit {
        // Явная отписка от всех подписок (cancellables автоматически отпишутся, но лучше явно)
        cancellables.removeAll()
    }
}

