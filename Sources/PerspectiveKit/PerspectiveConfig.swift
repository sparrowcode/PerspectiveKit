import UIKit

public struct PerspectiveConfig: Equatable, Sendable {

    /* Сила перспективы, в матрице идёт как 1 / distortion. Чем больше значение, тем слабее искажение,
     нормальный диапазон 400...1200. 0 и меньше — поворот без перспективы. */
    public var distortion: CGFloat

    /* Угол наклона в градусах. */
    public var angle: CGFloat

    /* Положение наклона, в анимации цикл начинается с него. nil — случайное. */
    public var corner: PerspectiveCorner?

    /* nil — статичный наклон. */
    public var animation: PerspectiveAnimation?

    /* nil — без тени. */
    public var shadow: PerspectiveShadow?

    public init(
        distortion: CGFloat,
        angle: CGFloat,
        corner: PerspectiveCorner? = nil,
        animation: PerspectiveAnimation? = nil,
        shadow: PerspectiveShadow? = nil
    ) {
        self.distortion = distortion
        self.angle = angle
        self.corner = corner
        self.animation = animation
        self.shadow = shadow
    }

    /* При «Уменьшении движения» карточка не качается, а остаётся в статичном наклоне. */
    func respectingReduceMotion(_ reduceMotion: Bool) -> PerspectiveConfig {
        var config = self
        if reduceMotion {
            config.animation = nil
        }
        return config
    }

    // MARK: - Presets

    /* Как превью виджетов в iOS: карточка медленно обходит наклоном все углы за 16 секунд. */
    public static let widgetAnimatable = PerspectiveConfig(
        distortion: 600,
        angle: 10,
        animation: PerspectiveAnimation(duration: 16),
        shadow: .widget
    )

    public static let widgetStatic = PerspectiveConfig(
        distortion: 600,
        angle: 10,
        shadow: .widget
    )
}

public struct PerspectiveAnimation: Equatable, Sendable {

    /* Полный круг по всем углам. */
    public var duration: TimeInterval
    public var direction: PerspectiveDirection

    public init(duration: TimeInterval, direction: PerspectiveDirection = .clockwise) {
        self.duration = duration
        self.direction = direction
    }
}

public enum PerspectiveDirection: Sendable, CaseIterable {

    case clockwise
    case counterclockwise
}
