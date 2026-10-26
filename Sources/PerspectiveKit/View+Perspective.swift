import SwiftUI

public extension View {

    func perspective(_ config: PerspectiveConfig) -> some View {
        modifier(PerspectiveModifier(config: config))
    }
}

struct PerspectiveModifier: ViewModifier {

    let config: PerspectiveConfig

    /* Случайное положение выбирается один раз, иначе оно менялось бы при каждом пересчёте body. */
    @State private var randomCorner = PerspectiveCorner.random
    @State private var startDate = Date()

    func body(content: Content) -> some View {
        TimelineView(.animation(paused: config.animation == nil)) { context in
            let frame = config.frame(from: config.corner ?? randomCorner, progress: progress(at: context.date))
            let shadow = config.shadow
            content
                .compositingGroup()
                .shadow(
                    color: Color(uiColor: shadow?.color ?? .clear).opacity(Double(shadow?.opacity ?? 0)),
                    radius: shadow?.blurRadius ?? 0,
                    x: frame.shadowOffset.width,
                    y: frame.shadowOffset.height
                )
                .modifier(PerspectiveEffect(transform: frame.transform))
        }
    }

    private func progress(at date: Date) -> Double {
        guard let duration = config.animation?.duration, duration > 0 else { return 0 }
        let elapsed = date.timeIntervalSince(startDate)
        return elapsed.truncatingRemainder(dividingBy: duration) / duration
    }
}

/* Применяет CATransform3D относительно центра, как это делает слой в UIKit. */
private struct PerspectiveEffect: GeometryEffect {

    var transform: CATransform3D

    func effectValue(size: CGSize) -> ProjectionTransform {
        let toCenter = CATransform3DMakeTranslation(-size.width / 2, -size.height / 2, 0)
        let back = CATransform3DMakeTranslation(size.width / 2, size.height / 2, 0)
        return ProjectionTransform(CATransform3DConcat(CATransform3DConcat(toCenter, transform), back))
    }
}
