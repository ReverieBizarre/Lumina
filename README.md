# Lumina ☀️

<p align="center">
  <img src="assets/icon.png" width="128" height="128" alt="Lumina Icon">
</p>

<p align="center">
  <b>1000 尼特 XDR 屏幕高亮工具 · 0% 额外能耗 · 纯原生极简</b><br>
  <b>1000-Nit XDR Brightness Booster · 0.0% Idle CPU · Pure Native macOS</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2013%2B-blue?style=flat-square" alt="macOS">
  <img src="https://img.shields.io/badge/Hardware-Liquid%20Retina%20XDR-orange?style=flat-square" alt="Liquid Retina XDR">
  <img src="https://img.shields.io/badge/CPU%20Overhead-0.0%25-brightgreen?style=flat-square" alt="CPU Usage">
  <img src="https://img.shields.io/badge/Language-Swift%206-red?style=flat-square" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
</p>

---

<p align="center">
  <img src="assets/preview.png" width="420" alt="Lumina UI Preview">
</p>

---

## 简体中文

### 核心亮点（关键词前置）
- **1000 尼特全屏持续高亮**：解锁 Liquid Retina XDR 屏幕的硬件冗余，突破 macOS 默认 500 尼特的日常限制，在户外阳光与强光下依然清晰明亮。
- **0.0% 额外能耗（零 CPU / GPU 占用）**：采用单次静态 EDR 硬件信号触发，彻底摒弃连续重绘循环与后台定时器，**除 Mini-LED 背光自身的发光耗电外，软件本身零多余开销**。
- **纯原生 Swift 极简架构**：基于 Swift 6 + AppKit + SwiftUI 构建，无任何 Electron 臃肿依赖，常驻内存极低，安装包仅 1.5 MB，可执行程序不足 300 KB。
- **即点即用的直觉交互**：集成实时估算尼特值、系统原生平滑滑块、100% / 150% / 200% 常用预设档位，并支持开机自动静默常驻。

### 支持设备
- **MacBook Pro 14 寸 / 16 寸**（配备 Liquid Retina XDR 屏幕的 M1 / M2 / M3 / M4 Pro & Max 系列）
- **Apple Pro Display XDR** 专业显示器

### 快速安装
1. 点击 [Releases](../../releases) 页面，下载最新版 **`Lumina.dmg`**。
2. 双击打开镜像，将 **`Lumina.app`** 拖拽到 **`Applications（应用程序）`** 文件夹。
3. 打开 Lumina，屏幕右上角菜单栏将常驻小太阳图标，点击即可调节。

### 源码编译
```bash
git clone https://github.com/ReverieBizarre/Lumina.git
cd Lumina
./scripts/build_dmg.sh
```

---

## English

### Key Features (Keyword Front-Loaded)
- **1000 Nits Full-Screen Brightness**: Unlocks the physical headroom of Liquid Retina XDR displays, breaking through the default 500-nit macOS limit for comfortable outdoor and bright-ambient readability.
- **0.0% Idle CPU & GPU Overhead**: Employs a one-time static EDR hardware trigger without continuous animation loops or background pollers. **Zero extra power consumption** beyond the display backlight itself.
- **Pure Native Swift Architecture**: Crafted with Swift 6, AppKit, and SwiftUI without heavy web wrappers. Ultra-lightweight footprint (<300 KB binary size, ~1.5 MB DMG).
- **Intuitive Controls & Presets**: Features live nits estimation, native smooth slider, 100% / 150% / 200% one-click presets, and optional launch-at-login.

### Supported Devices
- **MacBook Pro 14" / 16"** (M1 / M2 / M3 / M4 Pro & Max with Liquid Retina XDR displays)
- **Apple Pro Display XDR**

### Installation
1. Download the latest **`Lumina.dmg`** from the [Releases](../../releases) section.
2. Open the disk image and drag **`Lumina.app`** into your **`Applications`** directory.
3. Launch Lumina from Applications or Spotlight; access it via the sun icon in your menu bar.

### Build from Source
```bash
git clone https://github.com/ReverieBizarre/Lumina.git
cd Lumina
./scripts/build_dmg.sh
```

---

## 贡献与致谢 / Contributors & Acknowledgments

- **Author & Project Lead**: [@ReverieBizarre](https://github.com/ReverieBizarre)
- **AI Pair Programming**: Developed in pair programming with **Google DeepMind Antigravity** & **Gemini** (assisted in macOS EDR display pipeline architecture, zero-overhead Swift implementation, and automated packaging).

---

## License
Distributed under the [MIT License](LICENSE).
