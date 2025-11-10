import SwiftUI
import CoreData

struct MaintenanceView: View {
    @EnvironmentObject var carViewModel: CarViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    @StateObject private var maintenanceViewModel = MaintenanceViewModel()
    @State private var showAddMaintenance = false
    @State private var editingRecord: MaintenanceRecord?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Градиентный фон приложения (авто ассистент)
                appGradientBackground
                    .ignoresSafeArea()
                
                Group {
                    if maintenanceViewModel.maintenanceRecords.isEmpty && maintenanceViewModel.upcomingServices.isEmpty {
                        // Пустое состояние
                        VStack(spacing: 24) {
                            Spacer()
                            
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 64))
                                .foregroundColor(.blue.opacity(0.6))
                            
                            VStack(spacing: 8) {
                                Text(Localization.Maintenance.noRecords)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(Localization.Maintenance.addMaintenance)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // Предстоящие работы
                        if !maintenanceViewModel.upcomingServices.isEmpty {
                            Section(header: Text(Localization.Maintenance.upcomingServices)) {
                                ForEach(maintenanceViewModel.upcomingServices, id: \.id) { record in
                                    UpcomingServiceCard(record: record)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            editingRecord = record
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                maintenanceViewModel.deleteMaintenanceRecord(record)
                                            } label: {
                                                Label(Localization.Common.delete, systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        
                        // История работ
                        Section(header: Text(Localization.Maintenance.history)) {
                            if maintenanceViewModel.maintenanceRecords.isEmpty {
                                Text(Localization.Maintenance.noRecords)
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(maintenanceViewModel.maintenanceRecords, id: \.id) { record in
                                    MaintenanceHistoryCard(
                                        record: record,
                                        onEdit: {
                                            editingRecord = record
                                        },
                                        onDelete: {
                                            maintenanceViewModel.deleteMaintenanceRecord(record)
                                        }
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingRecord = record
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        maintenanceViewModel.deleteMaintenanceRecord(record)
                                    } label: {
                                        Label(Localization.Common.delete, systemImage: "trash")
                                    }
                                    }
                                }
                            }
                        }
                    }
                }
                }
                
                // Плавающая кнопка "Добавить работы" - всегда видна
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingAddWorkButton {
                            showAddMaintenance = true
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .scrollContentBackground(.hidden) // Скрываем фон List, чтобы был виден градиент
            .navigationTitle(Localization.Maintenance.title)
            .sheet(isPresented: $showAddMaintenance) {
                AddMaintenanceView()
                    .environmentObject(carViewModel)
                    .environmentObject(maintenanceViewModel)
            }
            .sheet(isPresented: Binding(
                get: { editingRecord != nil },
                set: { if !$0 { editingRecord = nil } }
            )) {
                if let record = editingRecord {
                    EditMaintenanceView(record: record)
                        .environmentObject(carViewModel)
                        .environmentObject(maintenanceViewModel)
                }
            }
            .task {
                if let car = carViewModel.car {
                    maintenanceViewModel.loadMaintenanceRecords(for: car)
                }
            }
            .onChange(of: carViewModel.car?.id) { _ in
                if let car = carViewModel.car {
                    maintenanceViewModel.loadMaintenanceRecords(for: car)
                }
            }
        }
    }
    
    /// Градиентный фон приложения (авто ассистент)
    private var appGradientBackground: some View {
        let isDark = themeManager.colorScheme == .dark || (themeManager.colorScheme == nil && systemColorScheme == .dark)
        
        return LinearGradient(
            colors: isDark ? [
                Color(red: 0.15, green: 0.17, blue: 0.20),      // Темно-синий (верх)
                Color(red: 0.12, green: 0.15, blue: 0.18),    // Темно-серо-синий (середина)
                Color(red: 0.10, green: 0.12, blue: 0.15)     // Темно-серый (низ)
            ] : [
                Color(red: 0.95, green: 0.97, blue: 1.0),      // Светло-голубой (верх)
                Color(red: 0.92, green: 0.95, blue: 0.98),    // Светло-серо-голубой (середина)
                Color(red: 0.88, green: 0.92, blue: 0.96)     // Светло-серый (низ)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// Карточка предстоящего ТО
struct UpcomingServiceCard: View {
    let record: MaintenanceRecord
    
    private var daysUntilService: Int? {
        let targetDate = record.isPlanned ? record.date : (record.nextServiceDate ?? record.date)
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: targetDate)
        return components.day
    }
    
    private var isOverdue: Bool {
        guard record.isPlanned else { return false }
        return record.date < Date()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.serviceType ?? "ТО")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                let targetDate = record.isPlanned ? record.date : (record.nextServiceDate ?? record.date)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(targetDate, style: .date)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(isOverdue ? .red : .secondary)
                    
                    if let days = daysUntilService {
                        if isOverdue {
                            Text("\(Localization.MaintenanceInput.overdue) \(abs(days)) \(Localization.MaintenanceInput.days)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.red)
                        } else if days <= 30 {
                            Text("\(Localization.MaintenanceInput.inDays) \(days) \(Localization.MaintenanceInput.days)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.orange)
                        } else {
                            Text("\(Localization.MaintenanceInput.inDays) \(days) \(Localization.MaintenanceInput.days)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            HStack(spacing: 16) {
                if record.nextServiceMileage > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "speedometer")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text("\(record.nextServiceMileage) км")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                let targetDate = record.isPlanned ? record.date : (record.nextServiceDate ?? record.date)
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    Text(targetDate, style: .date)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            if let description = record.serviceDescription, !description.isEmpty {
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isOverdue ? Color.red.opacity(0.15) : Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isOverdue ? Color.red.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
    }
}

// Карточка истории ТО
struct MaintenanceHistoryCard: View {
    let record: MaintenanceRecord
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.serviceType ?? "ТО")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(record.date, style: .date)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
                Text("\(Localization.MaintenanceInput.mileageLabel) \(record.mileage) км")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
            
            if let worksPerformed = record.worksPerformed, !worksPerformed.isEmpty {
                Text(worksPerformed)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            if record.documentImageData != nil {
                HStack {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    Text(Localization.MaintenanceInput.documentAttached)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// Форма добавления ТО
struct AddMaintenanceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var carViewModel: CarViewModel
    @EnvironmentObject var maintenanceViewModel: MaintenanceViewModel
    
    @State private var date = Date()
    @State private var mileage: String = ""
    @State private var serviceType: String = ""
    @State private var description: String = ""
    @State private var worksPerformed: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showPhotoPicker = false
    @State private var showImageOptions = false
    @State private var isAnalyzingImage = false
    @State private var extractedText: String = ""
    
    var maintenanceTypes: [String] { Localization.MaintenanceType.maintenanceTypes }
    var serviceTypes: [String] { Localization.MaintenanceType.serviceTypes }
    var replacementTypes: [String] { Localization.MaintenanceType.replacementTypes }
    var repairTypes: [String] { Localization.MaintenanceType.repairTypes }
    
    @State private var selectedMaintenanceType: String = ""
    @State private var customServiceType: String = ""
    @State private var showAddServiceType = false
    @State private var showAddRepairType = false
    @State private var isPlanned = false
    @State private var plannedDate = Date()
    @State private var plannedMileage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(Localization.MaintenanceInput.dateAndMileage)) {
                    if isPlanned {
                        DatePicker(Localization.MaintenanceInput.plannedDate, selection: $plannedDate, displayedComponents: .date)
                    } else {
                        DatePicker(Localization.MaintenanceInput.workDate, selection: $date, displayedComponents: .date)
                    }
                    
                    if !isPlanned {
                        TextField(Localization.MaintenanceInput.mileage, text: $mileage)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section(header: Text(Localization.MaintenanceInput.works)) {
                    Picker(Localization.MaintenanceInput.works, selection: $selectedMaintenanceType) {
                        ForEach(maintenanceTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    typeWorkSection
                }
                .onAppear {
                    if selectedMaintenanceType.isEmpty {
                        selectedMaintenanceType = maintenanceTypes.first ?? ""
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
                    documentSection
                }
                
                Section(header: Text(Localization.MaintenanceInput.plannedWork)) {
                    Toggle(Localization.MaintenanceInput.plannedWork, isOn: $isPlanned)
                    
                    if isPlanned {
                        // Дата задается в начале экрана, пробег не нужен для запланированных работ
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
                            useExtractedText()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle(Localization.Maintenance.title)
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
                    .disabled(serviceType.isEmpty || (!isPlanned && mileage.isEmpty))
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
            .alert(Localization.MaintenanceInput.addWorkType, isPresented: $showAddServiceType) {
                TextField(Localization.MaintenanceInput.addTypeName, text: $customServiceType)
                Button(Localization.MaintenanceInput.addType) {
                    if !customServiceType.isEmpty {
                        serviceType = customServiceType
                    }
                }
                Button(Localization.Common.cancel, role: .cancel) {}
            } message: {
                Text(Localization.MaintenanceInput.enterWorkTypeName)
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
    
    @ViewBuilder
    private var typeWorkSection: some View {
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
            TextField(Localization.MaintenanceInput.describeWorkType, text: $serviceType)
        }
    }
    
    @ViewBuilder
    private var documentSection: some View {
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
    
    private func useExtractedText() {
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
        guard let car = carViewModel.car,
              let mileageInt = Int32(mileage) else {
            return
        }
        
        // Сжимаем изображение перед сохранением в Core Data для экономии памяти
        let imageData = selectedImage.flatMap { ImageOptimizer.compressImage($0, maxDimension: 800, compressionQuality: 0.7) }
        
        // Для запланированных работ используем plannedDate, для остальных - date
        let targetDate = isPlanned ? plannedDate : date
        
        maintenanceViewModel.createMaintenanceRecord(
            date: targetDate,
            mileage: mileageInt,
            serviceType: serviceType.isEmpty ? nil : serviceType,
            description: description.isEmpty ? nil : description,
            worksPerformed: worksPerformed.isEmpty ? nil : worksPerformed,
            documentImageData: imageData,
            extractedText: extractedText.isEmpty ? nil : extractedText,
            isPlanned: isPlanned,
            plannedDate: isPlanned ? plannedDate : nil,
            plannedMileage: nil, // Пробег не нужен для запланированных работ
            for: car
        )
        
        dismiss()
    }
}

// Плавающая кнопка "Добавить работы"
struct FloatingAddWorkButton: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
                onTap()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.black)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
