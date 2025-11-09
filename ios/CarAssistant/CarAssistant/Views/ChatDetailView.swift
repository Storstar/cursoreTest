import SwiftUI

struct ChatDetailView: View {
    let chat: Chat
    @Binding var navigationPath: NavigationPath
    let chatViewModel: ChatViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @StateObject private var keyboardHelper = KeyboardHeightHelper()
    @State private var messages: [Message] = []
    @State private var messageText: String = ""
    @State private var showImagePicker = false
    @FocusState private var isInputFocused: Bool
    @State private var currentChat: Chat
    
    var carName: String {
        guard let car = carViewModel.car else { return "Автомобиль" }
        return "\(car.brand) \(car.model)"
    }
    
    init(chat: Chat, navigationPath: Binding<NavigationPath>, chatViewModel: ChatViewModel) {
        self.chat = chat
        self._navigationPath = navigationPath
        self.chatViewModel = chatViewModel
        self._currentChat = State(initialValue: chat)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок
            headerView
            
            // Область сообщений
            messagesView
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            // Поле ввода - закреплено внизу
            inputView
        }
        .navigationBarBackButtonHidden(true) // Скрываем стандартную кнопку назад
        .toolbar(.hidden, for: .navigationBar) // Скрываем весь navigation bar
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                // Прокручиваем к последнему сообщению при появлении клавиатуры
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToBottom()
                }
            }
        }
        .onAppear {
            // Убеждаемся, что currentChat синхронизирован с chat
            if currentChat.id != chat.id {
                currentChat = chat
            }
            // Загружаем сообщения из CoreData
            messages = chatViewModel.loadMessages(for: chat.id)
        }
        .onChange(of: isInputFocused) { focused in
            if focused {
                // Небольшая задержка для корректной прокрутки
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    scrollToBottom()
                }
            }
        }
        .onChange(of: messages.count) { _ in
            scrollToBottom()
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            // Кнопка меню слева
            Button(action: {
                // Возвращаемся к списку чатов, очищая весь путь навигации
                navigationPath = NavigationPath()
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            
            // Название автомобиля по центру
            Text(carName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
            
            // Кнопка плюс справа
            Button(action: {
                // TODO: Действие для плюса
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color(uiColor: .systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    @State private var scrollProxy: ScrollViewProxy?
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20) {
                    if messages.isEmpty {
                        // Пустое состояние
                        VStack(spacing: 16) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.3))
                            Text("Начните разговор")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively) // Позволяет скрывать клавиатуру при прокрутке
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: messages.count) { _ in
                scrollToBottom()
            }
        }
    }
    
    private func scrollToBottom() {
        guard let proxy = scrollProxy else { return }
        if let lastMessage = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 0) {
            // Разделительная линия
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.2))
            
            HStack(spacing: 12) {
                // Иконка галереи
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                
                // Поле ввода
                TextField("Напишите сообщение...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(22)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .onSubmit {
                        if !messageText.isEmpty {
                            sendMessage()
                        }
                    }
                    .onTapGesture {
                        // Явно устанавливаем фокус при нажатии
                        DispatchQueue.main.async {
                            isInputFocused = true
                        }
                    }
                
                // Кнопка отправки или микрофон
                if !messageText.isEmpty {
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.blue)
                    }
                } else {
                    Button(action: {
                        // TODO: Голосовой ввод
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .contentShape(Rectangle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .systemBackground))
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let userMessage = Message(
            chatId: currentChat.id,
            content: trimmedText,
            isUser: true,
            timestamp: Date()
        )
        
        // Сохраняем сообщение в CoreData
        chatViewModel.saveMessage(userMessage)
        
        // Добавляем в локальный массив
        messages.append(userMessage)
        messageText = ""
        isInputFocused = false
        
        // Обновляем название чата по первому сообщению пользователя
        if currentChat.title == "Новый чат" || currentChat.title.isEmpty {
            let chatTitle = trimmedText.count > 30 ? String(trimmedText.prefix(30)) + "..." : trimmedText
            currentChat.title = chatTitle
            currentChat.lastMessage = trimmedText
            currentChat.timestamp = Date()
            chatViewModel.updateChat(currentChat)
        } else {
            // Обновляем последнее сообщение
            currentChat.lastMessage = trimmedText
            currentChat.timestamp = Date()
            chatViewModel.updateChat(currentChat)
        }
        
        // TODO: Отправить сообщение AI и получить ответ
        // После получения ответа добавить его в messages через chatViewModel.saveMessage() и обновить lastMessage
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 50)
            }
            
            Text(message.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(message.isUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isUser
                        ? Color.blue
                        : Color(uiColor: .systemGray6)
                )
                .cornerRadius(18)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    ChatDetailView(
        chat: Chat(carId: UUID(), title: "Тест", lastMessage: "Тест"),
        navigationPath: .constant(NavigationPath()),
        chatViewModel: ChatViewModel()
    )
    .environmentObject(CarViewModel())
}
