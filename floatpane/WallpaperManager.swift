import SwiftUI
import AppKit
import Combine 

class WallpaperManager: ObservableObject {
    @Published var wallpapers: [URL] = []
    @Published var selectedIndex: Int = 0
    
    private let fileManager = FileManager.default
    private var wallpaperDirectory: URL {
        fileManager.homeDirectoryForCurrentUser.appendingPathComponent("wallpapers")
    }
    
    init() {
        loadWallpapers()
    }
    
    func loadWallpapers() {
        do {
            if !fileManager.fileExists(atPath: wallpaperDirectory.path) {
                try fileManager.createDirectory(at: wallpaperDirectory, withIntermediateDirectories: true)
            }
            
            let fileURLs = try fileManager.contentsOfDirectory(at: wallpaperDirectory, includingPropertiesForKeys: nil)
            
            let allowedExtensions = ["jpg", "jpeg", "png", "heic", "webp"]
            self.wallpapers = fileURLs.filter { url in
                allowedExtensions.contains(url.pathExtension.lowercased())
            }.sorted { $0.lastPathComponent < $1.lastPathComponent }
            
        } catch {
            print("Error loading wallpapers: \(error)")
        }
    }
    
    func setWallpaper(url: URL) {
        if let screen = NSScreen.main {
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
            print("Wallpaper set to: \(url.lastPathComponent)")
        }
    }
    
    func openWallpaperFolder() {
        NSWorkspace.shared.open(wallpaperDirectory)
    }
}
