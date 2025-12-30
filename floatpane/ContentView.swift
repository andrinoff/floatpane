import SwiftUI

struct ContentView: View {
    @StateObject var manager = WallpaperManager()
    @State private var hoveredIndex: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal Carousel
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        ForEach(Array(manager.wallpapers.enumerated()), id: \.element) { index, url in
                            WallpaperItem(
                                url: url,
                                isSelected: index == manager.selectedIndex
                            )
                            .id(index)
                            .onTapGesture {
                                manager.selectedIndex = index
                                withAnimation { proxy.scrollTo(index, anchor: .center) }
                            }
                            .simultaneousGesture(TapGesture(count: 2).onEnded {
                                manager.setWallpaper(url: url)
                                NSApplication.shared.hide(nil)
                            })
                        }
                    }
                    .padding(.horizontal, 50) // Padding to center the first/last items
                    .padding(.vertical, 20)
                }
                .frame(height: 300) // Fixed height for the strip
                // Auto-scroll when index changes (e.g. via keyboard)
                .onChange(of: manager.selectedIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            
            // Footer Info
            HStack {
                Text(manager.wallpapers.indices.contains(manager.selectedIndex)
                     ? manager.wallpapers[manager.selectedIndex].lastPathComponent
                     : "Select a wallpaper")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Open Settings Window
                    if let url = URL(string: "floatpane://settings") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.black.opacity(0.5))
        }
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        .cornerRadius(16)
        // Keyboard Handling
        .focusable()
        .onAppear { DispatchQueue.main.async { NSApp.windows.first?.makeFirstResponder(nil) } }
        .onKeyPress(.leftArrow) {
            manager.selectedIndex = max(0, manager.selectedIndex - 1)
            return .handled
        }
        .onKeyPress(.rightArrow) {
            manager.selectedIndex = min(manager.wallpapers.count - 1, manager.selectedIndex + 1)
            return .handled
        }
        .onKeyPress(.return) {
            if manager.wallpapers.indices.contains(manager.selectedIndex) {
                manager.setWallpaper(url: manager.wallpapers[manager.selectedIndex])
                NSApplication.shared.hide(nil)
            }
            return .handled
        }
    }
}

struct WallpaperItem: View {
    let url: URL
    let isSelected: Bool
    
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().aspectRatio(contentMode: .fill)
            } else {
                Color.white.opacity(0.1)
            }
        }
        .frame(width: isSelected ? 240 : 180, height: isSelected ? 160 : 120) // Active item is larger
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: isSelected ? 4 : 0)
        )
        .shadow(radius: isSelected ? 10 : 2)
        .animation(.spring(), value: isSelected) // Smooth resize animation
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
