import SwiftUI

@main
struct CarAssistantApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var carViewModel = CarViewModel()
    
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(carViewModel)
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
