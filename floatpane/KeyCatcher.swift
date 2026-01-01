import SwiftUI
import Carbon

enum KeyEvent { case left, right, enter, escape }

struct KeyCatcher: NSViewRepresentable {
    var onKey: (KeyEvent) -> Void

    func makeNSView(context: Context) -> NSView {
        let v = KeyCatcherView()
        v.onKey = onKey
        DispatchQueue.main.async {
            if let win = v.window {
                win.makeFirstResponder(v)
                win.makeKey()
            }
        }
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak v] note in
            if let win = note.object as? NSWindow, win == v?.window {
                win.makeFirstResponder(v)
            }
        }
        NotificationCenter.default.addObserver(
            forName: .keyCatcherFocusRequest,
            object: nil,
            queue: .main
        ) { [weak v] _ in
            guard let view = v, let window = view.window else { return }
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(view)
        }
        return v
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

final class KeyCatcherView: NSView {
    var onKey: ((KeyEvent) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case UInt16(kVK_LeftArrow):  onKey?(.left)
        case UInt16(kVK_RightArrow): onKey?(.right)
        case UInt16(kVK_Return):     onKey?(.enter)
        case UInt16(kVK_Escape):     onKey?(.escape)
        default: break
        }
    }
}

extension Notification.Name {
    static let keyCatcherFocusRequest = Notification.Name("FloatpaneKeyCatcherFocusRequest")
}
