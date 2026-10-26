import UIKit

@MainActor
public extension UIView {

    func applyPerspective(_ config: PerspectiveConfig) {
        resetPerspective()
        let corner = config.corner ?? .random

        /* Без этого при наклоне край вьюхи обрезается соседними слоями. */
        layer.zPosition = 999

        if let shadow = config.shadow {
            layer.shadowColor = shadow.color.cgColor
            layer.shadowOpacity = Float(shadow.opacity)
            layer.shadowRadius = shadow.blurRadius
        }

        guard let animation = config.animation else {
            layer.transform = config.transform(axis: corner.axis)
            if let shadow = config.shadow {
                layer.shadowOffset = corner.shadowOffset(shadow)
            }
            return
        }

        /* Последним кадром повторяем первый, чтобы цикл замкнулся без скачка. */
        let corners = corner.cycle(animation.direction) + [corner]

        let transformAnimation = makeLoopAnimation(keyPath: "transform", duration: animation.duration)
        transformAnimation.values = corners.map { NSValue(caTransform3D: config.transform(axis: $0.axis)) }
        layer.add(transformAnimation, forKey: Self.transformAnimationKey)

        if let shadow = config.shadow {
            let shadowAnimation = makeLoopAnimation(keyPath: "shadowOffset", duration: animation.duration)
            shadowAnimation.values = corners.map { NSValue(cgSize: $0.shadowOffset(shadow)) }
            layer.add(shadowAnimation, forKey: Self.shadowAnimationKey)
        }
    }

    func resetPerspective() {
        layer.removeAnimation(forKey: Self.transformAnimationKey)
        layer.removeAnimation(forKey: Self.shadowAnimationKey)
        layer.transform = CATransform3DIdentity
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowColor = nil
    }

    // MARK: - Private

    private static var transformAnimationKey: String { "PerspectiveKit.transform" }
    private static var shadowAnimationKey: String { "PerspectiveKit.shadow" }

    private func makeLoopAnimation(keyPath: String, duration: TimeInterval) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.repeatCount = .infinity
        /* Иначе анимацию снимет при уходе приложения в фон. */
        animation.isRemovedOnCompletion = false
        return animation
    }
}
