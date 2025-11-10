//
//  ChatHistoryView.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI

// MARK: - ChatHistoryView

/// Представление истории чатов
struct ChatHistoryView: View {
    // MARK: - Properties
    
    let chats: [Chat]
    let onChatTap: (Chat) -> Void
    let onCreateNewChat: () -> Void
    let onDeleteChat: ((Chat) -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            chatsListView
        }
    }
    
    // MARK: - Subviews
    
    /// Заголовок с кнопкой создания нового чата
    private var headerView: some View {
        HStack(spacing: 16) {
            Text("Чаты")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
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
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
    }
    
    /// Список чатов или пустое состояние
    @ViewBuilder
    private var chatsListView: some View {
        if chats.isEmpty {
            emptyStateView
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(chats) { chat in
                        ChatRow(
                            chat: chat,
                            onTap: { onChatTap(chat) },
                            onDelete: { onDeleteChat?(chat) }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
    
    /// Пустое состояние (когда нет чатов)
    private var emptyStateView: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Нет чатов")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Создайте первый чат, чтобы начать общение с ИИ")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
    }
}

// MARK: - ChatRow

/// Строка чата в списке истории
struct ChatRow: View {
    // MARK: - Properties
    
    let chat: Chat
    let onTap: () -> Void
    let onDelete: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                chatIcon
                chatInfo
                Spacer()
                chevronIcon
            }
            .padding(20)
            .background(chatRowBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Иконка чата (темы)
    private var chatIcon: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: topicGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 56, height: 56)
            .overlay(
                Group {
                    if let topic = chat.topic {
                        topicIcon(for: topic)
                    } else {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            )
    }
    
    /// Иконка темы
    private func topicIcon(for topic: Topic) -> some View {
        Group {
            if topic == .check_engine {
                Image("check_engine_icon")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.white)
            } else {
                Image(systemName: topicIconName(for: topic))
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
    }
    
    /// Имя иконки для темы
    private func topicIconName(for topic: Topic) -> String {
        switch topic {
        case .general_question:
            return "questionmark.circle.fill"
        case .check_engine:
            return "check.engine.custom"
        case .battery:
            return "battery.100"
        case .brakes:
            return "exclamationmark.octagon.fill"
        case .engine:
            return "gearshape.2.fill"
        case .transmission:
            return "gearshape.fill"
        case .suspension:
            return "car.2.fill"
        case .electrical:
            return "bolt.fill"
        case .air_conditioning:
            return "snowflake"
        case .tires:
            return "circle.dotted"
        }
    }
    
    /// Цвета градиента для темы
    private var topicGradientColors: [Color] {
        if let topic = chat.topic {
            switch topic {
            case .general_question:
                return [Color.blue.opacity(0.6), Color.blue.opacity(0.3)]
            case .check_engine:
                return [Color.orange.opacity(0.7), Color.orange.opacity(0.4)]
            case .battery:
                return [Color.green.opacity(0.6), Color.green.opacity(0.3)]
            case .brakes:
                return [Color.red.opacity(0.6), Color.red.opacity(0.3)]
            case .engine:
                return [Color.purple.opacity(0.6), Color.purple.opacity(0.3)]
            case .transmission:
                return [Color.indigo.opacity(0.6), Color.indigo.opacity(0.3)]
            case .suspension:
                return [Color.teal.opacity(0.6), Color.teal.opacity(0.3)]
            case .electrical:
                return [Color.yellow.opacity(0.6), Color.yellow.opacity(0.3)]
            case .air_conditioning:
                return [Color.cyan.opacity(0.6), Color.cyan.opacity(0.3)]
            case .tires:
                return [Color.gray.opacity(0.6), Color.gray.opacity(0.3)]
            }
        }
        return [Color.blue.opacity(0.6), Color.blue.opacity(0.3)]
    }
    
    /// Информация о чате
    private var chatInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(chat.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if let lastMessage = chat.lastMessage {
                Text(lastMessage)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Text(formatDate(chat.lastMessageDate))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
    
    /// Иконка стрелки
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.secondary)
    }
    
    /// Фон строки чата
    private var chatRowBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
    }
    
    // MARK: - Helper Methods
    
    /// Форматировать дату сообщения
    /// - Parameter date: Дата сообщения
    /// - Returns: Отформатированная дата
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}
