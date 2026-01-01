import Foundation
import AppKit
import Combine
import Carbon

struct Hotkey: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32

    static let toggleDefault = Hotkey(keyCode: UInt32(kVK_ANSI_W), modifiers: cmdShift)

    static var cmdShift: UInt32 { UInt32(cmdKey | shiftKey) }
}

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @Published var toggleHotkey: Hotkey {
        didSet { saveToggleHotkey() }
    }
    @Published var isSettingsPresented: Bool = false
    @Published var themes: [Theme] = []
    @Published var selectedThemeID: String = Theme.fallback.id {
        didSet { saveTheme() }
    }

    var currentTheme: Theme {
        themes.first(where: { $0.id == selectedThemeID }) ?? themes.first ?? Theme.fallback
    }

    private let defaults = UserDefaults.standard
    private let toggleKey = "hotkey.toggle"
    private let themeKey  = "theme.selected"

    private init() {
        toggleHotkey = defaults.decode(Hotkey.self, forKey: toggleKey) ?? .toggleDefault
        themes = SettingsStore.loadThemes()

        let storedTheme = defaults.string(forKey: themeKey)
        if let storedTheme, themes.contains(where: { $0.id == storedTheme }) {
            selectedThemeID = storedTheme
        } else {
            selectedThemeID = themes.first?.id ?? Theme.fallback.id
        }
    }

    private func saveToggleHotkey() {
        defaults.encode(toggleHotkey, forKey: toggleKey)
        GlobalShortcutManager.shared?.registerAll()
    }

    private func saveTheme() {
        defaults.set(selectedThemeID, forKey: themeKey)
    }

    private static func loadThemes() -> [Theme] {
        let decoder = JSONDecoder()
        let bundle = Bundle.main
        
        // Collect URLs from both the "themes" subdirectory and the root resources
        var urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: "themes") ?? []
        if let rootUrls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            urls.append(contentsOf: rootUrls)
        }
        
        // Fallback: Manually check the resource path if bundle.urls fails
        if urls.isEmpty, let resourcePath = bundle.resourcePath {
            let fm = FileManager.default
            if let contents = try? fm.contentsOfDirectory(atPath: resourcePath) {
                let jsonFiles = contents.filter { $0.hasSuffix(".json") }
                let manualUrls = jsonFiles.map { URL(fileURLWithPath: resourcePath).appendingPathComponent($0) }
                urls.append(contentsOf: manualUrls)
            }
        }
        
        // Deduplicate URLs
        let uniqueUrls = Array(Set(urls))

        let loaded = uniqueUrls.compactMap { url -> Theme? in
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try? decoder.decode(Theme.self, from: data)
        }

        let themes = loaded.isEmpty ? [Theme.fallback] : loaded
        return themes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

private extension UserDefaults {
    func encode<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            set(data, forKey: key)
        }
    }

    func decode<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
