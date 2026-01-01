import SwiftUI
import AppKit

struct WindowConfigurator: NSViewRepresentable {
    private static let preferredSize = NSSize(width: 1000, height: 360)

    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        DispatchQueue.main.async { Self.configureWindow() }
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { Self.configureWindow() }
    }

    static func refreshWindowConfiguration() {
        DispatchQueue.main.async { Self.configureWindow() }
    }

    private static func configureWindow() {
        // Find the window that hosts our content.
        // Since we are in a WindowGroup, NSApp.windows should contain it.
        // We look for a window that is NOT the settings window (if any) and has standard behavior.
        // A simple heuristic is the first window that is visible or just the first one.
        guard let screen = NSScreen.main, let window = NSApp.windows.first else { return }

        // Tag the window so we can find it later
        window.identifier = NSUserInterfaceItemIdentifier("FloatpaneMainWindow")

        // Use visibleFrame to center within the available desktop area (respecting Dock/Menu Bar)
        let screenRect = screen.visibleFrame
        let origin = NSPoint(
            x: screenRect.midX - preferredSize.width / 2,
            y: screenRect.midY - preferredSize.height / 2
        )
        let frame = NSRect(origin: origin, size: preferredSize)
        window.setFrame(frame, display: true)

        // Fix: Use .titled + .fullSizeContentView to allow the window to become key (accept keyboard input)
        // while maintaining a borderless appearance by hiding the title bar.
        window.styleMask = [.titled, .fullSizeContentView]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovable = false
        window.isMovableByWindowBackground = false
        window.hasShadow = false
        
        // Do NOT call window.center() as it overrides our precise positioning and places the window slightly high.
        window.makeKeyAndOrderFront(nil)
    }
}
