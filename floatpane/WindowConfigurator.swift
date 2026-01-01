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
        guard let screen = NSScreen.main, let window = NSApp.windows.first else { return }

        let origin = NSPoint(
            x: screen.frame.midX - preferredSize.width / 2,
            y: screen.frame.midY - preferredSize.height / 2
        )
        let frame = NSRect(origin: origin, size: preferredSize)
        window.setFrame(frame, display: true)

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.styleMask = [.borderless]
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.isMovable = false
        window.isMovableByWindowBackground = false
        window.hasShadow = false
        window.center()
    }
}
