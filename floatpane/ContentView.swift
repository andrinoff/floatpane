import SwiftUI
import Carbon
import AppKit

struct ContentView: View {
    @EnvironmentObject var model: WallpaperViewModel
    @EnvironmentObject var store: SettingsStore
    @Namespace private var ns

    var body: some View {
        let theme = store.currentTheme
        return ZStack {
            VStack(alignment: .leading, spacing: 12) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 14) {
                            ForEach(Array(model.wallpapers.enumerated()), id: \.offset) { index, url in
                                WallpaperItem(
                                    url: url,
                                    isSelected: index == model.selectedIndex,
                                    ns: ns,
                                    accent: theme.primaryColor
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        model.setWallpaper(at: index)
                                    }
                                    model.applyCurrentWallpaper()
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                    .frame(height: 130)
                    .onChange(of: model.selectedIndex) { index in
                        guard model.wallpapers.indices.contains(index) else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(index, anchor: .center)
                        }
                    }
                    .onAppear {
                        guard model.wallpapers.indices.contains(model.selectedIndex) else { return }
                        DispatchQueue.main.async {
                            proxy.scrollTo(model.selectedIndex, anchor: .center)
                        }
                    }
                }

                HStack(spacing: 12) {
                    Image("Logo")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                        .foregroundStyle(.white)

                    Spacer()
                    Button {
                        let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("wallpapers")
                        NSWorkspace.shared.open(url)
                    } label: {
                        Image(systemName: "folder")
                            .imageScale(.medium)
                            .accessibilityLabel("Open wallpapers folder")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.primaryColor)
                    .focusable(false)
                    Button {
                        store.isSettingsPresented = true
                    } label: {
                        Image(systemName: "gearshape")
                            .imageScale(.medium)
                            .accessibilityLabel("Open settings")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.onSurfaceColor)
                    .focusable(false)
                }
                .padding(.horizontal, 18)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 28)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(theme.surfaceColor.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(theme.primaryColor.opacity(0.25), lineWidth: 1)
                    )
            )
            .frame(maxWidth: 860)
            .padding(.horizontal, 32)
        }
        .background(WindowConfigurator())
        .background(KeyCatcher { key in handleKey(key) })
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            // Initial configuration will be handled by WindowConfigurator
        }
        .sheet(isPresented: $store.isSettingsPresented) {
            SettingsView().environmentObject(store)
        }
    }

    private func handleKey(_ key: KeyEvent) {
        switch key {
        case .left:
            withAnimation(.easeInOut(duration: 0.18)) { model.moveSelection(by: -1) }
        case .right:
            withAnimation(.easeInOut(duration: 0.18)) { model.moveSelection(by: 1) }
        case .enter:
            model.applyCurrentWallpaper()
        case .escape:
            model.hideWindow()
        }
    }
}

struct WallpaperItem: View {
    let url: URL
    let isSelected: Bool
    let ns: Namespace.ID
    let accent: Color

    var body: some View {
        ZStack {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Color.gray.opacity(0.25)
                }
            }
            .frame(width: 170, height: 110)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accent : Color.clear, lineWidth: 4)
                    .matchedGeometryEffect(id: isSelected ? "sel" : "\(url)", in: ns)
            )
            .cornerRadius(12)
        }
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
