//
//  ChatBubble.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - ChatBubble

/// Компонент для отображения сообщения в чате
struct ChatBubble: View {
    // MARK: - Properties
    
    let message: ChatMessage
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if message.isFromUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 8) {
                imageView
                messageContentView
                timeView
            }
            
            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
    
    // MARK: - Subviews
    
    /// Изображение в сообщении (если есть)
    @ViewBuilder
    private var imageView: some View {
        if let imageData = message.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280, maxHeight: 220)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.bottom, 4)
        }
    }
    
    /// Содержимое сообщения (текст или индикатор загрузки)
    @ViewBuilder
    private var messageContentView: some View {
        if let text = message.text {
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(message.isFromUser ? .white : .primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(messageBubbleBackground)
        } else if message.isLoading {
            LoadingMessageView(loadingText: message.loadingText ?? "Ищу решение…")
        }
    }
    
    /// Фон пузыря сообщения
    @ViewBuilder
    private var messageBubbleBackground: some View {
        if message.isFromUser {
            // Сообщение пользователя - синий градиент
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
        } else {
            // Сообщение ИИ - светлый фон с эффектом стекла
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }
    
    /// Время сообщения
    private var timeView: some View {
        Text(formatTime(message.timestamp))
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.secondary)
            .padding(.horizontal, 4)
    }
    
    // MARK: - Helper Methods
    
    /// Форматировать время сообщения
    /// - Parameter date: Дата сообщения
    /// - Returns: Отформатированное время
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - LoadingMessageView

/// Индикатор загрузки для сообщения
struct LoadingMessageView: View {
    // MARK: - Properties
    
    let loadingText: String
    @State private var animationPhase: CGFloat = 0
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            animatedDots
            Text(loadingText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(loadingBackground)
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Subviews
    
    /// Анимированные точки
    private var animatedDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .offset(y: sin(animationPhase + Double(index) * 0.5) * 4)
            }
        }
    }
    
    /// Фон индикатора загрузки
    private var loadingBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Helper Methods
    
    /// Запустить анимацию
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            animationPhase = .pi * 2
        }
    }
}
