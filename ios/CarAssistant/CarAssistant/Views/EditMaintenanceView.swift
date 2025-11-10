import SwiftUI
import CoreData

struct EditMaintenanceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var carViewModel: CarViewModel
    @EnvironmentObject var maintenanceViewModel: MaintenanceViewModel
    
    let record: MaintenanceRecord
    
    @State private var date: Date
    @State private var mileage: String
    @State private var serviceType: String
    @State private var description: String
    @State private var worksPerformed: String
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showPhotoPicker = false
    @State private var showImageOptions = false
    @State private var isAnalyzingImage = false
    @State private var extractedText: String
    
    let maintenanceTypes = ["ТО", "Ремонт", "Замена", "Другое"]
    let serviceTypes = ["Плановое ТО", "Другое"] // Для категории "ТО"
    let replacementTypes = ["Замена масла", "Замена фильтров", "Замена тормозов", "Замена шин", "Диагностика", "Другое"] // Для категории "Замена"
    let repairTypes = ["Ремонт двигателя", "Ремонт коробки передач", "Ремонт подвески", "Ремонт тормозов", "Ремонт кузова", "Ремонт электрики", "Другое"]
    
    @State private var selectedMaintenanceType: String = "ТО"
    @State private var customServiceType: String = ""
    @State private var showAddServiceType = false
    @State private var showAddRepairType = false
    
    init(record: MaintenanceRecord) {
        self.record = record
        _date = State(initialValue: record.date)
        _mileage = State(initialValue: "\(record.mileage)")
        _serviceType = State(initialValue: record.serviceType ?? "")
        _description = State(initialValue: record.serviceDescription ?? "")
        _worksPerformed = State(initialValue: record.worksPerformed ?? "")
        _extractedText = State(initialValue: record.extractedText ?? "")
        
        // Определяем тип работы на основе serviceType
        let serviceTypeValue = record.serviceType ?? ""
        if repairTypes.contains(serviceTypeValue) {
            _selectedMaintenanceType = State(initialValue: "Ремонт")
        } else if replacementTypes.contains(serviceTypeValue) {
            _selectedMaintenanceType = State(initialValue: "Замена")
        } else if serviceTypes.contains(serviceTypeValue) {
            _selectedMaintenanceType = State(initialValue: "ТО")
        } else {
            _selectedMaintenanceType = State(initialValue: "Другое")
        }
        
        // Загружаем изображение с оптимизацией для экономии памяти
        if let imageData = record.documentImageData {
            // Используем downsampling для экономии памяти (80x80 = 160pt на retina = 320px)
            let optimizedImage = ImageOptimizer.downsampleImage(data: imageData, to: CGSize(width: 320, height: 320))
            _selectedImage = State(initialValue: optimizedImage)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Дата и пробег")) {
                    DatePicker("Дата ТО", selection: $date, displayedComponents: .date)
                    
                    TextField("Пробег (км)", text: $mileage)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Работы")) {
                    Picker("Работы", selection: $selectedMaintenanceType) {
                        ForEach(maintenanceTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedMaintenanceType == "ТО" {
                        Picker("Работы", selection: $serviceType) {
                            Text("Выберите тип").tag("")
                            ForEach(serviceTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        
                        if !serviceType.isEmpty && !serviceTypes.contains(serviceType) {
                            Button(action: {
                                customServiceType = serviceType
                                showAddServiceType = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Добавить \"\(serviceType)\"")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    } else if selectedMaintenanceType == "Ремонт" {
                        Picker("Работы", selection: $serviceType) {
                            Text("Выберите тип").tag("")
                            ForEach(repairTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        
                        if !serviceType.isEmpty && !repairTypes.contains(serviceType) {
                            Button(action: {
                                customServiceType = serviceType
                                showAddRepairType = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Добавить \"\(serviceType)\"")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    } else if selectedMaintenanceType == "Замена" {
                        Picker("Работы", selection: $serviceType) {
                            Text("Выберите тип").tag("")
                            ForEach(replacementTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        
                        if !serviceType.isEmpty && !replacementTypes.contains(serviceType) {
                            Button(action: {
                                customServiceType = serviceType
                                showAddServiceType = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Добавить \"\(serviceType)\"")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    } else {
                        // "Другое" - текстовое поле
                        TextField("Опишите тип работы", text: $serviceType)
                    }
                }
                
                Section(header: Text("Описание")) {
                    TextField("Описание работ", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Выполненные работы")) {
                    TextField("Список выполненных работ", text: $worksPerformed, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Документ (чек/наряд)")) {
                    if let image = selectedImage {
                        HStack {
                            // Используем thumbnail для экономии памяти (80x80 = 160pt на retina = 320px)
                            if let thumbnail = ImageOptimizer.createThumbnail(from: image, maxSize: 160) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            } else {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Button("Удалить фото") {
                                    selectedImage = nil
                                    extractedText = ""
                                }
                                .foregroundColor(.red)
                                
                                if isAnalyzingImage {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Анализ...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else if !extractedText.isEmpty {
                                    Text("Текст распознан")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Spacer()
                        }
                    } else {
                        Button(action: {
                            showImageOptions = true
                        }) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("Прикрепить фото")
                            }
                        }
                    }
                }
                
                if !extractedText.isEmpty {
                    Section(header: Text("Распознанный текст")) {
                        ScrollView {
                            Text(extractedText)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 100)
                        
                        Button("Использовать распознанный текст") {
                            let info = maintenanceViewModel.extractMaintenanceInfo(from: extractedText)
                            if let extractedServiceType = info.serviceType {
                                serviceType = extractedServiceType
                            }
                            if let extractedWorks = info.worksPerformed {
                                worksPerformed = extractedWorks
                            }
                            if let extractedMileage = info.mileage {
                                mileage = String(extractedMileage)
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Редактировать ТО")
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
                        saveMaintenance()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .disabled(serviceType.isEmpty || mileage.isEmpty)
                    .accessibilityLabel("Сохранить")
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
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    analyzeImage(image)
                }
            }
            .alert("Добавить тип ТО", isPresented: $showAddServiceType) {
                TextField("Название типа", text: $customServiceType)
                Button("Добавить") {
                    if !customServiceType.isEmpty {
                        serviceType = customServiceType
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Введите название нового типа ТО")
            }
            .alert("Добавить тип ремонта", isPresented: $showAddRepairType) {
                TextField("Название типа", text: $customServiceType)
                Button("Добавить") {
                    if !customServiceType.isEmpty {
                        serviceType = customServiceType
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Введите название нового типа ремонта")
            }
        }
    }
    
    private func analyzeImage(_ image: UIImage) {
        isAnalyzingImage = true
        Task {
            if let text = await maintenanceViewModel.recognizeText(from: image) {
                extractedText = text
            }
            isAnalyzingImage = false
        }
    }
    
    private func saveMaintenance() {
        guard let mileageInt = Int32(mileage) else {
            return
        }
        
        // Сжимаем изображение перед сохранением в Core Data для экономии памяти
        let imageData = selectedImage.flatMap { ImageOptimizer.compressImage($0, maxDimension: 800, compressionQuality: 0.7) }
        
        maintenanceViewModel.updateMaintenanceRecord(
            record,
            date: date,
            mileage: mileageInt,
            serviceType: serviceType.isEmpty ? nil : serviceType,
            description: description.isEmpty ? nil : description,
            worksPerformed: worksPerformed.isEmpty ? nil : worksPerformed,
            documentImageData: imageData,
            extractedText: extractedText.isEmpty ? nil : extractedText
        )
        
        dismiss()
    }
}

