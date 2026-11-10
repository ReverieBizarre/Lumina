import AppKit
import CoreGraphics

final class GammaTable {
    static let tableSize: UInt32 = 256
    private static let boostedThreshold: CGGammaValue = 1.05

    var redTable: [CGGammaValue] = .init(repeating: 0, count: Int(tableSize))
    var greenTable: [CGGammaValue] = .init(repeating: 0, count: Int(tableSize))
    var blueTable: [CGGammaValue] = .init(repeating: 0, count: Int(tableSize))

    private init() {}

    static func capture(displayId: CGDirectDisplayID) -> GammaTable? {
        let table = GammaTable()
        var sampleCount: UInt32 = 0
        let result = CGGetDisplayTransferByTable(
            displayId, tableSize,
            &table.redTable, &table.greenTable, &table.blueTable,
            &sampleCount
        )
        return result == .success ? table : nil
    }

    static func cleanBaseline(displayId: CGDirectDisplayID) -> GammaTable? {
        guard let current = capture(displayId: displayId) else { return nil }
        if current.appearsBoosted {
            CGDisplayRestoreColorSyncSettings()
            if let restored = capture(displayId: displayId), !restored.appearsBoosted {
                return restored
            }
            return current.normalized()
        }
        return current
    }

    func apply(displayId: CGDirectDisplayID, factor: Float = 1.0) {
        var r = redTable
        var g = greenTable
        var b = blueTable
        if factor != 1.0 {
            for i in 0..<Int(Self.tableSize) {
                r[i] *= factor
                g[i] *= factor
                b[i] *= factor
            }
        }
        CGSetDisplayTransferByTable(displayId, Self.tableSize, &r, &g, &b)
    }

    private var maxComponent: CGGammaValue {
        max(redTable.max() ?? 0, greenTable.max() ?? 0, blueTable.max() ?? 0)
    }

    private var appearsBoosted: Bool {
        maxComponent > Self.boostedThreshold
    }

    private func normalized() -> GammaTable? {
        let m = maxComponent
        guard m > 0 else { return nil }
        let table = GammaTable()
        table.redTable = redTable.map { $0 / m }
        table.greenTable = greenTable.map { $0 / m }
        table.blueTable = blueTable.map { $0 / m }
        return table
    }
}
