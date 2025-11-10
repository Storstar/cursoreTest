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
    let isLoadingHistory: Bool
    let hasLoadedAllMessages: Bool
    let onTapToDismissKeyboard: () -> Void
    let onLoadMoreMessages: () -> Void
    
    init(
        messages: [ChatMessage],
        keyboardHeight: CGFloat,
        isLoadingHistory: Bool,
        hasLoadedAllMessages: Bool,
        onTapToDismissKeyboard: @escaping () -> Void,
        onLoadMoreMessages: @escaping () -> Void
    ) {
        self.messages = messages
        self.keyboardHeight = keyboardHeight
        self.isLoadingHistory = isLoadingHistory
        self.hasLoadedAllMessages = hasLoadedAllMessages
        self.onTapToDismissKeyboard = onTapToDismissKeyboard
        self.onLoadMoreMessages = onLoadMoreMessages
    }
    
    // MARK: - State Properties
    
    @State private var isFirstAppear = true
    @State private var lastMessageCount = 0
    @State private var firstMessageVisible = false
    @State private var anchorMessageId: UUID?
    @State private var lastLoadMoreTime: Date?
    
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
                        // Индикатор загрузки истории вверху
                        if isLoadingHistory {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                            .id(message.id)
                                .onAppear {
                                    // Отслеживаем появление первого сообщения для подгрузки истории
                                    if message.id == messages.first?.id {
                                        firstMessageVisible = true
                                        // Сохраняем ID первого сообщения для сохранения позиции скролла
                                        anchorMessageId = message.id
                                        // Если не все сообщения загружены, загружаем больше
                                        // Добавляем задержку, чтобы не вызывать слишком часто
                                        if !hasLoadedAllMessages && !isLoadingHistory {
                                            let now = Date()
                                            if let lastTime = lastLoadMoreTime {
                                                // Защита от множественных вызовов - минимум 0.5 секунды между вызовами
                                                if now.timeIntervalSince(lastTime) < 0.5 {
                                                    return
                                                }
                                            }
                                            lastLoadMoreTime = now
                                            onLoadMoreMessages()
                                        }
                                    }
                                }
                                .onDisappear {
                                    // Отслеживаем исчезновение первого сообщения
                                    if message.id == messages.first?.id {
                                        firstMessageVisible = false
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, keyboardHeight > 0 ? 4 : 100) // Минимальный отступ снизу когда клавиатура открыта (4pt), или отступ для панели ввода когда закрыта (100pt)
            }
            .scrollBounceBehavior(.basedOnSize) // Ограничиваем bounce эффект на основе размера контента (iOS 16+)
            .onAppear {
                // При первом появлении делаем мгновенный скролл без анимации
                // чтобы не тратить ресурсы на рендеринг всех сообщений сверху вниз
                if isFirstAppear && !messages.isEmpty {
                    if let lastMessage = messages.last {
                        // Мгновенный скролл без анимации для оптимизации
                        // Используем Task для выполнения после рендеринга
                        Task { @MainActor in
                            // Небольшая задержка для гарантии, что элемент отрендерен
                            try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 секунды
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    isFirstAppear = false
                    lastMessageCount = messages.count
                }
            }
            .onChange(of: isLoadingHistory) { isLoading in
                // При завершении загрузки истории сохраняем позицию скролла
                if !isLoading && anchorMessageId != nil {
                    // Сохраняем позицию скролла, скролля к якорному сообщению
                    if let anchorId = anchorMessageId {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(anchorId, anchor: .top)
                        }
                    }
                }
            }
            .onChange(of: messages.count) { newCount in
                // Обновляем счетчик сообщений
                if !isFirstAppear {
                    lastMessageCount = newCount
                }
            }
            .onChange(of: messages.last?.id) { newLastMessageId in
                // При изменении последнего сообщения (новое сообщение или обновление текста): прокручиваем к нему
                // Только если это не первое появление и не идет загрузка истории
                if !isFirstAppear && !isLoadingHistory, let lastMessageId = newLastMessageId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
            .onChange(of: keyboardHeight) { newHeight in
                // При появлении/скрытии клавиатуры прокручиваем к последнему сообщению
                if newHeight > 0 && !messages.isEmpty && !isFirstAppear {
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

