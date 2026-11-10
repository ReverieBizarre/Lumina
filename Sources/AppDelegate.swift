import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize menu bar status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            if let image = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "Lumina")?.withSymbolConfiguration(config) {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "☀️"
            }
            button.target = self
            button.action = #selector(togglePopover(_:))
        }

        // Initialize SwiftUI Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 290, height: 260)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: LuminaView())

        // Initialize Brightness Manager
        _ = BrightnessManager.shared
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        BrightnessManager.shared.cleanup()
    }
}
