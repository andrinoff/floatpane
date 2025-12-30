import SwiftUI

@main
struct FloatpaneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Main Floating Window
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, maxHeight: 350) // Adjusted for horizontal strip
                .onOpenURL { url in
                    if url.absoluteString == "floatpane://settings" {
                        SettingsWindowController.shared.showWindow(nil)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        // We use a custom controller for Settings to keep it separate from the floaty window logic
        SettingsScene()
    }
}

struct SettingsScene: Scene {
    var body: some Scene {
        Settings {
            EmptyView() // Placeholder, we handle settings via a custom controller below
        }
    }
}

// Custom Window Controller for Settings to ensure it looks standard
class SettingsWindowController: NSWindowController {
    private static var _shared: SettingsWindowController?
    
    static var shared: SettingsWindowController {
        if _shared == nil {
            _shared = SettingsWindowController()
        }
        return _shared!
    }

    private convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false
        )
        window.center()
        window.title = "Floatpane Settings"
        window.contentView = NSHostingView(rootView: SettingsView())
        window.isReleasedWhenClosed = false // Critical: prevents the object from being destroyed when closed
        self.init(window: window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Configure Main Window
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
            window.isOpaque = false
            window.backgroundColor = .clear
            window.titlebarAppearsTransparent = true
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.center()
        }
        
        // 2. Start Hotkey Listener
        HotKeyManager.shared.startMonitoring {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
        
        // 3. Handle ESC to hide
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // ESC
                NSApp.hide(nil)
                return nil
            }
            return event
        }
    }
}
