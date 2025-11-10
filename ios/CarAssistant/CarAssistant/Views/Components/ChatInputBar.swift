//
//  ChatInputBar.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI

// MARK: - CarProblemButton

/// Модель кнопки проблемы с автомобилем
struct CarProblemButton: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    var isActive: Bool
    
    static let defaultButtons: [CarProblemButton] = [
        CarProblemButton(icon: "questionmark.circle", title: "General Question", isActive: false),
        CarProblemButton(icon: "check.engine.custom", title: "Check Engine", isActive: false),
        CarProblemButton(icon: "battery.100", title: "Battery", isActive: false),
        CarProblemButton(icon: "exclamationmark.octagon", title: "Brake System", isActive: false),
        CarProblemButton(icon: "gearshape.2", title: "Engine", isActive: false),
        CarProblemButton(icon: "gearshape", title: "Transmission", isActive: false),
        CarProblemButton(icon: "car.2", title: "Suspension", isActive: false),
        CarProblemButton(icon: "bolt", title: "Electrical", isActive: false),
        CarProblemButton(icon: "snowflake", title: "AC System", isActive: false),
        CarProblemButton(icon: "circle.dotted", title: "Tires", isActive: false)
    ]
}

// MARK: - ChatInputBar

/// Компонент для ввода сообщений в чате
struct ChatInputBar: View {
    // MARK: - Properties
    
    @Binding var text: String
    @Binding var selectedImage: UIImage?
    @Binding var isRecording: Bool
    @Binding var isTextFieldFocused: Bool
    
    @State private var textFieldContentHeight: CGFloat = 43 // Начальная высота (1 строка)
    @State private var problemButtons: [CarProblemButton] = CarProblemButton.defaultButtons
    
    let onSend: () -> Void
    let onImageTap: () -> Void
    let onVoiceTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            imagePreviewView
            problemButtonsScrollView
            inputFieldView
        }
        .background(
            inputBackground
                .ignoresSafeArea(edges: .bottom)
        )
        .padding(.bottom, 0)
    }
    
    // MARK: - Subviews
    
    /// Горизонтальный скролл с кнопками проблем
    private var problemButtonsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(problemButtons) { button in
                    ProblemButtonView(
                        button: button,
                        onTap: {
                            toggleButton(button)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(height: 60)
    }
    
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
    
    // MARK: - Helper Methods
    
    /// Переключить состояние кнопки (только одна может быть активна)
    private func toggleButton(_ button: CarProblemButton) {
        if let index = problemButtons.firstIndex(where: { $0.id == button.id }) {
            var updatedButtons = problemButtons
            
            // Если нажатая кнопка уже активна, деактивируем её
            if updatedButtons[index].isActive {
                updatedButtons[index].isActive = false
            } else {
                // Деактивируем все кнопки
                for i in updatedButtons.indices {
                    updatedButtons[i].isActive = false
                }
                // Активируем только выбранную
                updatedButtons[index].isActive = true
            }
            
            problemButtons = updatedButtons
        }
    }
}

// MARK: - ProblemButtonView

/// Представление кнопки проблемы
struct ProblemButtonView: View {
    let button: CarProblemButton
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if button.icon == "check.engine.custom" {
                    Image("check_engine_icon")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(button.isActive ? .white : .orange)
                } else {
                    Image(systemName: button.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(button.isActive ? .white : .blue)
                }
                
                Text(button.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(button.isActive ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(button.isActive ? 
                          LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) :
                          LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
                    .shadow(
                        color: button.isActive ? Color.blue.opacity(0.3) : Color.black.opacity(0.1),
                        radius: button.isActive ? 4 : 2,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        button.isActive ? Color.clear : Color(.systemGray4).opacity(0.3),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

