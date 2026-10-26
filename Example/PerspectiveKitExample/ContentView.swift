import SwiftUI
import PerspectiveKit

struct ContentView: View {

    @State private var config = PerspectiveConfig.widgetAnimatable
    @State private var implementation = Implementation.swiftUI

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                preview
                    .frame(height: 280)
                    .frame(maxWidth: .infinity)
                Form {
                    implementationSection
                    animationSection
                    transformSection
                    shadowSection
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("PerspectiveKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    Button("Widget Animatable") { config = .widgetAnimatable }
                    Button("Widget Static") { config = .widgetStatic }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var preview: some View {
        switch implementation {
        case .swiftUI:
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(width: 180, height: 180)
                .perspective(config)
        case .uiKit:
            CardView(config: config)
                .frame(width: 180, height: 180)
        }
    }

    // MARK: - Sections

    private var implementationSection: some View {
        Section {
            Picker("Implementation", selection: $implementation) {
                ForEach(Implementation.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)
        }
    }

    private var animationSection: some View {
        Section("Animation") {
            Toggle("Animatable", isOn: Binding(
                get: { config.animation != nil },
                set: { config.animation = $0 ? PerspectiveAnimation(duration: 16) : nil }
            ))
            Picker("Corner", selection: $config.corner) {
                Text("Random").tag(PerspectiveCorner?.none)
                ForEach(PerspectiveCorner.allCases, id: \.self) { Text($0.rawValue).tag(Optional($0)) }
            }
            if let animation = config.animation {
                Picker("Direction", selection: Binding(
                    get: { animation.direction },
                    set: { config.animation?.direction = $0 }
                )) {
                    Text("Clockwise").tag(PerspectiveDirection.clockwise)
                    Text("Counterclockwise").tag(PerspectiveDirection.counterclockwise)
                }
                SliderRow(title: "Duration", value: Binding(
                    get: { animation.duration },
                    set: { config.animation?.duration = $0 }
                ), range: 1...30)
            }
        }
    }

    private var transformSection: some View {
        Section("Transform") {
            SliderRow(title: "Distortion", value: $config.distortion, range: 100...1500)
            SliderRow(title: "Angle", value: $config.angle, range: 0...45)
        }
    }

    @ViewBuilder
    private var shadowSection: some View {
        Section {
            Toggle("Shadow", isOn: Binding(
                get: { config.shadow != nil },
                set: { config.shadow = $0 ? .widget : nil }
            ))
            if config.shadow != nil {
                SliderRow(title: "Opacity", value: shadowBinding(\.opacity), range: 0...1)
                SliderRow(title: "Blur Radius", value: shadowBinding(\.blurRadius), range: 0...40)
                SliderRow(title: "Horizontal Offset", value: shadowBinding(\.maximumHorizontalOffset), range: 0...50)
                SliderRow(title: "Start Vertical Offset", value: shadowBinding(\.startVerticalOffset), range: -10...50)
                SliderRow(title: "Corner Vertical Offset", value: shadowBinding(\.cornerVerticalOffset), range: -10...50)
                SliderRow(title: "Maximum Vertical Offset", value: shadowBinding(\.maximumVerticalOffset), range: -10...50)
            }
        } footer: {
            Text("Vertical offsets go in ascending order: start, corner, maximum")
        }
    }

    private func shadowBinding(_ keyPath: WritableKeyPath<PerspectiveShadow, CGFloat>) -> Binding<CGFloat> {
        Binding(
            get: { config.shadow?[keyPath: keyPath] ?? 0 },
            set: { config.shadow?[keyPath: keyPath] = $0 }
        )
    }

    enum Implementation: String, CaseIterable {

        case swiftUI = "SwiftUI"
        case uiKit = "UIKit"
    }
}

private struct SliderRow<Value: BinaryFloatingPoint>: View where Value.Stride: BinaryFloatingPoint {

    let title: String
    @Binding var value: Value
    let range: ClosedRange<Value>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.2f", Double(value)))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range)
        }
    }
}

/* Та же карточка через UIKit-расширение, чтобы сравнить с SwiftUI-модификатором. */
private struct CardView: UIViewRepresentable {

    let config: PerspectiveConfig

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 22
        view.layer.cornerCurve = .continuous
        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        view.applyPerspective(config)
    }
}
