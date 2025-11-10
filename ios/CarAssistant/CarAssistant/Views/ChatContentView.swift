//
//  ChatContentView.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI

// MARK: - ChatContentView

/// Контент чата (без инпут-бара, который в inputAccessoryView)
struct ChatContentView: View {
    // MARK: - Properties
    
    let messages: [ChatMessage]
    let keyboardHeight: CGFloat
    let onTapToDismissKeyboard: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            messagesScrollView
        }
    }
    
    // MARK: - Subviews
    
    /// Градиентный фон экрана
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.97, blue: 0.99), // #F6F7FB
                Color(red: 0.88, green: 0.92, blue: 0.97)  // #E1EBF7
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Скролл-вью с сообщениями
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if messages.isEmpty {
                        emptyStateView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, keyboardHeight > 0 ? 4 : 100) // Минимальный отступ снизу когда клавиатура открыта (4pt), или отступ для панели ввода когда закрыта (100pt)
            }
            .scrollBounceBehavior(.basedOnSize) // Ограничиваем bounce эффект на основе размера контента (iOS 16+)
            .onAppear {
                // Один автоскролл при первом появлении (к низу)
                if !messages.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastMessage = messages.last {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .onChange(of: messages.last?.id) { newLastMessageId in
                // При изменении последнего сообщения (отправка нового или получение ответа): прокручиваем к нему
                if let lastMessageId = newLastMessageId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
            .onChange(of: keyboardHeight) { newHeight in
                // При появлении/скрытии клавиатуры прокручиваем к последнему сообщению
                if newHeight > 0 && !messages.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let lastMessage = messages.last {
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        // Тап по ленте скрывает клавиатуру
                        onTapToDismissKeyboard()
                    }
            )
        }
    }
    
    /// Пустое состояние (когда нет сообщений)
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Начните диалог с ИИ-помощником")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Прокрутить к последнему сообщению
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = messages.last else { return }
        
        // Прокручиваем к последнему сообщению с небольшой задержкой для корректного отображения
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

