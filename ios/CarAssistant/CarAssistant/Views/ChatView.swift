//
//  ChatView.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI

// MARK: - ChatView

/// Главный экран чата с ИИ-помощником
struct ChatView: View {
    // MARK: - Environment Objects
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    
    // MARK: - Properties
    
    let onChatStateChange: ((Bool) -> Void)?
    
    // MARK: - State Objects
    
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var requestViewModel = RequestViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    // MARK: - State Properties
    
    @State private var messageText = ""
    @State private var selectedImage: UIImage?
    @State private var showImageOptions = false
    @State private var showImagePicker = false
    @State private var showPhotoPicker = false
    @State private var isRecording = false
    @State private var showChatHistory = false
    @State private var isTextFieldFocused = false
    @State private var keyboardHeight: CGFloat = 0
    
    // MARK: - Task Management
    
    @State private var sendMessageTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(onChatStateChange: ((Bool) -> Void)? = nil) {
        self.onChatStateChange = onChatStateChange
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            if showChatHistory {
                chatHistoryView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                activeChatView
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showChatHistory)
        .task {
            loadInitialData()
        }
        .onAppear {
            // При открытии ChatView определяем, нужно ли скрывать TabBar
            onChatStateChange?(!showChatHistory)
        }
        .onChange(of: showChatHistory) { newValue in
            // Уведомляем о изменении состояния чата для скрытия/показа TabBar
            // showChatHistory = true означает список чатов (показываем TabBar)
            // showChatHistory = false означает активный чат (скрываем TabBar)
            onChatStateChange?(!newValue)
        }
        .onChange(of: carViewModel.car?.id) { newCarId in
            handleCarChange()
        }
        .sheet(isPresented: $showImageOptions) {
            ImageSourcePicker(
                selectedImage: $selectedImage,
                showImagePicker: $showImagePicker,
                showPhotoPicker: $showPhotoPicker
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .onChange(of: speechRecognizer.recognizedText) { newValue in
            handleSpeechRecognition(newValue)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
        .onDisappear {
            cleanup()
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
    
    /// Представление истории чатов
    private var chatHistoryView: some View {
        ChatHistoryView(
            chats: chatViewModel.chats,
            onChatTap: { chat in
                chatViewModel.openChat(chat)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showChatHistory = false
                }
            },
            onCreateNewChat: {
                chatViewModel.createNewChat()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showChatHistory = false
                }
            },
            onDeleteChat: { chat in
                if let user = authViewModel.currentUser {
                    chatViewModel.deleteChat(chat, for: user, car: carViewModel.car)
                }
            }
        )
    }
    
    /// Представление активного чата
    private var activeChatView: some View {
        VStack(spacing: 0) {
            ChatHeaderView(
                car: carViewModel.car,
                onShowHistory: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showChatHistory = true
                    }
                },
                onCreateNewChat: {
                    chatViewModel.createNewChat()
                }
            )
            
            // Контент чата
            ChatContentView(
                messages: chatViewModel.currentChatMessages,
                keyboardHeight: keyboardHeight,
                onTapToDismissKeyboard: { hideKeyboard() }
            )
            
            // Панель ввода
            ChatInputBar(
                text: $messageText,
                selectedImage: $selectedImage,
                isRecording: $isRecording,
                isTextFieldFocused: $isTextFieldFocused,
                onSend: { sendMessage() },
                onImageTap: { showImageOptions = true },
                onVoiceTap: { handleVoiceTap() }
            )
        }
    }
    
    // MARK: - Helper Methods
    
    /// Загрузить начальные данные
    private func loadInitialData() {
        if let user = authViewModel.currentUser {
            chatViewModel.loadChats(for: user, car: carViewModel.car)
        }
    }
    
    /// Обработать изменение автомобиля
    private func handleCarChange() {
        guard let user = authViewModel.currentUser else { return }
        
        Task { @MainActor in
            chatViewModel.loadChats(for: user, car: carViewModel.car)
            chatViewModel.currentChat = nil
            chatViewModel.currentChatMessages = []
            selectedImage = nil
        }
    }
    
    /// Обработать распознавание речи
    /// - Parameter text: Распознанный текст
    private func handleSpeechRecognition(_ text: String) {
        if !text.isEmpty && isRecording {
            messageText = text
        }
    }
    
    /// Очистка при закрытии экрана
    private func cleanup() {
        // Отменяем все активные задачи
        sendMessageTask?.cancel()
        sendMessageTask = nil
        
        // Очищаем изображения
        selectedImage = nil
        
        // Останавливаем запись, если она активна
        if isRecording {
            speechRecognizer.stopRecording()
            isRecording = false
        }
        
        // Скрываем клавиатуру
        hideKeyboard()
    }
    
    /// Скрыть клавиатуру
    private func hideKeyboard() {
        isTextFieldFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Обработать нажатие на кнопку голосового ввода
    private func handleVoiceTap() {
        if isRecording {
            speechRecognizer.stopRecording()
            isRecording = false
            if !speechRecognizer.recognizedText.isEmpty {
                messageText = speechRecognizer.recognizedText
            }
        } else {
            Task {
                let authorized = await speechRecognizer.requestAuthorization()
                if authorized {
                    speechRecognizer.startRecording()
                    isRecording = true
                }
            }
        }
    }
    
    /// Отправить сообщение
    private func sendMessage() {
        guard let user = authViewModel.currentUser else { return }
        
        let textToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageToSend = selectedImage
        
        // Очистка полей ввода
        messageText = ""
        selectedImage = nil
        isRecording = false
        isTextFieldFocused = false
        
        // Отменяем предыдущую задачу, если она еще выполняется
        sendMessageTask?.cancel()
        
        sendMessageTask = Task {
            // Оптимизация изображения перед отправкой
            var compressedImageData: Data? = nil
            if let imageToSend = imageToSend {
                compressedImageData = compressImage(imageToSend)
            }
            
            await chatViewModel.sendMessage(
                text: textToSend.isEmpty ? nil : textToSend,
                imageData: compressedImageData,
                requestViewModel: requestViewModel,
                for: user,
                car: carViewModel.car
            )
            
            // После отправки скролл будет выполнен автоматически в ChatContentView
        }
    }
    
    /// Сжать изображение для отправки
    /// - Parameter image: Исходное изображение
    /// - Returns: Сжатые данные изображения
    private func compressImage(_ image: UIImage) -> Data? {
        let maxDimension: CGFloat = 1200
        let scale: CGFloat
        
        if image.size.width > image.size.height {
            scale = min(1.0, maxDimension / image.size.width)
        } else {
            scale = min(1.0, maxDimension / image.size.height)
        }
        
        let scaledSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let scaledImage = scaledImage else { return nil }
        
        if let imageData = scaledImage.jpegData(compressionQuality: 0.7) {
            // Если изображение все еще слишком большое, сжимаем сильнее
            if imageData.count > 1_000_000 {
                return scaledImage.jpegData(compressionQuality: 0.5)
            } else {
                return imageData
            }
        }
        
        return nil
    }
}

// MARK: - ChatHeaderView

/// Заголовок чата с информацией об автомобиле
struct ChatHeaderView: View {
    // MARK: - Properties
    
    let car: Car?
    let onShowHistory: () -> Void
    let onCreateNewChat: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16) {
            historyButton
            
            carInfoView
            
            Spacer()
            
            newChatButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Subviews
    
    /// Кнопка показа истории чатов
    private var historyButton: some View {
        Button(action: onShowHistory) {
            Image(systemName: "list.bullet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// Информация об автомобиле
    @ViewBuilder
    private var carInfoView: some View {
        if let car = car {
            HStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "car.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(car.brand ?? "") \(car.model ?? "")")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if car.year > 0 || !car.engine.isEmpty {
                        Text([car.year > 0 ? "\(car.year)" : nil, car.engine]
                            .compactMap { $0 }
                            .joined(separator: " • "))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        } else {
            Text("Автомобиль не выбран")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
        }
    }
    
    /// Кнопка создания нового чата
    private var newChatButton: some View {
        Button(action: onCreateNewChat) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
