import SwiftUI

public extension View {

    func perspective(_ config: PerspectiveConfig) -> some View {
        modifier(PerspectiveModifier(config: config))
    }
}

struct PerspectiveModifier: ViewModifier {

    let config: PerspectiveConfig

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /* Случайное положение выбирается один раз, иначе оно менялось бы при каждом пересчёте body. */
    @State private var randomCorner = PerspectiveCorner.allCases.randomElement()!
    @State private var startDate = Date()

    func body(content: Content) -> some View {
        let config = config.respectingReduceMotion(reduceMotion)
        /* Цикл длится секунды, 60 кадров хватает с запасом. На ProMotion это вдвое меньше пересчётов. */
        TimelineView(.animation(minimumInterval: 1 / 60, paused: config.animation == nil)) { context in
            let phase = config.phase(from: config.corner ?? randomCorner, progress: progress(at: context.date, config: config))
            content
                .modifier(PerspectiveShadowEffect(shadow: config.shadow, offset: config.shadowOffset(phase: phase)))
                .modifier(PerspectiveEffect(transform: config.transform(phase: phase)))
        }
        .onChange(of: config.animation?.duration) { [oldDuration = config.animation?.duration] newDuration in
            keepPhase(from: oldDuration, to: newDuration)
        }
    }

    private func progress(at date: Date, config: PerspectiveConfig) -> Double {
        guard let duration = config.animation?.duration, duration > 0 else { return 0 }
        let elapsed = date.timeIntervalSince(startDate)
        return elapsed.truncatingRemainder(dividingBy: duration) / duration
    }

    /* При смене длительности сдвигаем старт так, чтобы карточка продолжила с того же места, а не прыгнула. */
    private func keepPhase(from oldDuration: TimeInterval?, to newDuration: TimeInterval?) {
        guard let oldDuration, let newDuration, oldDuration > 0, newDuration > 0 else { return }
        let now = Date()
        startDate = now.addingTimeInterval(-now.timeIntervalSince(startDate) * newDuration / oldDuration)
    }
}

/* compositingGroup и тень рендерятся отдельным проходом, поэтому без тени их не добавляем. */
private struct PerspectiveShadowEffect: ViewModifier {

    let shadow: PerspectiveShadow?
    let offset: CGSize

    func body(content: Content) -> some View {
        if let shadow {
            content
                .compositingGroup()
                .shadow(
                    color: Color(uiColor: shadow.color).opacity(Double(shadow.opacity)),
                    radius: shadow.blurRadius,
                    x: offset.width,
                    y: offset.height
                )
        } else {
            content
        }
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
