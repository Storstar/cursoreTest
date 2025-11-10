import Foundation
import CoreData

extension ChatCoreData {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatCoreData> {
        return NSFetchRequest<ChatCoreData>(entityName: "Chat")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var carId: UUID
    @NSManaged public var title: String
    @NSManaged public var lastMessage: String
    @NSManaged public var timestamp: Date
    @NSManaged public var messages: NSSet?
}

extension ChatCoreData {
    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: ChatMessageCoreData)
    
    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: ChatMessageCoreData)
    
    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)
    
    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)
}

