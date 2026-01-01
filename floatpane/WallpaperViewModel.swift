import SwiftUI
import AppKit
import Combine

final class WallpaperViewModel: ObservableObject {
    static let shared = WallpaperViewModel()

    @Published var wallpapers: [URL] = []
    @Published var selectedIndex: Int = 0
    @Published var isWindowVisible: Bool = true

    private let fm = FileManager.default
    private let wallpaperDir: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("wallpapers")

    init() { reloadWallpapers() }

    func reloadWallpapers() {
        let exts = ["jpg","jpeg","png","heic","tiff","bmp","gif"]
        let urls = (try? fm.contentsOfDirectory(at: wallpaperDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)) ?? []
        wallpapers = urls.filter { exts.contains($0.pathExtension.lowercased()) }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
        if wallpapers.isEmpty { selectedIndex = 0 }
        else { selectedIndex = min(selectedIndex, wallpapers.count - 1) }
    }

    func setWallpaper(at index: Int) {
        guard wallpapers.indices.contains(index) else { return }
        selectedIndex = index
        setCurrentWallpaper()
    }

    func moveSelection(by delta: Int) {
        guard !wallpapers.isEmpty else { return }
        let count = wallpapers.count
        selectedIndex = (selectedIndex + delta % count + count) % count
    }

    func applyCurrentWallpaper() {
        setCurrentWallpaper()
        hideWindow()
    }

    func toggleWindowVisibility() {
        isWindowVisible.toggle()
        if isWindowVisible { showWindow() } else { hideWindow() }
    }

    func showWindow() {
        isWindowVisible = true
        WindowConfigurator.refreshWindowConfiguration()
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.forEach {
            $0.orderFrontRegardless()
            $0.makeKeyAndOrderFront(nil)
        }
        NotificationCenter.default.post(name: .keyCatcherFocusRequest, object: nil)
    }

    func hideWindow() {
        isWindowVisible = false
        NSApp.windows.forEach { $0.orderOut(nil) }
    }

    private func setCurrentWallpaper() {
        guard wallpapers.indices.contains(selectedIndex) else { return }
        let url = wallpapers[selectedIndex]
        for screen in NSScreen.screens {
            do { try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:]) }
            catch { NSLog("Failed to set wallpaper: \(error.localizedDescription)") }
        }
    }
}
