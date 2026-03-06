import SwiftUI

@main
struct ServantApp: App {
    @StateObject private var serverManager = ServerManager()
    @StateObject private var localizationManager = LocalizationManager()

    var body: some Scene {
        MenuBarExtra("Servant", systemImage: "terminal.fill") {
            MenuBarView()
                .environmentObject(serverManager)
                .environmentObject(localizationManager)
        }
        .menuBarExtraStyle(.window) 
        
        WindowGroup(id: "SettingsWindow") {
            SettingsView()
                .environmentObject(serverManager)
                .environmentObject(localizationManager)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 400)
    }
}
