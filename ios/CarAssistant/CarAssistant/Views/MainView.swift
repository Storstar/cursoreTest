import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    
    var body: some View {
        MainTabView()
            .environmentObject(authViewModel)
            .environmentObject(carViewModel)
    }
}
