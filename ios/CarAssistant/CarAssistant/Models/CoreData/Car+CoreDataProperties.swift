import Foundation
import CoreData

extension Car {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }
    
    @NSManaged public var brand: String
    @NSManaged public var driveType: String?
    @NSManaged public var engine: String
    @NSManaged public var fuelType: String?
    @NSManaged public var id: UUID
    @NSManaged public var model: String
    @NSManaged public var transmission: String?
    @NSManaged public var vin: String?
    @NSManaged public var year: Int16
    @NSManaged public var photoData: Data?
    @NSManaged public var notes: String?
    @NSManaged public var maintenanceRecords: NSSet?
    @NSManaged public var requests: NSSet?
    @NSManaged public var user: User?
}

extension Car {
    @objc(addMaintenanceRecordsObject:)
    @NSManaged public func addToMaintenanceRecords(_ value: NSManagedObject)
    
    @objc(removeMaintenanceRecordsObject:)
    @NSManaged public func removeFromMaintenanceRecords(_ value: NSManagedObject)
    
    @objc(addMaintenanceRecords:)
    @NSManaged public func addToMaintenanceRecords(_ values: NSSet)
    
    @objc(removeMaintenanceRecords:)
    @NSManaged public func removeFromMaintenanceRecords(_ values: NSSet)
    
    @objc(addRequestsObject:)
    @NSManaged public func addToRequests(_ value: Request)
    
    @objc(removeRequestsObject:)
    @NSManaged public func removeFromRequests(_ value: Request)
    
    @objc(addRequests:)
    @NSManaged public func addToRequests(_ values: NSSet)
    
    @objc(removeRequests:)
    @NSManaged public func removeFromRequests(_ values: NSSet)
}
