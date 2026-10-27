import UIKit

/* Наклон описан одной непрерывной функцией от фазы: ось поворота равномерно идёт по кругу,
 угол наклона постоянный, тень меняется плавно. UIKit снимает с неё ключевые кадры, SwiftUI считает каждый кадр,
 поэтому движение в обоих одинаковое и без изломов на углах. */
extension PerspectiveConfig {

    var perspective: CATransform3D {
        var transform = CATransform3DIdentity
        if distortion > 0 {
            transform.m34 = 1 / distortion
        }
        return transform
    }

    func rotation(phase: Double) -> CATransform3D {
        let axis = phase * 2 * .pi
        return CATransform3DMakeRotation(angle * .pi / 180, cos(axis), sin(axis), 0)
    }

    func transform(phase: Double) -> CATransform3D {
        CATransform3DConcat(rotation(phase: phase), perspective)
    }

    /* Вбок тень уходит по синусу, вниз — по кривой через start (вверху), corner (по бокам) и maximum (внизу). */
    func shadowOffset(phase: Double) -> CGSize {
        guard let shadow else { return .zero }
        let axis = phase * 2 * .pi
        let start = shadow.startVerticalOffset
        let side = shadow.cornerVerticalOffset
        let maximum = shadow.maximumVerticalOffset
        let base = (start + maximum) / 4 + side / 2
        let vertical = base + (start - maximum) / 2 * cos(axis) + (base - side) * cos(2 * axis)
        return CGSize(width: shadow.maximumHorizontalOffset * sin(axis), height: vertical)
    }

    /* Фаза в точке progress (0...1) цикла анимации, начатого с corner. */
    func phase(from corner: PerspectiveCorner, progress: Double) -> Double {
        guard let animation else { return corner.phase }
        switch animation.direction {
        case .clockwise: return corner.phase + progress
        case .counterclockwise: return corner.phase - progress
        }
    }
}

extension CALayer {

    /* 64 кадра на круг: между соседними кадрами ось сдвигается на 5,6°, интерполяция Core Animation там уже не видна. */
    private static let keyframeCount = 64

    func applyPerspectiveMotion(_ config: PerspectiveConfig, corner: PerspectiveCorner, base: CATransform3D, traitCollection: UITraitCollection) {
        removePerspectiveMotion()

        if let shadow = config.shadow {
            shadowColor = shadow.color.resolvedColor(with: traitCollection).cgColor
            shadowOpacity = Float(shadow.opacity)
            shadowRadius = shadow.blurRadius
        }

        let startPhase = corner.phase
        transform = CATransform3DConcat(config.rotation(phase: startPhase), base)
        if config.shadow != nil {
            shadowOffset = config.shadowOffset(phase: startPhase)
        }

        guard let animation = config.animation else { return }

        let phases = (0...Self.keyframeCount).map { config.phase(from: corner, progress: Double($0) / Double(Self.keyframeCount)) }

        let transformAnimation = Self.makeLoopAnimation(keyPath: "transform", duration: animation.duration)
        transformAnimation.values = phases.map { NSValue(caTransform3D: CATransform3DConcat(config.rotation(phase: $0), base)) }
        add(transformAnimation, forKey: Self.transformAnimationKey)

        if config.shadow != nil {
            let shadowAnimation = Self.makeLoopAnimation(keyPath: "shadowOffset", duration: animation.duration)
            shadowAnimation.values = phases.map { NSValue(cgSize: config.shadowOffset(phase: $0)) }
            add(shadowAnimation, forKey: Self.shadowAnimationKey)
        }
    }

    func removePerspectiveMotion() {
        removeAnimation(forKey: Self.transformAnimationKey)
        removeAnimation(forKey: Self.shadowAnimationKey)
        transform = CATransform3DIdentity
        shadowOffset = .zero
        shadowRadius = 0
        shadowOpacity = 0
        shadowColor = nil
    }

    // MARK: - Private

    private static var transformAnimationKey: String { "PerspectiveKit.transform" }
    private static var shadowAnimationKey: String { "PerspectiveKit.shadow" }

    private static func makeLoopAnimation(keyPath: String, duration: TimeInterval) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.repeatCount = .infinity
        /* Иначе анимацию снимет при уходе приложения в фон. */
        animation.isRemovedOnCompletion = false
        return animation
    }
}
