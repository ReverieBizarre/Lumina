import SwiftUI

struct LuminaView: View {
    @ObservedObject var manager = BrightnessManager.shared

    private var estimatedNits: Int {
        let ratio = (manager.brightnessPercentage - 100.0) / 100.0
        return Int(500.0 + ratio * 500.0)
    }

    private var statusDescription: String {
        if manager.brightnessPercentage <= 100 {
            return "标准模式 (SDR · 500 nits)"
        } else if manager.brightnessPercentage < 160 {
            return "户外增强模式 (\(estimatedNits) nits)"
        } else {
            return "极限阳光模式 (XDR · 1000 nits)"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: "sun.max.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.orange.gradient)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Lumina")
                        .font(.system(size: 15, weight: .bold))
                    Text("XDR 极简高亮增强")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Text("\(Int(manager.brightnessPercentage))%")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(manager.brightnessPercentage > 100 ? .orange : .secondary)
            }

            // Big Info Card
            VStack(spacing: 4) {
                Text("\(estimatedNits) nits")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        manager.brightnessPercentage > 100
                            ? AnyShapeStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color.primary)
                    )

                Text(statusDescription)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Slider
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "sun.min")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    Slider(value: $manager.brightnessPercentage, in: 100...200, step: 1)
                        .tint(.orange)

                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                }

                HStack {
                    Text("100% (500 nits)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("200% (1000 nits)")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }

            // Quick Preset Buttons
            HStack(spacing: 8) {
                presetButton(title: "100% 标准", value: 100)
                presetButton(title: "150% 强光", value: 150)
                presetButton(title: "200% 极亮", value: 200)
            }

            Divider()

            // Zero-overhead badge
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text("静态硬件触发 · 0.0% CPU 占用")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            // Settings & Quit
            HStack {
                Toggle("开机启动", isOn: $manager.launchAtLogin)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 12))

                Spacer()

                Button(action: {
                    BrightnessManager.shared.cleanup()
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("退出")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(16)
        .frame(width: 290)
    }

    @ViewBuilder
    private func presetButton(title: String, value: Double) -> some View {
        Button(action: {
            manager.setPercentagePreset(value)
        }) {
            Text(title)
                .font(.system(size: 11, weight: manager.brightnessPercentage == value ? .bold : .regular))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(
                    manager.brightnessPercentage == value
                        ? Color.orange.opacity(0.15)
                        : Color(NSColor.controlColor).opacity(0.4)
                )
                .foregroundStyle(manager.brightnessPercentage == value ? Color.orange : Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(manager.brightnessPercentage == value ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
