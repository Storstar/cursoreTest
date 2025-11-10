import Foundation
import CoreData

extension Request {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Request> {
        return NSFetchRequest<Request>(entityName: "Request")
    }
    
    @NSManaged public var chatId: UUID?
    @NSManaged public var createdAt: Date
    @NSManaged public var id: UUID
    @NSManaged public var imageData: Data?
    @NSManaged public var text: String?
    @NSManaged public var type: String
    @NSManaged public var topic: String? // Тема проблемы (Topic.rawValue)
    @NSManaged public var car: Car?
    @NSManaged public var response: Response?
    @NSManaged public var user: User?
}
