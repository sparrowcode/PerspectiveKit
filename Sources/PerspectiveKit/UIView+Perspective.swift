import UIKit

@MainActor
public extension UIView {

    @available(*, deprecated, message: "Use PerspectiveView: it keeps the view's own shadow and zPosition and follows Reduce Motion live")
    func applyPerspective(_ config: PerspectiveConfig) {
        let config = config.respectingReduceMotion(UIAccessibility.isReduceMotionEnabled)
        layer.applyPerspectiveMotion(
            config,
            corner: config.corner ?? PerspectiveCorner.allCases.randomElement()!,
            base: config.perspective,
            traitCollection: traitCollection
        )
        /* Без этого при наклоне край вьюхи уходит под соседние слои. */
        layer.zPosition = 999
    }

    @available(*, deprecated, message: "Use PerspectiveView")
    func resetPerspective() {
        layer.removePerspectiveMotion()
        layer.zPosition = 0
    }
}
