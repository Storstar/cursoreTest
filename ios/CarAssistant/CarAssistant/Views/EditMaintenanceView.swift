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
    
    var maintenanceTypes: [String] { Localization.MaintenanceType.maintenanceTypes }
    var serviceTypes: [String] { Localization.MaintenanceType.serviceTypes }
    var replacementTypes: [String] { Localization.MaintenanceType.replacementTypes }
    var repairTypes: [String] { Localization.MaintenanceType.repairTypes }
    
    @State private var selectedMaintenanceType: String = ""
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
        // Используем локализованные значения для сравнения
        // Также проверяем старые русские значения для обратной совместимости
        let localizedRepairTypes = Localization.MaintenanceType.repairTypes
        let localizedReplacementTypes = Localization.MaintenanceType.replacementTypes
        let localizedServiceTypes = Localization.MaintenanceType.serviceTypes
        
        // Старые русские значения для обратной совместимости
        let oldRussianRepairTypes = ["Ремонт двигателя", "Ремонт коробки передач", "Ремонт подвески", "Ремонт тормозов", "Ремонт кузова", "Ремонт электрики"]
        let oldRussianReplacementTypes = ["Замена масла", "Замена фильтров", "Замена тормозов", "Замена шин", "Диагностика"]
        let oldRussianServiceTypes = ["Плановое ТО"]
        
        if localizedRepairTypes.contains(serviceTypeValue) || oldRussianRepairTypes.contains(serviceTypeValue) {
            _selectedMaintenanceType = State(initialValue: Localization.MaintenanceType.repair)
        } else if localizedReplacementTypes.contains(serviceTypeValue) || oldRussianReplacementTypes.contains(serviceTypeValue) {
            _selectedMaintenanceType = State(initialValue: Localization.MaintenanceType.replacement)
        } else if localizedServiceTypes.contains(serviceTypeValue) || oldRussianServiceTypes.contains(serviceTypeValue) {
            _selectedMaintenanceType = State(initialValue: Localization.MaintenanceType.maintenance)
        } else {
            _selectedMaintenanceType = State(initialValue: Localization.MaintenanceType.other)
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
                Section(header: Text(Localization.MaintenanceInput.dateAndMileage)) {
                    DatePicker(Localization.MaintenanceInput.maintenanceDate, selection: $date, displayedComponents: .date)
                    
                    TextField(Localization.MaintenanceInput.mileage, text: $mileage)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text(Localization.MaintenanceInput.works)) {
                    Picker(Localization.MaintenanceInput.works, selection: $selectedMaintenanceType) {
                        ForEach(maintenanceTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedMaintenanceType == Localization.MaintenanceType.maintenance {
                        Picker(Localization.MaintenanceInput.works, selection: $serviceType) {
                            Text(Localization.MaintenanceInput.selectType).tag("")
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
                                    Text("\(Localization.MaintenanceInput.addType) \"\(serviceType)\"")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    } else if selectedMaintenanceType == Localization.MaintenanceType.repair {
                        Picker(Localization.MaintenanceInput.works, selection: $serviceType) {
                            Text(Localization.MaintenanceInput.selectType).tag("")
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
                                    Text("\(Localization.MaintenanceInput.addType) \"\(serviceType)\"")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    } else if selectedMaintenanceType == Localization.MaintenanceType.replacement {
                        Picker(Localization.MaintenanceInput.works, selection: $serviceType) {
                            Text(Localization.MaintenanceInput.selectType).tag("")
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
                                    Text("\(Localization.MaintenanceInput.addType) \"\(serviceType)\"")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    } else {
                        // "Другое" - текстовое поле
                        TextField(Localization.MaintenanceInput.describeWorkType, text: $serviceType)
                    }
                }
                
                Section(header: Text(Localization.MaintenanceInput.description)) {
                    TextField(Localization.MaintenanceInput.worksDescription, text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text(Localization.MaintenanceInput.performedWorks)) {
                    TextField(Localization.MaintenanceInput.performedWorksList, text: $worksPerformed, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text(Localization.MaintenanceInput.document)) {
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
                                Button(Localization.MaintenanceInput.deletePhoto) {
                                    selectedImage = nil
                                    extractedText = ""
                                }
                                .foregroundColor(.red)
                                
                                if isAnalyzingImage {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text(Localization.MaintenanceInput.analyzing)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else if !extractedText.isEmpty {
                                    Text(Localization.MaintenanceInput.textRecognized)
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
                                Text(Localization.MaintenanceInput.attachPhoto)
                            }
                        }
                    }
                }
                
                if !extractedText.isEmpty {
                    Section(header: Text(Localization.MaintenanceInput.recognizedText)) {
                        ScrollView {
                            Text(extractedText)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 100)
                        
                        Button(Localization.MaintenanceInput.useRecognizedText) {
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
            .navigationTitle(Localization.MaintenanceInput.editMaintenance)
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
                    .accessibilityLabel(Localization.Common.cancel)
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
                    .accessibilityLabel(Localization.Common.save)
                }
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
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    analyzeImage(image)
                }
            }
            .alert(Localization.MaintenanceInput.addMaintenanceType, isPresented: $showAddServiceType) {
                TextField(Localization.MaintenanceInput.addTypeName, text: $customServiceType)
                Button(Localization.MaintenanceInput.addType) {
                    if !customServiceType.isEmpty {
                        serviceType = customServiceType
                    }
                }
                Button(Localization.Common.cancel, role: .cancel) {}
            } message: {
                Text(Localization.MaintenanceInput.enterMaintenanceType)
            }
            .alert(Localization.MaintenanceInput.addRepairType, isPresented: $showAddRepairType) {
                TextField(Localization.MaintenanceInput.addTypeName, text: $customServiceType)
                Button(Localization.MaintenanceInput.addType) {
                    if !customServiceType.isEmpty {
                        serviceType = customServiceType
                    }
                }
                Button(Localization.Common.cancel, role: .cancel) {}
            } message: {
                Text(Localization.MaintenanceInput.enterRepairType)
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

