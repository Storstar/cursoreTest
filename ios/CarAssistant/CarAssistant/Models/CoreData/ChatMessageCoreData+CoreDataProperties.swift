import Foundation
import CoreData

extension ChatMessageCoreData {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatMessageCoreData> {
        return NSFetchRequest<ChatMessageCoreData>(entityName: "ChatMessage")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var chatId: UUID
    @NSManaged public var content: String
    @NSManaged public var isUser: Bool
    @NSManaged public var timestamp: Date
    @NSManaged public var chat: ChatCoreData?
}

