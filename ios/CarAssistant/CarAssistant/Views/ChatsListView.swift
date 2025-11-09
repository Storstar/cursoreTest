import SwiftUI

struct ChatsListView: View {
    @EnvironmentObject var carViewModel: CarViewModel
    @State private var allChats: [Chat] = []
    @State private var showCreateChat = false
    
    // Фильтруем чаты по текущему автомобилю
    private var chats: [Chat] {
        guard let currentCar = carViewModel.car else { return [] }
        return allChats.filter { $0.carId == currentCar.id }
    }
    
    init() {
        // Инициализация с тестовыми данными для демонстрации
        // Тестовые данные будут добавлены в onAppear с правильным carId
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Список чатов
                if chats.isEmpty {
                    emptyStateView
                } else {
                    chatListView
                }
            }
            
            // Floating Action Button в правом нижнем углу
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        createNewChat()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30) // Отступ от нижнего таба (как на экране работ)
                }
            }
        }
        .onAppear {
            // Загружаем тестовые данные при появлении, если есть выбранный автомобиль
            if let car = carViewModel.car, allChats.isEmpty {
                loadTestData(for: car)
            }
        }
        .onChange(of: carViewModel.car?.id) { _ in
            // Обновляем чаты при смене автомобиля
            if let car = carViewModel.car {
                loadTestData(for: car)
            }
        }
    }
    
    private func loadTestData(for car: Car) {
        // Добавляем тестовый чат только если его еще нет для этого автомобиля
        if !allChats.contains(where: { $0.carId == car.id }) {
            let testChat = Chat(
                carId: car.id,
                title: "Горит желтая ма...",
                lastMessage: "Короткий ответ: с ж...",
                timestamp: Calendar.current.date(byAdding: .minute, value: -59, to: Date()) ?? Date()
            )
            allChats.append(testChat)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.fill")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.3))
            Text("Нет чатов")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var chatListView: some View {
        List {
            ForEach(chats) { chat in
                ChatRowView(chat: chat)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteChat(chat)
                        } label: {
                            Label("Удалить", systemImage: "trash.fill")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.bottom, 100) // Отступ для FAB
    }
    
    private func createNewChat() {
        guard let car = carViewModel.car else { return }
        let newChat = Chat(
            carId: car.id,
            title: "Новый чат",
            lastMessage: "Начните разговор",
            timestamp: Date()
        )
        allChats.insert(newChat, at: 0)
    }
    
    private func deleteChat(_ chat: Chat) {
        allChats.removeAll { $0.id == chat.id }
    }
}

struct ChatRowView: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка чата
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "message.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            // Информация о чате
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(chat.lastMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Text(formatTime(chat.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Стрелка навигации
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ChatsListView()
        .environmentObject(CarViewModel())
}
