import SwiftUI
import Carbon

struct SettingsView: View {
    @EnvironmentObject var store: SettingsStore
    @State private var recordingToggle = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings").font(.title2).bold()

            VStack(alignment: .leading, spacing: 8) {
                Text("Theme").font(.headline)
                ThemeGrid(themes: store.themes, selectedID: $store.selectedThemeID)
            }

            Divider()

            hotkeyRow(title: "Toggle window", hotkey: store.toggleHotkey, isRecording: $recordingToggle) { newHK in
                store.toggleHotkey = newHK
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Shortcuts require Accessibility permission.")
                    .font(.callout)
                Button("Open Privacy & Security ▸ Accessibility") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }

            HStack {
                Spacer()
                Button("Close") { store.isSettingsPresented = false }
            }
        }
        .padding(20)
        .frame(width: 700)
    }
}

struct ThemeGrid: View {
    let themes: [Theme]
    @Binding var selectedID: String

    private let columns = [GridItem(.adaptive(minimum: 220), spacing: 16)]

    var body: some View {
        Group {
            if themes.isEmpty {
                Text("No themes found")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(themes) { theme in
                            ThemeTile(theme: theme, isSelected: theme.id == selectedID)
                                .onTapGesture { selectedID = theme.id }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(height: 400)
    }
}

private struct ThemeTile: View {
    let theme: Theme
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(theme.name)
                .font(.headline)
                .foregroundColor(theme.onSurfaceColor)
        }
        .padding(.vertical, 8)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.surfaceColor.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? theme.primaryColor : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

extension SettingsView {
    private func hotkeyRow(title: String, hotkey: Hotkey, isRecording: Binding<Bool>, onChange: @escaping (Hotkey) -> Void) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(display(hotkey))
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.4)))
            Button(isRecording.wrappedValue ? "Press keys…" : "Change") {
                isRecording.wrappedValue = true
            }
            // intentionally no keyboardShortcut to avoid stealing focus
        }
        .background(
            KeyCaptureView(isCapturing: isRecording, onCapture: { hk in
                onChange(hk)
            })
        )
    }

    private func display(_ hk: Hotkey) -> String {
        var parts: [String] = []
        if hk.modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        if hk.modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if hk.modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if hk.modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        parts.append(keyName(from: hk.keyCode))
        return parts.joined()
    }

    private func keyName(from keyCode: UInt32) -> String {
        switch keyCode {
        case 0x00: return "A"
        case 0x01: return "S"
        case 0x02: return "D"
        case 0x03: return "F"
        case 0x04: return "H"
        case 0x05: return "G"
        case 0x06: return "Z"
        case 0x07: return "X"
        case 0x08: return "C"
        case 0x09: return "V"
        case 0x0B: return "B"
        case 0x0C: return "Q"
        case 0x0D: return "W"
        case 0x0E: return "E"
        case 0x0F: return "R"
        case 0x10: return "Y"
        case 0x11: return "T"
        case 0x12: return "1"
        case 0x13: return "2"
        case 0x14: return "3"
        case 0x15: return "4"
        case 0x16: return "6"
        case 0x17: return "5"
        case 0x18: return "="
        case 0x19: return "9"
        case 0x1A: return "7"
        case 0x1B: return "-"
        case 0x1C: return "8"
        case 0x1D: return "0"
        case 0x1E: return "]"
        case 0x1F: return "O"
        case 0x20: return "U"
        case 0x21: return "["
        case 0x22: return "I"
        case 0x23: return "P"
        case 0x24: return "Return"
        case 0x25: return "L"
        case 0x26: return "J"
        case 0x27: return "'"
        case 0x28: return "K"
        case 0x29: return ";"
        case 0x2A: return "\\"
        case 0x2B: return ","
        case 0x2C: return "/"
        case 0x2D: return "N"
        case 0x2E: return "M"
        case 0x2F: return "."
        case 0x30: return "Tab"
        case 0x31: return "Space"
        case 0x32: return "`"
        case 0x33: return "Delete"
        case 0x35: return "Esc"
        case 0x7B: return "←"
        case 0x7C: return "→"
        case 0x7D: return "↓"
        case 0x7E: return "↑"
        default: return String(format: "0x%02X", keyCode)
        }
    }
}

struct KeyCaptureView: NSViewRepresentable {
    @Binding var isCapturing: Bool
    var onCapture: (Hotkey) -> Void

    func makeNSView(context: Context) -> CaptureNSView {
        let v = CaptureNSView()
        v.onCapture = { hk in
            onCapture(hk)
            isCapturing = false
        }
        v.onStop = { isCapturing = false }
        return v
    }

    func updateNSView(_ nsView: CaptureNSView, context: Context) {
        nsView.isCapturing = isCapturing
    }
}

final class CaptureNSView: NSView {
    var onCapture: ((Hotkey) -> Void)?
    var onStop: (() -> Void)?
    var isCapturing: Bool = false {
        didSet {
            needsPanelToBecomeKey = isCapturing
            if isCapturing {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.window?.makeFirstResponder(self)
                }
            }
        }
    }

    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override var canBecomeKeyView: Bool { true }
    override var needsPanelToBecomeKey: Bool {
        get { isCapturing }
        set { }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if isCapturing { window?.makeFirstResponder(self) }
    }

    override func keyDown(with event: NSEvent) {
        guard isCapturing else { return }
        let hk = Hotkey(keyCode: UInt32(event.keyCode), modifiers: UInt32(event.modifierFlags.carbonFlags))
        onCapture?(hk)
    }

    override func flagsChanged(with event: NSEvent) {
        // consume modifier changes during capture
    }

    override func resignFirstResponder() -> Bool {
        if isCapturing { onStop?() }
        return super.resignFirstResponder()
    }
}

private extension NSEvent.ModifierFlags {
    var carbonFlags: Int {
        var result = 0
        if contains(.command) { result |= cmdKey }
        if contains(.option)  { result |= optionKey }
        if contains(.control) { result |= controlKey }
        if contains(.shift)   { result |= shiftKey }
        return result
    }
}
