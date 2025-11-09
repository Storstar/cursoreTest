import SwiftUI
import CoreData

struct MaintenanceView: View {
    @EnvironmentObject var carViewModel: CarViewModel
    @StateObject private var maintenanceViewModel = MaintenanceViewModel()
    @State private var showAddMaintenance = false
    @State private var editingRecord: MaintenanceRecord?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if maintenanceViewModel.maintenanceRecords.isEmpty && maintenanceViewModel.upcomingServices.isEmpty {
                        // Пустое состояние
                        VStack(spacing: 24) {
                            Spacer()
                            
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 64))
                                .foregroundColor(.blue.opacity(0.6))
                            
                            VStack(spacing: 8) {
                                Text("Нет записей о работах")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Добавьте первую запись о работах")
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
                            Section(header: Text("Предстоящие работы")) {
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
                                                Label("Удалить", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        
                        // История работ
                        Section(header: Text("История работ")) {
                            if maintenanceViewModel.maintenanceRecords.isEmpty {
                                Text("Нет записей о работах")
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
                                            Label("Удалить", systemImage: "trash")
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
            .navigationTitle("Работы")
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
                            Text("Просрочено на \(abs(days)) дн.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.red)
                        } else if days <= 30 {
                            Text("Через \(days) дн.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.orange)
                        } else {
                            Text("Через \(days) дн.")
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
            
            Text("Пробег: \(record.mileage) км")
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
                    Text("Документ прикреплен")
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
    
    let maintenanceTypes = ["ТО", "Ремонт", "Замена", "Другое"]
    let serviceTypes = ["Плановое ТО", "Другое"] // Для категории "ТО"
    let replacementTypes = ["Замена масла", "Замена фильтров", "Замена тормозов", "Замена шин", "Диагностика", "Другое"] // Для категории "Замена"
    let repairTypes = ["Ремонт двигателя", "Ремонт коробки передач", "Ремонт подвески", "Ремонт тормозов", "Ремонт кузова", "Ремонт электрики", "Другое"]
    
    @State private var selectedMaintenanceType: String = "ТО"
    @State private var customServiceType: String = ""
    @State private var showAddServiceType = false
    @State private var showAddRepairType = false
    @State private var isPlanned = false
    @State private var plannedDate = Date()
    @State private var plannedMileage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Дата и пробег")) {
                    if isPlanned {
                        DatePicker("Дата запланированной работы", selection: $plannedDate, displayedComponents: .date)
                    } else {
                        DatePicker("Дата работ", selection: $date, displayedComponents: .date)
                    }
                    
                    if !isPlanned {
                        TextField("Пробег (км)", text: $mileage)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section(header: Text("Работы")) {
                    Picker("Работы", selection: $selectedMaintenanceType) {
                        ForEach(maintenanceTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    typeWorkSection
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
                    documentSection
                }
                
                Section(header: Text("Запланированная работа")) {
                    Toggle("Запланированная работа", isOn: $isPlanned)
                    
                    if isPlanned {
                        // Дата задается в начале экрана, пробег не нужен для запланированных работ
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
                            useExtractedText()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Работы")
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
                    .accessibilityLabel("Закрыть")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveMaintenance()
                    }
                    .disabled(serviceType.isEmpty || mileage.isEmpty)
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
            .alert("Добавить тип работ", isPresented: $showAddServiceType) {
                TextField("Название типа", text: $customServiceType)
                Button("Добавить") {
                    if !customServiceType.isEmpty {
                        serviceType = customServiceType
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Введите название нового типа работ")
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
    
    @ViewBuilder
    private var typeWorkSection: some View {
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
            TextField("Опишите тип работы", text: $serviceType)
        }
    }
    
    @ViewBuilder
    private var documentSection: some View {
        if let image = selectedImage {
            HStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                
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
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
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
