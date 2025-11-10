import SwiftUI
import UIKit
import Combine

struct MyCarsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @State private var showAddCar = false
    @State private var editingCar: Car?
    
    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                contentView
                // Временно для отладки
                #if DEBUG
                debugInfo
                #endif
            }
        }
        .navigationTitle(Localization.CarInput.myCars)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addCarButton
            }
        }
        .sheet(isPresented: $showAddCar) {
            CarInputView(navigationPath: .constant(NavigationPath()))
                .environmentObject(authViewModel)
                .environmentObject(carViewModel)
                .presentationDetents([.large])
                .interactiveDismissDisabled(false) // Разрешаем свайп вниз для закрытия
                .onDisappear {
                    // Обновляем список автомобилей после закрытия экрана добавления
                    if let user = authViewModel.currentUser {
                        carViewModel.loadCars(for: user)
                    }
                }
            }
        .sheet(item: Binding(
            get: { editingCar },
            set: { editingCar = $0 }
        )) { (car: Car) in
            CarEditView(car: car)
                .environmentObject(authViewModel)
                .environmentObject(carViewModel)
                .presentationDetents([.large])
                .interactiveDismissDisabled(false) // Разрешаем свайп вниз для закрытия
        }
        .task {
            // Используем task вместо onAppear для асинхронной загрузки
            if let user = authViewModel.currentUser {
                await carViewModel.loadCarsAsync(for: user)
            }
        }
        // УБРАНО .refreshable - чтобы не мешать свайпу вниз для закрытия sheet'ов добавления/редактирования авто
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.96, green: 0.97, blue: 0.99),
                Color(red: 0.98, green: 0.99, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if carViewModel.cars.isEmpty {
            emptyStateView
        } else {
            carsListView
        }
    }
    
    private var debugInfo: some View {
        VStack {
            Text("Отладка: автомобилей = \(carViewModel.cars.count)")
                .font(.caption)
                .foregroundColor(.red)
            if let user = authViewModel.currentUser {
                Text("Пользователь: \(user.email ?? "нет")")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "car.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.3))
            
            Text(Localization.Settings.noCars)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(Localization.CarInput.addFirstCar)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
            
            Button(action: {
                showAddCar = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                    Text(Localization.CarInput.addCar)
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
            }
        }
    }
    
    private var carsListView: some View {
        Group {
            if carViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(carViewModel.cars, id: \.objectID) { car in
                        CarManagementCard(
                            car: car,
                            isDefault: carViewModel.car?.objectID == car.objectID,
                            onSetDefault: {
                                carViewModel.selectCar(car)
                            },
                            onEdit: {
                                editingCar = car
                            },
                            onDelete: {
                                deleteCar(car)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                editingCar = car
                            } label: {
                                Label(Localization.Common.edit, systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteCar(car)
                            } label: {
                                Label(Localization.Common.delete, systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    private var addCarButton: some View {
        Button(action: {
            showAddCar = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.blue)
        }
    }
    
    
    private func deleteCar(_ car: Car) {
        let context = CoreDataManager.shared.viewContext
        context.delete(car)
        CoreDataManager.shared.save()
        
        if let user = authViewModel.currentUser {
            carViewModel.invalidateCache()
            carViewModel.loadCars(for: user)
            // Если удалили текущий авто, выбираем первый из оставшихся
            if carViewModel.car?.objectID == car.objectID {
                carViewModel.car = carViewModel.cars.first
            }
        }
    }
}

// Карточка автомобиля для управления
struct CarManagementCard: View {
    let car: Car
    let isDefault: Bool
    let onSetDefault: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // Фото/иконка авто
            // Используем thumbnail для экономии памяти (45x45 = 90pt на retina = 180px)
            Group {
                if let photoData = car.photoData,
                   let thumbnail = ImageOptimizer.createThumbnail(from: photoData, maxSize: 90) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 45, height: 45)
                        
                        Image(systemName: "car.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Информация об авто
            VStack(alignment: .leading, spacing: 2) {
                Text("\(car.brand ?? "") \(car.model ?? "")")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(car.year)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Звезда для активного авто
            Button(action: {
                onSetDefault()
            }) {
                Image(systemName: isDefault ? "star.fill" : "star")
                    .font(.system(size: 18))
                    .foregroundColor(isDefault ? .blue : .gray.opacity(0.4))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 2)
    }
}

// Экран редактирования автомобиля
struct CarEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var carViewModel: CarViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var keyboardHelper = KeyboardHeightHelper()
    let car: Car
    @State private var selectedBrand: String = ""
    @State private var selectedModel: String = ""
    @State private var selectedYear: Int16 = 2024
    @State private var selectedEngine: String = ""
    @State private var selectedFuelType: String = ""
    @State private var selectedDriveType: String = ""
    @State private var selectedTransmission: String = ""
    @State private var vin: String = ""
    @State private var notes: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showPhotoPicker = false
    @State private var showImageOptions = false
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
    
    var fuelTypes: [String] { Localization.FuelType.all }
    var driveTypes: [String] { Localization.DriveType.all }
    var transmissions: [String] { Localization.Transmission.all }
    
    var filteredBrands: [String] {
        if brandSearchText.isEmpty {
            return CarBrandsData.allBrands
        }
        return CarBrandsData.searchBrands(query: brandSearchText)
    }
    
    var filteredModels: [String] {
        CarBrandsData.searchModels(for: selectedBrand, query: modelSearchText)
    }
    
    var shouldShowBrandList: Bool {
        isBrandFieldFocused && !filteredBrands.isEmpty
    }
    
    var shouldShowModelList: Bool {
        isModelFieldFocused && !selectedBrand.isEmpty && !filteredModels.isEmpty
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
                
                Section(header: Text(Localization.CarInput.brand)) {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(Localization.CarInput.brand, text: $brandSearchText)
                            .focused($isBrandFieldFocused)
                            .onChange(of: brandSearchText) { newValue in
                                selectedBrand = newValue
                                selectedModel = ""
                                modelSearchText = ""
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
                }
                
                Section(header: Text(Localization.CarInput.model)) {
                    if !selectedBrand.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            TextField(Localization.CarInput.model, text: $modelSearchText)
                                .focused($isModelFieldFocused)
                                .onChange(of: modelSearchText) { newValue in
                                    selectedModel = newValue
                                }
                            
                            // Выпадающий список моделей - часть контента формы
                            if shouldShowModelList {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(filteredModels, id: \.self) { model in
                                            Button(action: {
                                                selectedModel = model
                                                modelSearchText = model
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
                        Text(Localization.CarInput.enterBrandFirst)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(Localization.CarInput.year) {
                    Picker(Localization.CarInput.year, selection: $selectedYear) {
                        ForEach(carViewModel.years, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                }
                
                Section(Localization.CarInput.engine) {
                    Picker(Localization.CarInput.engine, selection: $selectedEngine) {
                        ForEach(carViewModel.engines, id: \.self) { engine in
                            Text(engine).tag(engine)
                        }
                    }
                }
                
                Section(header: Text(Localization.CarInput.additionalParams)) {
                    Picker(Localization.CarInput.fuelType, selection: $selectedFuelType) {
                        Text(Localization.CarInput.notSpecified).tag("")
                        ForEach(fuelTypes, id: \.self) { fuelType in
                            Text(fuelType).tag(fuelType)
                        }
                    }
                    
                    Picker(Localization.CarInput.driveType, selection: $selectedDriveType) {
                        Text(Localization.CarInput.notSpecified).tag("")
                        ForEach(driveTypes, id: \.self) { driveType in
                            Text(driveType).tag(driveType)
                        }
                    }
                    
                    Picker(Localization.CarInput.transmission, selection: $selectedTransmission) {
                        Text(Localization.CarInput.notSpecified).tag("")
                        ForEach(transmissions, id: \.self) { transmission in
                            Text(transmission).tag(transmission)
                        }
                    }
                    
                    TextField(Localization.CarInput.vinOptional, text: $vin)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text(Localization.CarInput.additionalInfo)) {
                    TextField(Localization.CarInput.notes, text: $notes, axis: .vertical)
                        .lineLimit(3...10)
                }
            }
            .navigationTitle(Localization.CarInput.editCar)
            .navigationBarTitleDisplayMode(.inline)
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
                    .accessibilityLabel(Localization.Common.cancel)
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
                    .disabled(selectedBrand.isEmpty || selectedModel.isEmpty)
                    .accessibilityLabel(Localization.Common.save)
                }
            }
            .onAppear {
                selectedBrand = car.brand ?? ""
                selectedModel = car.model ?? ""
                selectedYear = car.year
                selectedEngine = car.engine ?? ""
                // Преобразуем сохраненные значения (могут быть ключами или локализованными строками)
                if let fuelType = car.fuelType, !fuelType.isEmpty {
                    // Проверяем, является ли значение ключом
                    if fuelType.hasPrefix("fuelType.") {
                        selectedFuelType = Localization.FuelType.localizedString(for: fuelType)
                    } else {
                        // Это локализованная строка, преобразуем в ключ, а затем в текущую локализацию
                        if let key = Localization.FuelType.key(for: fuelType) {
                            selectedFuelType = Localization.FuelType.localizedString(for: key)
                        } else {
                            selectedFuelType = fuelType
                        }
                    }
                } else {
                    selectedFuelType = ""
                }
                
                if let driveType = car.driveType, !driveType.isEmpty {
                    if driveType.hasPrefix("driveType.") {
                        selectedDriveType = Localization.DriveType.localizedString(for: driveType)
                    } else {
                        if let key = Localization.DriveType.key(for: driveType) {
                            selectedDriveType = Localization.DriveType.localizedString(for: key)
                        } else {
                            selectedDriveType = driveType
                        }
                    }
                } else {
                    selectedDriveType = ""
                }
                
                if let transmission = car.transmission, !transmission.isEmpty {
                    if transmission.hasPrefix("transmission.") {
                        selectedTransmission = Localization.Transmission.localizedString(for: transmission)
                    } else {
                        if let key = Localization.Transmission.key(for: transmission) {
                            selectedTransmission = Localization.Transmission.localizedString(for: key)
                        } else {
                            selectedTransmission = transmission
                        }
                    }
                } else {
                    selectedTransmission = ""
                }
                vin = car.vin ?? ""
                notes = car.notes ?? ""
                // Загружаем изображение с оптимизацией для экономии памяти
                if let photoData = car.photoData {
                    // Используем downsampling для экономии памяти (120x120 = 240pt на retina = 480px)
                    selectedImage = ImageOptimizer.downsampleImage(data: photoData, to: CGSize(width: 480, height: 480))
                }
                brandSearchText = car.brand ?? ""
                modelSearchText = car.model ?? ""
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showPhotoPicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .confirmationDialog(Localization.CarInput.selectSource, isPresented: $showImageOptions, titleVisibility: .visible) {
                Button(Localization.CarInput.camera) {
                    showImagePicker = true
                }
                Button(Localization.CarInput.gallery) {
                    showPhotoPicker = true
                }
                Button(Localization.Common.cancel, role: .cancel) {}
            }
        }
    }
    
    private func saveCar() {
        if let user = authViewModel.currentUser {
            car.brand = selectedBrand
            car.model = selectedModel
            car.year = selectedYear
            car.engine = selectedEngine
            // Сохраняем ключи вместо локализованных строк
            if selectedFuelType.isEmpty {
                car.fuelType = nil
            } else {
                // Преобразуем локализованную строку в ключ
                if let key = Localization.FuelType.key(for: selectedFuelType) {
                    car.fuelType = key
                } else {
                    // Если не удалось найти ключ, сохраняем как есть (для обратной совместимости)
                    car.fuelType = selectedFuelType
                }
            }
            
            if selectedDriveType.isEmpty {
                car.driveType = nil
            } else {
                if let key = Localization.DriveType.key(for: selectedDriveType) {
                    car.driveType = key
                } else {
                    car.driveType = selectedDriveType
                }
            }
            
            if selectedTransmission.isEmpty {
                car.transmission = nil
            } else {
                if let key = Localization.Transmission.key(for: selectedTransmission) {
                    car.transmission = key
                } else {
                    car.transmission = selectedTransmission
                }
            }
            car.vin = vin.isEmpty ? nil : vin
            // Сжимаем изображение перед сохранением в Core Data для экономии памяти
            car.photoData = selectedImage.flatMap { ImageOptimizer.compressImage($0, maxDimension: 800, compressionQuality: 0.7) }
            car.notes = notes.isEmpty ? nil : notes
            CoreDataManager.shared.save()
            carViewModel.loadCars(for: user)
            dismiss()
        }
    }
    
    @ViewBuilder
    private var carPhotoSection: some View {
        VStack(spacing: 12) {
            if let image = selectedImage {
                ZStack(alignment: .topTrailing) {
                    // Используем thumbnail для экономии памяти (120x120 = 240pt на retina = 480px)
                    if let thumbnail = ImageOptimizer.createThumbnail(from: image, maxSize: 240) {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 3)
                            )
                    } else {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 3)
                            )
                    }
                    
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
                            Text(Localization.CarInput.addPhoto)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

