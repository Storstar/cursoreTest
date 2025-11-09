import Foundation

struct UserData: Codable {
    let id: UUID
    var username: String
    var email: String
    var password: String
    
    init(id: UUID = UUID(), username: String = "", email: String = "", password: String = "") {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
    }
}


