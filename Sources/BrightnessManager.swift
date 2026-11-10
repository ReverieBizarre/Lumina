import AppKit
import Foundation
import ServiceManagement

@MainActor
final class BrightnessManager: ObservableObject {
    static let shared = BrightnessManager()

    @Published var brightnessPercentage: Double {
        didSet {
            UserDefaults.standard.set(brightnessPercentage, forKey: "LuminaBrightness")
            applyBrightness()
        }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            updateLaunchAtLogin(enabled: launchAtLogin)
        }
    }

    private var baselineGammaTables: [CGDirectDisplayID: GammaTable] = [:]
    private var overlayWindows: [CGDirectDisplayID: OverlayWindow] = [:]
    private let bonusGamma: Float

    private init() {
        let saved = UserDefaults.standard.double(forKey: "LuminaBrightness")
        self.brightnessPercentage = saved >= 100.0 && saved <= 200.0 ? saved : 100.0

        if #available(macOS 13.0, *) {
            self.launchAtLogin = SMAppService.mainApp.status == .enabled
        } else {
            self.launchAtLogin = false
        }

        // Determine bonus gamma based on device generation
        var size: Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        let modelIdentifier = String(cString: model)

        if modelIdentifier.hasPrefix("Mac15") || modelIdentifier.hasPrefix("Mac16") || modelIdentifier.hasPrefix("Mac17") {
            self.bonusGamma = 0.50
        } else {
            self.bonusGamma = 0.59
        }

        setupNotifications()
        
        // Initial setup if saved percentage > 100
        if brightnessPercentage > 100.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.applyBrightness()
            }
        }
    }

    func setPercentagePreset(_ value: Double) {
        self.brightnessPercentage = value
    }

    func applyBrightness() {
        let displays = getBuiltInXDRDisplays()
        guard !displays.isEmpty else { return }

        if brightnessPercentage <= 100.0 {
            // Restore normal mode
            for (_, window) in overlayWindows {
                window.close()
            }
            overlayWindows.removeAll()

            for (displayId, table) in baselineGammaTables {
                table.apply(displayId: displayId, factor: 1.0)
            }
            baselineGammaTables.removeAll()
            CGDisplayRestoreColorSyncSettings()
            return
        }

        // Boost mode (> 100%)
        let boostRatio = Float((brightnessPercentage - 100.0) / 100.0)
        let factor = 1.0 + (boostRatio * bonusGamma)

        for screen in displays {
            guard let displayId = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
                continue
            }

            // Ensure baseline gamma captured
            if baselineGammaTables[displayId] == nil {
                if let table = GammaTable.cleanBaseline(displayId: displayId) {
                    baselineGammaTables[displayId] = table
                }
            }

            // Ensure 1x1 EDR overlay is installed
            if overlayWindows[displayId] == nil {
                let window = OverlayWindow()
                window.install(on: screen)
                overlayWindows[displayId] = window
            }

            // Apply scaled gamma table
            baselineGammaTables[displayId]?.apply(displayId: displayId, factor: factor)
        }
    }

    func cleanup() {
        for (_, window) in overlayWindows {
            window.close()
        }
        overlayWindows.removeAll()

        for (displayId, table) in baselineGammaTables {
            table.apply(displayId: displayId, factor: 1.0)
        }
        baselineGammaTables.removeAll()
        CGDisplayRestoreColorSyncSettings()
    }

    private func getBuiltInXDRDisplays() -> [NSScreen] {
        NSScreen.screens.filter { screen in
            guard let displayId = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
                return false
            }
            return CGDisplayIsBuiltin(displayId) != 0 && screen.maximumPotentialExtendedDynamicRangeColorComponentValue > 1.0
        }
    }

    private func setupNotifications() {
        let wsNC = NSWorkspace.shared.notificationCenter
        wsNC.addObserver(forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.cleanup()
            }
        }
        wsNC.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: .main) { [weak self] _ in
            CGDisplayRestoreColorSyncSettings()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task { @MainActor [weak self] in
                    self?.applyBrightness()
                }
            }
        }
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.applyBrightness()
            }
        }
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.cleanup()
            }
        }
    }

    private func updateLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                print("LaunchAtLogin change failed: \(error)")
            }
        }
    }
}
