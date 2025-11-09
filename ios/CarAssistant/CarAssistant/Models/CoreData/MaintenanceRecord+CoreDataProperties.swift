import Foundation
import CoreData

extension MaintenanceRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MaintenanceRecord> {
        return NSFetchRequest<MaintenanceRecord>(entityName: "MaintenanceRecord")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var mileage: Int32
    @NSManaged public var serviceType: String?
    @NSManaged public var serviceDescription: String?
    @NSManaged public var worksPerformed: String?
    @NSManaged public var nextServiceDate: Date?
    @NSManaged public var nextServiceMileage: Int32
    @NSManaged public var documentImageData: Data?
    @NSManaged public var extractedText: String?
    @NSManaged public var isPlanned: Bool
    @NSManaged public var car: Car?
}

