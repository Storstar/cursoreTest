//
//  Localization.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import Foundation

/// Структура для хранения всех локализованных строк
struct Localization {
    private static var currentLanguage: LanguageManager.AppLanguage {
        LanguageManager.shared.currentLanguage
    }
    
    // MARK: - Common
    
    struct Common {
        static var ok: String { localized("common.ok") }
        static var cancel: String { localized("common.cancel") }
        static var save: String { localized("common.save") }
        static var delete: String { localized("common.delete") }
        static var edit: String { localized("common.edit") }
        static var add: String { localized("common.add") }
        static var close: String { localized("common.close") }
        static var back: String { localized("common.back") }
        static var next: String { localized("common.next") }
        static var done: String { localized("common.done") }
    }
    
    // MARK: - Tab Bar
    
    struct TabBar {
        static var chats: String { localized("tabbar.chats") }
        static var maintenance: String { localized("tabbar.maintenance") }
        static var profile: String { localized("tabbar.profile") }
    }
    
    // MARK: - Welcome
    
    struct Welcome {
        static var title: String { localized("welcome.title") }
        static var subtitle: String { localized("welcome.subtitle") }
        static var login: String { localized("welcome.login") }
        static var register: String { localized("welcome.register") }
    }
    
    // MARK: - Settings
    
    struct Settings {
        static var profile: String { localized("settings.profile") }
        static var myCars: String { localized("settings.myCars") }
        static var noCars: String { localized("settings.noCars") }
        static var addCar: String { localized("settings.addCar") }
        static var geolocation: String { localized("settings.geolocation") }
        static var autoDetermined: String { localized("settings.autoDetermined") }
        static var determineLocation: String { localized("settings.determineLocation") }
        static var determining: String { localized("settings.determining") }
        static var appearance: String { localized("settings.appearance") }
        static var theme: String { localized("settings.theme") }
        static var lightTheme: String { localized("settings.lightTheme") }
        static var darkTheme: String { localized("settings.darkTheme") }
        static var language: String { localized("settings.language") }
        static var account: String { localized("settings.account") }
        static var logout: String { localized("settings.logout") }
    }
    
    // MARK: - Chat
    
    struct Chat {
        static var startDialog: String { localized("chat.startDialog") }
        static var writeMessage: String { localized("chat.writeMessage") }
        static var generalQuestion: String { localized("chat.generalQuestion") }
        static var checkEngine: String { localized("chat.checkEngine") }
        static var battery: String { localized("chat.battery") }
        static var brakeSystem: String { localized("chat.brakeSystem") }
        static var engine: String { localized("chat.engine") }
        static var transmission: String { localized("chat.transmission") }
        static var suspension: String { localized("chat.suspension") }
        static var electrical: String { localized("chat.electrical") }
        static var acSystem: String { localized("chat.acSystem") }
        static var tires: String { localized("chat.tires") }
        static var chats: String { localized("chat.chats") }
    }
    
    // MARK: - Maintenance
    
    struct Maintenance {
        static var title: String { localized("maintenance.title") }
        static var noRecords: String { localized("maintenance.noRecords") }
        static var addMaintenance: String { localized("maintenance.addMaintenance") }
        static var upcomingServices: String { localized("maintenance.upcomingServices") }
        static var history: String { localized("maintenance.history") }
        static var addFirstRecord: String { localized("maintenance.addFirstRecord") }
    }
    
    // MARK: - Car Input
    
    struct CarInput {
        static var addCar: String { localized("carInput.addCar") }
        static var brand: String { localized("carInput.brand") }
        static var model: String { localized("carInput.model") }
        static var year: String { localized("carInput.year") }
        static var engine: String { localized("carInput.engine") }
        static var selectEngine: String { localized("carInput.selectEngine") }
        static var additionalParams: String { localized("carInput.additionalParams") }
        static var fuelType: String { localized("carInput.fuelType") }
        static var driveType: String { localized("carInput.driveType") }
        static var transmission: String { localized("carInput.transmission") }
        static var notSpecified: String { localized("carInput.notSpecified") }
        static var vin: String { localized("carInput.vin") }
        static var vinOptional: String { localized("carInput.vinOptional") }
        static var additionalInfo: String { localized("carInput.additionalInfo") }
        static var notes: String { localized("carInput.notes") }
        static var addPhoto: String { localized("carInput.addPhoto") }
        static var selectSource: String { localized("carInput.selectSource") }
        static var camera: String { localized("carInput.camera") }
        static var gallery: String { localized("carInput.gallery") }
        static var enterBrandFirst: String { localized("carInput.enterBrandFirst") }
        static var editCar: String { localized("carInput.editCar") }
        static var myCars: String { localized("carInput.myCars") }
        static var addFirstCar: String { localized("carInput.addFirstCar") }
    }
    
    // MARK: - Maintenance Input
    
