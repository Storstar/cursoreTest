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
    
    @State private var showDeleteConfirmation = false
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                chatIcon
                chatInfo
                Spacer()
                deleteButton
                chevronIcon
            }
            .padding(20)
            .background(chatRowBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog(
            "Удалить чат?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                onDelete()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы уверены, что хотите удалить этот чат?")
        }
    }
    
    // MARK: - Subviews
    
    /// Иконка чата
    private var chatIcon: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 56, height: 56)
            .overlay(
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            )
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
    
    /// Кнопка удаления
    private var deleteButton: some View {
        Button(action: { showDeleteConfirmation = true }) {
            Image(systemName: "trash")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.red.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
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
