import SwiftUI
import Combine

struct CarInputView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var keyboardHelper = KeyboardHeightHelper()
    @State private var selectedBrand = ""
    @State private var selectedModel = ""
    @State private var selectedYear: Int16 = Int16(Calendar.current.component(.year, from: Date()))
    @State private var selectedEngine = ""
    @State private var selectedFuelType: String = ""
    @State private var selectedDriveType: String = ""
    @State private var selectedTransmission: String = ""
    @State private var vin: String = ""
    @State private var notes: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showPhotoPicker = false
    @State private var showImageOptions = false
    @State private var brandError: String?
    @State private var modelError: String?
    @State private var yearError: String?
    @State private var engineError: String?
    @State private var brandSearchText: String = ""
    @State private var modelSearchText: String = ""
    @FocusState private var isBrandFieldFocused: Bool
    @FocusState private var isModelFieldFocused: Bool
    
    // Вычисляем доступную высоту для dropdown
    private var availableDropdownHeight: CGFloat {
        let preferredHeight: CGFloat = 200
        let minHeight: CGFloat = 100
        let padding: CGFloat = 16
        
        // Если клавиатура не видна, используем предпочтительную высоту
        guard keyboardHelper.isKeyboardVisible else {
            return preferredHeight
        }
        
        // Вычисляем доступное пространство (примерно)
        // В реальности нужно учитывать позицию поля, но для упрощения используем фиксированное значение
        let available = UIScreen.main.bounds.height - keyboardHelper.keyboardHeight - 200 - padding
        
        return max(minHeight, min(preferredHeight, available))
    }
    
    let fuelTypes = ["Бензин", "Дизель", "Гибрид", "Электрический", "Газ", "Газ/Бензин"]
    let driveTypes = ["Передний", "Задний", "Полный", "4WD", "AWD"]
    let transmissions = ["Механическая", "Автоматическая", "Робот", "Вариатор", "DSG", "DCT"]
    
    var filteredBrands: [String] {
        if brandSearchText.isEmpty {
            return CarBrandsData.allBrands
        }
        return CarBrandsData.searchBrands(query: brandSearchText)
    }
    
    var shouldShowBrandList: Bool {
        isBrandFieldFocused && !filteredBrands.isEmpty
    }
    
    var shouldShowModelList: Bool {
        isModelFieldFocused && !selectedBrand.isEmpty && !filteredModels.isEmpty
    }
    
    var filteredModels: [String] {
        if selectedBrand.isEmpty {
            return []
        }
        return CarBrandsData.searchModels(for: selectedBrand, query: modelSearchText)
    }
    
    var body: some View {
        NavigationStack {
            Form {
            Section {
                HStack {
                    Spacer()
                    carPhotoSection
                    Spacer()
                }
            }
            
            Section(header: Text("Марка")) {
                VStack(alignment: .leading, spacing: 0) {
                    TextField("Марка", text: $brandSearchText)
                        .focused($isBrandFieldFocused)
                        .onChange(of: brandSearchText) { newValue in
                            selectedBrand = newValue
                            selectedModel = ""
                            modelSearchText = ""
                            brandError = nil
                        }
                    
                    // Выпадающий список марок - часть контента формы
                    if shouldShowBrandList {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(filteredBrands, id: \.self) { brand in
                                    Button(action: {
                                        selectedBrand = brand
                                        brandSearchText = brand
                                        selectedModel = ""
                                        modelSearchText = ""
                                        brandError = nil
                                        isBrandFieldFocused = false
                                        // Убеждаемся, что dropdown полностью скрыт и не блокирует касания
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            // Дополнительная проверка, что фокус снят
                                            if isBrandFieldFocused {
                                                isBrandFieldFocused = false
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Text(brand)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .contentShape(Rectangle())
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if brand != filteredBrands.last {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: availableDropdownHeight)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.top, 4)
                        .id("brandDropdown") // ID для прокрутки к dropdown
                        .allowsHitTesting(shouldShowBrandList) // Отключаем hit-testing когда скрыт
                    }
                }
                
                if let error = brandError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
            
            Section(header: Text("Модель")) {
                if !selectedBrand.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Модель", text: $modelSearchText)
                            .focused($isModelFieldFocused)
                            .onChange(of: modelSearchText) { newValue in
                                selectedModel = newValue
                                modelError = nil
                            }
                        
                        // Выпадающий список моделей - часть контента формы
                        if shouldShowModelList {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(filteredModels, id: \.self) { model in
                                        Button(action: {
                                            selectedModel = model
                                            modelSearchText = model
                                            modelError = nil
                                            isModelFieldFocused = false
                                            // Убеждаемся, что dropdown полностью скрыт и не блокирует касания
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                // Дополнительная проверка, что фокус снят
                                                if isModelFieldFocused {
                                                    isModelFieldFocused = false
                                                }
                                            }
                                        }) {
                                            HStack {
                                                Text(model)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .frame(maxWidth: .infinity)
                                            .contentShape(Rectangle())
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        if model != filteredModels.last {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: availableDropdownHeight)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.top, 4)
                            .id("modelDropdown") // ID для прокрутки к dropdown
                            .allowsHitTesting(shouldShowModelList) // Отключаем hit-testing когда скрыт
                        }
                    }
                } else {
                    Text("Сначала введите марку")
                        .foregroundColor(.secondary)
                }
                
                if let error = modelError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
            
            Section(header: Text("Год")) {
                Picker("Год", selection: $selectedYear) {
                    ForEach(carViewModel.years, id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
                
                if let error = yearError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Двигатель")) {
                Picker("Двигатель", selection: $selectedEngine) {
                    Text("Выберите двигатель").tag("")
                    ForEach(carViewModel.engines, id: \.self) { engine in
                        Text(engine).tag(engine)
                    }
                }
                
                if let error = engineError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section(header: Text("Дополнительные параметры")) {
                Picker("Тип топлива", selection: $selectedFuelType) {
                    Text("Не указано").tag("")
                    ForEach(fuelTypes, id: \.self) { fuelType in
                        Text(fuelType).tag(fuelType)
                    }
                }
                
                Picker("Привод", selection: $selectedDriveType) {
                    Text("Не указано").tag("")
                    ForEach(driveTypes, id: \.self) { driveType in
                        Text(driveType).tag(driveType)
                    }
                }
                
                Picker("Коробка передач", selection: $selectedTransmission) {
                    Text("Не указано").tag("")
                    ForEach(transmissions, id: \.self) { transmission in
                        Text(transmission).tag(transmission)
                    }
                }
                
                TextField("VIN (необязательно)", text: $vin)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
            }
            
            Section(header: Text("Дополнительная информация")) {
                TextField("Заметки, особенности, пожелания...", text: $notes, axis: .vertical)
                    .lineLimit(3...10)
            }
            
            if let error = carViewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Добавить автомобиль")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Отмена")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    saveCar()
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(selectedBrand.isEmpty || selectedModel.isEmpty || selectedEngine.isEmpty)
                .accessibilityLabel("Сохранить")
            }
        }
        .scrollDismissesKeyboard(.interactively) // Автоматически скрывает клавиатуру при прокрутке
        .safeAreaInset(edge: .bottom) {
            // Добавляем нижний inset, равный высоте клавиатуры
            if keyboardHelper.isKeyboardVisible {
                Color.clear
                    .frame(height: keyboardHelper.keyboardHeight)
            }
        }
        // Убрали simultaneousGesture, так как он перехватывал все касания и блокировал взаимодействие с полями формы
        .onChange(of: isBrandFieldFocused) { focused in
            // При появлении dropdown автоматически прокручиваем форму
            if focused {
                // Form автоматически прокрутится к TextField при фокусе
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Небольшая задержка для корректной прокрутки
                }
            }
        }
        .onChange(of: isModelFieldFocused) { focused in
            // При появлении dropdown автоматически прокручиваем форму
            if focused {
                // Form автоматически прокрутится к TextField при фокусе
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Небольшая задержка для корректной прокрутки
                }
            }
        }
        .onAppear {
            // Убеждаемся, что поля всегда пустые при открытии формы добавления
            selectedBrand = ""
            selectedModel = ""
            selectedYear = Int16(Calendar.current.component(.year, from: Date()))
            selectedEngine = ""
            selectedFuelType = ""
            selectedDriveType = ""
            selectedTransmission = ""
            vin = ""
            notes = ""
            selectedImage = nil // Освобождаем память от изображений
        }
        .onDisappear {
            // Освобождаем память при закрытии экрана
            selectedImage = nil
            brandSearchText = ""
            modelSearchText = ""
            brandError = nil
            modelError = nil
            yearError = nil
            engineError = nil
            isBrandFieldFocused = false
            isModelFieldFocused = false
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
        }
    }
    
    private func saveCar() {
        brandError = Validators.validateBrand(selectedBrand)
        modelError = Validators.validateModel(selectedModel)
        yearError = Validators.validateYear(selectedYear)
        engineError = Validators.validateEngine(selectedEngine)
        
        if brandError == nil && modelError == nil && yearError == nil && engineError == nil {
            if let user = authViewModel.currentUser {
                // ВАЖНО: Всегда создаем новый автомобиль, никогда не обновляем существующий
                let carsCountBefore = carViewModel.cars.count
                let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                carViewModel.saveCar(
                    brand: selectedBrand,
                    model: selectedModel,
                    year: selectedYear,
                    engine: selectedEngine,
                    fuelType: selectedFuelType.isEmpty ? nil : selectedFuelType,
                    driveType: selectedDriveType.isEmpty ? nil : selectedDriveType,
                    transmission: selectedTransmission.isEmpty ? nil : selectedTransmission,
                    vin: vin.isEmpty ? nil : vin,
                    photoData: imageData,
                    notes: notes.isEmpty ? nil : notes,
                    for: user
                )
                
                if carViewModel.errorMessage == nil {
                    // Обновляем список автомобилей
                    carViewModel.loadCars(for: user)
                    
                    // Проверяем, что автомобиль действительно добавился
                    let carsCountAfter = carViewModel.cars.count
                    if carsCountAfter > carsCountBefore {
                        print("✅ Новый автомобиль успешно добавлен. Было: \(carsCountBefore), стало: \(carsCountAfter)")
                    } else {
                        print("⚠️ Внимание: Количество автомобилей не изменилось!")
                    }
                    
                    // Очищаем поля формы
                    selectedBrand = ""
                    selectedModel = ""
                    selectedYear = Int16(Calendar.current.component(.year, from: Date()))
                    selectedEngine = ""
                    selectedFuelType = ""
                    selectedDriveType = ""
                    selectedTransmission = ""
                    vin = ""
                    notes = ""
                    selectedImage = nil
                    brandSearchText = ""
                    modelSearchText = ""
                    brandError = nil
                    modelError = nil
                    yearError = nil
                    engineError = nil
                    isBrandFieldFocused = false
                    isModelFieldFocused = false
                    
                    // Закрываем sheet
                    dismiss()
                }
            }
        }
    }
    
    @ViewBuilder
    private var carPhotoSection: some View {
        VStack(spacing: 12) {
            if let image = selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                        )
                    
                    Button(action: {
                        selectedImage = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                            .background(Circle().fill(Color.white))
                    }
                    .offset(x: 5, y: -5)
                }
            } else {
                Button(action: {
                    showImageOptions = true
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                            Text("Добавить фото")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}
