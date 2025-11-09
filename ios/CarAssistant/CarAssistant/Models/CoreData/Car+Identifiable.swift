import Foundation
import CoreData

extension Car: Identifiable {
    // Car уже имеет id: UUID из CoreData, поэтому Identifiable автоматически работает
    // Swift автоматически использует существующее свойство id: UUID для протокола Identifiable
}