    struct MaintenanceInput {
        static var editMaintenance: String { localized("maintenanceInput.editMaintenance") }
        static var dateAndMileage: String { localized("maintenanceInput.dateAndMileage") }
        static var maintenanceDate: String { localized("maintenanceInput.maintenanceDate") }
        static var plannedDate: String { localized("maintenanceInput.plannedDate") }
        static var workDate: String { localized("maintenanceInput.workDate") }
        static var mileage: String { localized("maintenanceInput.mileage") }
        static var works: String { localized("maintenanceInput.works") }
        static var selectType: String { localized("maintenanceInput.selectType") }
        static var description: String { localized("maintenanceInput.description") }
        static var worksDescription: String { localized("maintenanceInput.worksDescription") }
        static var performedWorks: String { localized("maintenanceInput.performedWorks") }
        static var performedWorksList: String { localized("maintenanceInput.performedWorksList") }
        static var document: String { localized("maintenanceInput.document") }
        static var attachPhoto: String { localized("maintenanceInput.attachPhoto") }
        static var deletePhoto: String { localized("maintenanceInput.deletePhoto") }
        static var analyzing: String { localized("maintenanceInput.analyzing") }
        static var textRecognized: String { localized("maintenanceInput.textRecognized") }
        static var recognizedText: String { localized("maintenanceInput.recognizedText") }
        static var useRecognizedText: String { localized("maintenanceInput.useRecognizedText") }
        static var plannedWork: String { localized("maintenanceInput.plannedWork") }
        static var addType: String { localized("maintenanceInput.addType") }
        static var addTypeName: String { localized("maintenanceInput.addTypeName") }
        static var addMaintenanceType: String { localized("maintenanceInput.addMaintenanceType") }
        static var addRepairType: String { localized("maintenanceInput.addRepairType") }
        static var enterMaintenanceType: String { localized("maintenanceInput.enterMaintenanceType") }
        static var enterRepairType: String { localized("maintenanceInput.enterRepairType") }
        static var describeWorkType: String { localized("maintenanceInput.describeWorkType") }
        static var addWorkType: String { localized("maintenanceInput.addWorkType") }
        static var enterWorkTypeName: String { localized("maintenanceInput.enterWorkTypeName") }
        static var overdue: String { localized("maintenanceInput.overdue") }
        static var days: String { localized("maintenanceInput.days") }
        static var inDays: String { localized("maintenanceInput.in") }
        static var mileageLabel: String { localized("maintenanceInput.mileageLabel") }
        static var documentAttached: String { localized("maintenanceInput.documentAttached") }
    }
    
    // MARK: - Maintenance Types
    
    struct MaintenanceType {
        static var maintenance: String { localized("maintenanceType.maintenance") }
        static var repair: String { localized("maintenanceType.repair") }
        static var replacement: String { localized("maintenanceType.replacement") }
        static var other: String { localized("maintenanceType.other") }
        static var plannedMaintenance: String { localized("maintenanceType.plannedMaintenance") }
        static var oilChange: String { localized("maintenanceType.oilChange") }
        static var filterReplacement: String { localized("maintenanceType.filterReplacement") }
        static var brakeReplacement: String { localized("maintenanceType.brakeReplacement") }
        static var tireReplacement: String { localized("maintenanceType.tireReplacement") }
        static var diagnostics: String { localized("maintenanceType.diagnostics") }
        static var engineRepair: String { localized("maintenanceType.engineRepair") }
        static var transmissionRepair: String { localized("maintenanceType.transmissionRepair") }
        static var suspensionRepair: String { localized("maintenanceType.suspensionRepair") }
        static var brakeRepair: String { localized("maintenanceType.brakeRepair") }
        static var bodyRepair: String { localized("maintenanceType.bodyRepair") }
        static var electricalRepair: String { localized("maintenanceType.electricalRepair") }
        
        static var maintenanceTypes: [String] {
            [maintenance, repair, replacement, other]
        }
        
        static var serviceTypes: [String] {
            [plannedMaintenance, other]
        }
        
        static var replacementTypes: [String] {
            [oilChange, filterReplacement, brakeReplacement, tireReplacement, diagnostics, other]
        }
        
        static var repairTypes: [String] {
            [engineRepair, transmissionRepair, suspensionRepair, brakeRepair, bodyRepair, electricalRepair, other]
        }
    }
    
    // MARK: - Fuel Types
    
    struct FuelType {
        static var gasoline: String { localized("fuelType.gasoline") }
        static var diesel: String { localized("fuelType.diesel") }
        static var hybrid: String { localized("fuelType.hybrid") }
        static var electric: String { localized("fuelType.electric") }
        static var gas: String { localized("fuelType.gas") }
        static var gasGasoline: String { localized("fuelType.gasGasoline") }
        
        static var all: [String] {
            [gasoline, diesel, hybrid, electric, gas, gasGasoline]
        }
    }
    
    // MARK: - Drive Types
    
    struct DriveType {
        static var front: String { localized("driveType.front") }
        static var rear: String { localized("driveType.rear") }
        static var full: String { localized("driveType.full") }
        static var fourWD: String { localized("driveType.fourWD") }
        static var aws: String { localized("driveType.aws") }
        
        static var all: [String] {
            [front, rear, full, fourWD, aws]
        }
    }
    
    // MARK: - Transmission Types
    
    struct Transmission {
        static var manual: String { localized("transmission.manual") }
        static var automatic: String { localized("transmission.automatic") }
        static var robot: String { localized("transmission.robot") }
        static var cvt: String { localized("transmission.cvt") }
        static var dsg: String { localized("transmission.dsg") }
        static var dct: String { localized("transmission.dct") }
        
        static var all: [String] {
            [manual, automatic, robot, cvt, dsg, dct]
        }
    }
    
    // MARK: - Photo Selection
    
    struct Photo {
        static var takePhoto: String { localized("photo.takePhoto") }
        static var chooseFromGallery: String { localized("photo.chooseFromGallery") }
    }
    
    // MARK: - Helper
    
    private static func localized(_ key: String) -> String {
        return LanguageManager.shared.localizedString(for: key)
    }
}

