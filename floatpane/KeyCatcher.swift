import SwiftUI
import Carbon

enum KeyEvent { case left, right, enter, escape }

struct KeyCatcher: NSViewRepresentable {
    var onKey: (KeyEvent) -> Void

    func makeNSView(context: Context) -> KeyCatcherView {
        let view = KeyCatcherView()
        view.onKey = onKey
        return view
    }

    func updateNSView(_ nsView: KeyCatcherView, context: Context) {
        nsView.onKey = onKey
    }
}

final class KeyCatcherView: NSView {
    var onKey: ((KeyEvent) -> Void)?

    private var observers: [NSObjectProtocol] = []

    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        removeObservers()
        guard window != nil else { return }
        installObservers()
        focusSelf(ensureKey: true)
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

    deinit {
        removeObservers()
    }

    private func installObservers() {
        guard observers.isEmpty else { return }
        let center = NotificationCenter.default
        if let window {
            let keyObserver = center.addObserver(
                forName: NSWindow.didBecomeKeyNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                self?.focusSelf(ensureKey: false)
            }
            observers.append(keyObserver)
        }

        let focusObserver = center.addObserver(
            forName: .keyCatcherFocusRequest,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.focusSelf(ensureKey: true)
        }
        observers.append(focusObserver)
    }

    private func removeObservers() {
        let center = NotificationCenter.default
        observers.forEach { center.removeObserver($0) }
        observers.removeAll()
    }

    private func focusSelf(ensureKey: Bool) {
        guard let window else { return }
        if ensureKey {
            window.makeKeyAndOrderFront(nil)
        }
        // Ensure we become first responder after the window is ready
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window else { return }
            window.makeFirstResponder(self)
        }
    }
}

extension Notification.Name {
    static let keyCatcherFocusRequest = Notification.Name("FloatpaneKeyCatcherFocusRequest")
}
