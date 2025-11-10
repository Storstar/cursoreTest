//
//  ChatInputBar.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI

// MARK: - ChatInputBar

/// Компонент для ввода сообщений в чате
struct ChatInputBar: View {
    // MARK: - Properties
    
    @Binding var text: String
    @Binding var selectedImage: UIImage?
    @Binding var isRecording: Bool
    @Binding var isTextFieldFocused: Bool
    
    @State private var textFieldContentHeight: CGFloat = 43 // Начальная высота (1 строка)
    
    let onSend: () -> Void
    let onImageTap: () -> Void
    let onVoiceTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            imagePreviewView
            inputFieldView
        }
        .background(
            inputBackground
                .ignoresSafeArea(edges: .bottom)
        )
        .padding(.bottom, 0)
    }
    
    // MARK: - Subviews
    
    /// Предпросмотр выбранного изображения
    @ViewBuilder
    private var imagePreviewView: some View {
        if let image = selectedImage {
            HStack(spacing: 12) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Button(action: { selectedImage = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
    
    /// Поле ввода с кнопками
    private var inputFieldView: some View {
        HStack(alignment: .center, spacing: 8) {
            photoButton
            textField
            actionButton
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    /// Кнопка выбора фото (43×43pt, зона тача ≥53×53pt)
    private var photoButton: some View {
        Button(action: onImageTap) {
            Image(systemName: "photo.fill")
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 43, height: 43)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
        }
        .frame(width: 53, height: 53) // Зона тача ≥53×53pt
        .buttonStyle(PlainButtonStyle())
    }
    
    /// Поле ввода текста (как в Telegram: минимум 1 строка, максимум 4 строки)
    private var textField: some View {
        MultilineTextField(
            text: $text,
            placeholder: "Напишите сообщение...",
            maxLines: 4, // Максимум 4 строки, затем внутренний скролл
            isFocused: $isTextFieldFocused,
            contentHeight: $textFieldContentHeight
        )
        .background(textFieldBackground)
        .frame(height: min(max(43, textFieldContentHeight), 100)) // Минимум 43pt (1 строка), максимум ~100pt (4 строки)
        .onChange(of: text) { newValue in
            // Сбрасываем высоту, когда текст пустой
            if newValue.isEmpty {
                textFieldContentHeight = 43
            }
        }
    }
    
    /// Фон поля ввода (закругленная капсула, как в Telegram)
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(.systemGray4).opacity(0.3), lineWidth: 0.5)
            )
    }
    
    /// Кнопка действия (микрофон/отправка)
    @ViewBuilder
    private var actionButton: some View {
        if isRecording {
            stopRecordingButton
        } else if text.isEmpty && selectedImage == nil {
            microphoneButton
        } else {
            sendButton
        }
    }
    
    /// Кнопка остановки записи (43×43pt, зона тача ≥53×53pt)
    private var stopRecordingButton: some View {
        Button(action: {
            isRecording = false
            onVoiceTap()
        }) {
            Image(systemName: "stop.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.red)
                .frame(width: 43, height: 43)
                .background(
                    Circle()
                        .fill(Color.white)
                )
        }
        .frame(width: 53, height: 53) // Зона тача ≥53×53pt
        .buttonStyle(PlainButtonStyle())
    }
    
    /// Кнопка микрофона (43×43pt, зона тача ≥53×53pt)
    private var microphoneButton: some View {
        Button(action: {
            isRecording = true
            onVoiceTap()
        }) {
            Image(systemName: "mic.fill")
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 43, height: 43)
                .background(
                    Circle()
                        .fill(Color.white)
                )
        }
        .frame(width: 53, height: 53) // Зона тача ≥53×53pt
        .buttonStyle(PlainButtonStyle())
    }
    
    /// Кнопка отправки (43×43pt, зона тача ≥53×53pt)
    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 43, height: 43)
                .background(
                    Circle()
                        .fill(Color.blue)
                )
        }
        .frame(width: 53, height: 53) // Зона тача ≥53×53pt
        .buttonStyle(PlainButtonStyle())
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil)
    }
    
    /// Фон области ввода (совпадает с основным фоном)
    private var inputBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.97, blue: 0.99), // #F6F7FB
                Color(red: 0.88, green: 0.92, blue: 0.97)  // #E1EBF7
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
