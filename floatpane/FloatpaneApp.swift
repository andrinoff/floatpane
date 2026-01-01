import SwiftUI

@main
struct FloatpaneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = SettingsStore.shared
    @StateObject private var model = WallpaperViewModel.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environmentObject(store)
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Settings…") {
                    store.isSettingsPresented = true
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var shortcutManager: GlobalShortcutManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = SettingsStore.shared
        let model = WallpaperViewModel.shared
        shortcutManager = GlobalShortcutManager(model: model, store: store)
        shortcutManager?.registerAll()
    }
}
