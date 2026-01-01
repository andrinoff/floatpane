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
        .frame(width: 520)
    }
}

struct ThemeGrid: View {
    let themes: [Theme]
    @Binding var selectedID: String

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        Group {
            if themes.isEmpty {
                Text("No themes found")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(themes) { theme in
                            ThemeTile(theme: theme, isSelected: theme.id == selectedID)
                                .onTapGesture { selectedID = theme.id }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxHeight: 260)
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
            HStack(spacing: 10) {
                PaletteChip(label: "Primary", color: theme.primaryColor)
                PaletteChip(label: "Secondary", color: theme.secondaryColor)
                PaletteChip(label: "Surface", color: theme.surfaceColor)
            }
        }
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

private struct PaletteChip: View {
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
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
        case UInt32(kVK_ANSI_W): return "W"
        case UInt32(kVK_ANSI_N): return "N"
        case UInt32(kVK_Space):  return "Space"
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
        didSet { needsPanelToBecomeKey = isCapturing }
    }

    override var acceptsFirstResponder: Bool { true }
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
