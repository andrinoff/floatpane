# floatpane

<p align="center">
  <img src="https://raw.githubusercontent.com/floatpane/floatpane/master/assets/icon.svg" alt="floatpane Logo" width="128">
</p>

<h3 align="center">A lightweight, floating wallpaper selector for macOS.</h3>

<p align="center">
  <img src="https://img.shields.io/github/v/release/floatpane/floatpane?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/github/license/floatpane/floatpane?style=for-the-badge" alt="License">
</p>

---

**floatpane** is a minimal utility for macOS that lets you quickly browse and set your desktop wallpaper. It's designed to be invoked with a global keyboard shortcut and floats above all other windows, making it compatible with tiling window managers like **Aerospace** and **yabai**.

## 🎬 Demo

![floatpane Demo](https://raw.githubusercontent.com/floatpane/floatpane/master/assets/floatpane-preview.gif)

## ✨ Features

- **⚡ Summon:** Bring up the wallpaper grid from anywhere with `Cmd+Shift+P`.
- **🖼️ Floating Window:** Floats on top of all other applications for easy access.
- **🧩 Tiling WM Friendly:** Integrates smoothly with Aerospace, yabai, and Amethyst.
- **⌨️ Keyboard Navigation:** Use arrow keys to browse, `Enter` to apply, and `Esc` to dismiss.
- **🚀 Lazy Loading:** Thumbnails load as you scroll for a fast, responsive experience.
- **✅ Current Wallpaper Indicator:** Your active wallpaper is always highlighted.
- **🎨 Themes:** Customize the look and feel with multiple built-in themes.

## 📋 Requirements

- macOS
- A `~/wallpapers` directory containing your images.

## 🚀 Installation

### Homebrew (Recommended)

```bash
brew tap floatpane/floatpane
brew install floatpane
```

Builds (DMG's) are also available [here](https://github.com/floatpane/flotpane/releases).

> [!WARNING]
> The Builds are not signed with an Apple Developer ID. You need to run `xattr -cr /Applications/floatpane.app` after downloading and before opening it for the first time.

## 🌅 Wallpapers

You can find all the wallpapers I use by going to [andrinoff/wallpapers](https://github.com/andrinoff/wallpapers)

OR

```sh
curl -sS https://andrinoff.com/wallpapers/download.sh | sh
```

## 🎨 Available Themes

Floatpane includes a variety of themes to match your style. You can change the theme in the settings (`Cmd+,`, or by clicking the gear icon).

- Aura
- Ayu Dark
- Cobalt2
- Dracula
- Gruvbox Dark
- Material Theme
- Monokai
- Night Owl
- Nord
- One Dark Pro
- Panda Syntax
- Solarized Dark
- Synthwave '84
- Tokyo Night Blue

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
