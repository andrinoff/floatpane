import AppKit
import Carbon

final class GlobalShortcutManager {
    static var shared: GlobalShortcutManager?

    private weak var model: WallpaperViewModel?
    private weak var store: SettingsStore?
    private var hotKeyRefs: [Int: EventHotKeyRef] = [:]
    private var actions: [UInt32: () -> Void] = [:]
    private var handlerInstalled = false

    init(model: WallpaperViewModel, store: SettingsStore) {
        self.model = model
        self.store = store
        GlobalShortcutManager.shared = self
        installHandlerIfNeeded()
    }

    private func installHandlerIfNeeded() {
        guard !handlerInstalled else { return }
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyReleased))
        InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyHandler,
            1,
            &eventSpec,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            nil
        )
        handlerInstalled = true
    }

    func registerAll() {
        unregisterAll()
        guard let store else { return }
        registerHotKey(id: 1, hotkey: store.toggleHotkey) { [weak self] in
            self?.model?.toggleWindowVisibility()
        }
    }

    private func registerHotKey(id: Int, hotkey: Hotkey, action: @escaping () -> Void) {
        actions[UInt32(id)] = action

        var ref: EventHotKeyRef?
        let eventID = EventHotKeyID(signature: OSType("FPN1".fourCharCode),
                                    id: UInt32(id))

        let status = RegisterEventHotKey(UInt32(hotkey.keyCode),
                                         UInt32(hotkey.modifiers),
                                         eventID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &ref)
        if status == noErr, let ref {
            hotKeyRefs[id] = ref
        }
    }

    private func unregisterAll() {
        hotKeyRefs.values.forEach { UnregisterEventHotKey($0) }
        hotKeyRefs.removeAll()
        actions.removeAll()
    }

    fileprivate func handleHotKey(id: UInt32, signature: OSType) {
        guard signature == OSType("FPN1".fourCharCode) else { return }
        actions[id]?()
    }
}

// C-compatible callback
private let hotKeyHandler: EventHandlerUPP = { (_, event, userData) -> OSStatus in
    guard let event, let userData else { return noErr }
    var hkID = EventHotKeyID()
    GetEventParameter(event,
                      EventParamName(kEventParamDirectObject),
                      EventParamType(typeEventHotKeyID),
                      nil,
                      MemoryLayout<EventHotKeyID>.size,
                      nil,
                      &hkID)

    let manager = Unmanaged<GlobalShortcutManager>.fromOpaque(userData).takeUnretainedValue()
    manager.handleHotKey(id: hkID.id, signature: hkID.signature)
    return noErr
}

private extension String {
    var fourCharCode: UInt32 {
        var result: UInt32 = 0
        for scalar in utf16 { result = (result << 8) + UInt32(scalar) }
        return result
    }
}
