import Foundation

struct CarData: Codable, Identifiable {
    let id: UUID
    var brand: String
    var model: String
    var year: Int16
    var engine: String
    
    init(id: UUID = UUID(), brand: String = "", model: String = "", year: Int16 = 0, engine: String = "") {
        self.id = id
        self.brand = brand
        self.model = model
        self.year = year
        self.engine = engine
    }
}


