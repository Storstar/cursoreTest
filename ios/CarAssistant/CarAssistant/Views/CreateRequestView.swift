import SwiftUI

struct CreateRequestView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var requestViewModel: RequestViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var requestText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showPhotoPicker = false
    @State private var showImageOptions = false
    @State private var isRecording = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // История запросов (если есть)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(requestViewModel.requests.prefix(10), id: \.objectID) { request in
                            VStack(spacing: 8) {
                                // Запрос пользователя (справа, синий)
                                if let text = request.text {
                                    HStack {
                                        Spacer()
                                        Text(text)
                                            .padding(12)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(16)
                                            .frame(maxWidth: .infinity * 0.75, alignment: .trailing)
                                    }
                                }
                                
                                // Ответ AI (слева, серый)
                                if let response = request.response?.text {
                                    HStack {
                                        Text(response)
                                            .padding(12)
                                            .background(Color(.systemGray5))
                                            .foregroundColor(.primary)
                                            .cornerRadius(16)
                                            .frame(maxWidth: .infinity * 0.75, alignment: .leading)
                                        Spacer()
                                    }
                                }
                            }
                            .id(request.objectID)
                        }
                    }
                    .padding()
                }
                .onChange(of: requestViewModel.requests.count) { _ in
                    // Прокручиваем вниз при появлении нового сообщения
                    if let lastRequest = requestViewModel.requests.first {
                        withAnimation {
                            proxy.scrollTo(lastRequest.objectID, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Поле ввода внизу (в стиле GPT)
            VStack(spacing: 0) {
                if let image = selectedImage {
                    HStack {
                        // Используем thumbnail для экономии памяти (60x60 = 120pt на retina = 240px)
                        if let thumbnail = ImageOptimizer.createThumbnail(from: image, maxSize: 120) {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        } else {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            selectedImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                if let error = requestViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }
                
                HStack(spacing: 12) {
                    // Кнопка фото
                    Button(action: {
                        showImageOptions = true
                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    
                    // Поле ввода
                    TextField("Напишите ваш вопрос...", text: $requestText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .lineLimit(1...6)
                        .focused($isTextFieldFocused)
                    
                    // Кнопка микрофона или отправки
                    if isRecording {
                        Button(action: {
                            speechRecognizer.stopRecording()
                            isRecording = false
                        }) {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                        }
                    } else if requestText.isEmpty {
                        Button(action: {
                            Task {
                                let authorized = await speechRecognizer.requestAuthorization()
                                if authorized {
                                    speechRecognizer.startRecording()
                                    isRecording = true
                                }
                            }
                        }) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                    } else {
                        Button(action: {
                            sendMessage()
                        }) {
                            if requestViewModel.isLoading {
                                ProgressView()
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.blue)
                            }
                        }
                        .disabled(requestViewModel.isLoading || requestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("CarAssistant")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isTextFieldFocused = true
            if let user = authViewModel.currentUser {
                requestViewModel.loadRequests(for: user)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .confirmationDialog("Выберите источник", isPresented: $showImageOptions, titleVisibility: .visible) {
            Button("Камера") {
                showImagePicker = true
            }
            Button("Галерея") {
                showPhotoPicker = true
            }
            Button("Отмена", role: .cancel) {}
        }
        .onChange(of: speechRecognizer.recognizedText) { newValue in
            if !newValue.isEmpty && !isRecording {
                requestText = speechRecognizer.recognizedText
                isRecording = false
            }
        }
    }
    
    private func sendMessage() {
        guard let user = authViewModel.currentUser else { return }
        
        let textToSend = requestText.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageToSend = selectedImage
        
        // Сжимаем изображение перед отправкой для экономии памяти
        if let image = imageToSend, let imageData = ImageOptimizer.compressImage(image, maxDimension: 1200, compressionQuality: 0.7) {
            Task {
                await requestViewModel.createPhotoRequest(imageData: imageData, for: user, car: carViewModel.car)
                if requestViewModel.errorMessage == nil {
                    requestText = ""
                    selectedImage = nil
                    await requestViewModel.loadRequests(for: user)
                }
            }
        } else if !textToSend.isEmpty {
            Task {
                await requestViewModel.createTextRequest(text: textToSend, for: user, car: carViewModel.car)
                if requestViewModel.errorMessage == nil {
                    requestText = ""
                    await requestViewModel.loadRequests(for: user)
                }
            }
        }
    }
}

