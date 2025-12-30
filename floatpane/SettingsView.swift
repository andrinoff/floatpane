import SwiftUI

struct SettingsView: View {
    @ObservedObject var hotkeyManager = HotKeyManager.shared
    
    // Available modifiers for the picker
    let modifiers: [(name: String, value: NSEvent.ModifierFlags)] = [
        ("Cmd + Shift", [.command, .shift]),
        ("Cmd + Option", [.command, .option]),
        ("Ctrl + Shift", [.control, .shift]),
        ("Option + Shift", [.option, .shift])
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Global Shortcut")) {
                Text("Select a modifier combination and a key to toggle Floatpane.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Modifiers:", selection: Binding(
                    get: { hotkeyManager.currentModifiers.rawValue },
                    set: { hotkeyManager.storedModifiers = Int($0) }
                )) {
                    ForEach(modifiers, id: \.value.rawValue) { modifier in
                        Text(modifier.name).tag(modifier.value.rawValue)
                    }
                }
                
                HStack {
                    Text("Key:")
                    TextField("Key", text: $hotkeyManager.storedKey)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
                        .onChange(of: hotkeyManager.storedKey) { newValue in
                            // Restrict to 1 character
                            if newValue.count > 1 {
                                hotkeyManager.storedKey = String(newValue.prefix(1))
                            }
                        }
                }
            }
            
            Section {
                Button("Restart App to Apply Keybind Changes") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 350, height: 200)
    }
}
