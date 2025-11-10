import Foundation
import CoreData

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    @NSManaged public var email: String
    @NSManaged public var id: UUID
    @NSManaged public var password: String
    @NSManaged public var username: String
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var fullAddress: String?
    @NSManaged public var cars: NSSet?
    @NSManaged public var requests: NSSet?
}

extension User {
    @objc(addCarsObject:)
    @NSManaged public func addToCars(_ value: Car)
    
    @objc(removeCarsObject:)
    @NSManaged public func removeFromCars(_ value: Car)
    
    @objc(addCars:)
    @NSManaged public func addToCars(_ values: NSSet)
    
    @objc(removeCars:)
    @NSManaged public func removeFromCars(_ values: NSSet)
    
    @objc(addRequestsObject:)
    @NSManaged public func addToRequests(_ value: Request)
    
    @objc(removeRequestsObject:)
    @NSManaged public func removeFromRequests(_ value: Request)
    
    @objc(addRequests:)
    @NSManaged public func addToRequests(_ values: NSSet)
    
    @objc(removeRequests:)
    @NSManaged public func removeFromRequests(_ values: NSSet)
}
