import AppKit
import SwiftUI
import Combine // Fixes the ObservableObject error

class HotKeyManager: ObservableObject {
    static let shared = HotKeyManager()
    
    // Store user preferences
    @AppStorage("hotkeyKey") var storedKey: String = "x"
    // We store as Int, but will convert to UInt when needed
    @AppStorage("hotkeyModifiers") var storedModifiers: Int = Int(NSEvent.ModifierFlags([.command, .shift]).rawValue)
    
    private var monitor: Any?
    
    // Fixes the "Cannot convert value of type 'UInt' to expected argument type 'Int'" error
    var currentModifiers: NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: UInt(storedModifiers))
    }
    
    func startMonitoring(action: @escaping () -> Void) {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
        
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            print("WARNING: Accessibility permissions not granted.")
            return
        }
        
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            
            // Intersection compares the actual keys pressed vs our saved modifiers
            let eventMods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let targetMods = self.currentModifiers.intersection(.deviceIndependentFlagsMask)
            
            if let char = event.charactersIgnoringModifiers?.lowercased(),
               char == self.storedKey.lowercased(),
               eventMods == targetMods {
                
                DispatchQueue.main.async {
                    action()
                }
            }
        }
    }
}
