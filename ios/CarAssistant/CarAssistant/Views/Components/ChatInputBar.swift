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
    // MARK: - Environment Objects
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    // MARK: - Properties
    
    @Binding var text: String
    @Binding var selectedImage: UIImage?
    @Binding var isRecording: Bool
    @Binding var isTextFieldFocused: Bool
    
    @State private var textFieldContentHeight: CGFloat = 43 // Начальная высота (1 строка)
    @State private var problemButtons: [CarProblemButton] = CarProblemButton.defaultButtons
    
    let selectedTopic: Topic? // Текущая выбранная тема
    let onSend: () -> Void
    let onImageTap: () -> Void
    let onVoiceTap: () -> Void
    let onTopicSelected: ((Topic?) -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            imagePreviewView
            problemButtonsScrollView
            inputFieldView
        }
        .background(Color.clear) // Убираем фон за полем ввода и кнопками
        .padding(.bottom, 0)
        .onChange(of: selectedTopic) { newTopic in
            updateButtonsForTopic(newTopic)
        }
        .onAppear {
            updateButtonsForTopic(selectedTopic)
        }
    }
    
    // MARK: - Subviews
    
    /// Горизонтальный скролл с кнопками проблем
    private var problemButtonsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(problemButtons) { button in
                        ProblemButtonView(
                            button: button,
                            onTap: {
                                let buttonId = button.id
                                let wasActive = button.isActive
                                toggleButton(button)
                                // Прокручиваем к выбранной кнопке, если она стала активной
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if let updatedButton = problemButtons.first(where: { $0.id == buttonId }),
                                       updatedButton.isActive && !wasActive {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            proxy.scrollTo(buttonId, anchor: .leading) // Выбранный элемент к левой стороне
                                        }
                                    }
                                }
                            }
                        )
                        .id(button.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 2) // Минимальный отступ сверху
                .padding(.bottom, 0) // Убираем отступ снизу
            }
            .scrollContentBackground(.hidden) // Убираем фон у скролл вью
            .background(Color.clear) // Убираем фон у скролл вью
            .onChange(of: selectedTopic) { newTopic in
                // Прокручиваем к активной кнопке при изменении темы
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if let topic = newTopic,
                       let buttonTitle = topicButtonTitle(for: topic),
                       let activeButton = problemButtons.first(where: { $0.title == buttonTitle && $0.isActive }) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(activeButton.id, anchor: .leading) // Выбранный элемент к левой стороне
                        }
                    }
                }
            }
            .onAppear {
                // Прокручиваем к активной кнопке при появлении
                if let activeButton = problemButtons.first(where: { $0.isActive }) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(activeButton.id, anchor: .leading) // Выбранный элемент к левой стороне
                        }
                    }
                }
            }
        }
        .frame(height: 50)
    }
    
    /// Предпросмотр выбранного изображения
    @ViewBuilder
    private var imagePreviewView: some View {
        if let image = selectedImage {
            HStack(spacing: 12) {
                // Используем thumbnail для экономии памяти (60x60 = 120pt на retina = 240px)
                if let thumbnail = ImageOptimizer.createThumbnail(from: image, maxSize: 120) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
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
        .padding(.top, 0) // Убираем отступ сверху, чтобы максимально приблизить к скролл вью
        .padding(.bottom, 12)
    }
    
    /// Кнопка выбора фото (43×43pt, зона тача ≥53×53pt)
    private var photoButton: some View {
        let isDark = themeManager.colorScheme == .dark || (themeManager.colorScheme == nil && systemColorScheme == .dark)
        
        return Button(action: onImageTap) {
            Image(systemName: "photo.fill")
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 43, height: 43)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isDark ? Color(red: 0.25, green: 0.27, blue: 0.30) : Color.white)
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
        .background(textFieldBackground) // Белый фон у поля ввода как обычно
        .frame(height: min(max(43, textFieldContentHeight), 100)) // Минимум 43pt (1 строка), максимум ~100pt (4 строки)
        .onChange(of: text) { newValue in
            // Сбрасываем высоту, когда текст пустой
            if newValue.isEmpty {
                textFieldContentHeight = 43
            }
        }
    }
    
    /// Фон поля ввода (адаптирован под тему)
    private var textFieldBackground: some View {
        let isDark = themeManager.colorScheme == .dark || (themeManager.colorScheme == nil && systemColorScheme == .dark)
        
        return RoundedRectangle(cornerRadius: 18)
            .fill(isDark ? Color(red: 0.25, green: 0.27, blue: 0.30) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isDark ? Color(.systemGray3).opacity(0.3) : Color(.systemGray4).opacity(0.3), lineWidth: 0.5)
            )
    }
    
    /// Кнопка действия (отправка)
    @ViewBuilder
    private var actionButton: some View {
        if isRecording {
            stopRecordingButton
        } else {
            // Кнопка отправки всегда видна, но неактивна когда нет текста и изображения
            sendButton
                .disabled(text.isEmpty && selectedImage == nil)
                .opacity((text.isEmpty && selectedImage == nil) ? 0.5 : 1.0)
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
                // Уведомляем об отмене выбора темы
                onTopicSelected?(nil)
            } else {
                // Деактивируем все кнопки
                for i in updatedButtons.indices {
                    updatedButtons[i].isActive = false
                }
                // Активируем только выбранную
                updatedButtons[index].isActive = true
                
                // Уведомляем о выбранной теме
                if let topic = PromptBuilder.topic(from: button.title) {
                    onTopicSelected?(topic)
                }
            }
            
            problemButtons = updatedButtons
        }
    }
    
    /// Обновить кнопки в соответствии с выбранной темой
    private func updateButtonsForTopic(_ topic: Topic?) {
        var updatedButtons = problemButtons
        
        // Сбрасываем все кнопки
        for i in updatedButtons.indices {
            updatedButtons[i].isActive = false
        }
        
        // Активируем кнопку, соответствующую теме
        if let topic = topic,
           let buttonTitle = topicButtonTitle(for: topic),
           let index = updatedButtons.firstIndex(where: { $0.title == buttonTitle }) {
            updatedButtons[index].isActive = true
        }
        
        problemButtons = updatedButtons
    }
    
    /// Прокрутить к активной кнопке (используется из ScrollViewReader)
    private func scrollToActiveButton(proxy: ScrollViewProxy) {
        if let activeButton = problemButtons.first(where: { $0.isActive }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(activeButton.id, anchor: .leading) // Выбранный элемент к левой стороне
            }
        }
    }
    
    /// Получить название кнопки для темы
    private func topicButtonTitle(for topic: Topic) -> String? {
        switch topic {
        case .general_question:
            return "General Question"
        case .check_engine:
            return "Check Engine"
        case .battery:
            return "Battery"
        case .brakes:
            return "Brake System"
        case .engine:
            return "Engine"
        case .transmission:
            return "Transmission"
        case .suspension:
            return "Suspension"
        case .electrical:
            return "Electrical"
        case .air_conditioning:
            return "AC System"
        case .tires:
            return "Tires"
        }
    }
}

// MARK: - ProblemButtonView

/// Представление кнопки проблемы
struct ProblemButtonView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    let button: CarProblemButton
    let onTap: () -> Void
    
    private var isDark: Bool {
        themeManager.colorScheme == .dark || (themeManager.colorScheme == nil && systemColorScheme == .dark)
    }
    
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
                        .foregroundColor(button.isActive ? .white : (isDark ? .white : .blue))
                }
                
                Text(button.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(button.isActive ? .white : (isDark ? .white : .primary))
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
                            colors: isDark ? [
                                Color(red: 0.25, green: 0.27, blue: 0.30),
                                Color(red: 0.22, green: 0.24, blue: 0.27)
                            ] : [
                                Color.white,
                                Color.white.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
                    .shadow(
                        color: button.isActive ? Color.blue.opacity(0.3) : (isDark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)),
                        radius: button.isActive ? 4 : 2,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        button.isActive ? Color.clear : (isDark ? Color(.systemGray2).opacity(0.3) : Color(.systemGray4).opacity(0.3)),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

