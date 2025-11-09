import Foundation
import CoreData

extension Response {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Response> {
        return NSFetchRequest<Response>(entityName: "Response")
    }
    
    @NSManaged public var createdAt: Date
    @NSManaged public var id: UUID
    @NSManaged public var text: String
    @NSManaged public var request: Request?
}
