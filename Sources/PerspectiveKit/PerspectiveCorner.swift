import UIKit

public enum PerspectiveCorner: String, Sendable, CaseIterable {

    case topLeft
    case topMedium
    case topRight
    case mediumLeft
    case mediumRight
    case bottomLeft
    case bottomMedium
    case bottomRight

    public static var random: PerspectiveCorner {
        allCases.randomElement()!
    }

    /* Все положения по кругу, начиная с текущего. */
    public func cycle(_ direction: PerspectiveDirection) -> [PerspectiveCorner] {
        var order: [PerspectiveCorner] = [.topMedium, .topRight, .mediumRight, .bottomRight, .bottomMedium, .bottomLeft, .mediumLeft, .topLeft]
        if direction == .counterclockwise {
            order.reverse()
        }
        let index = order.firstIndex(of: self)!
        return Array(order[index...] + order[..<index])
    }

    // MARK: - Internal

    /* Ось поворота. Длина не важна, CATransform3DRotate её нормализует. */
    var axis: CGVector {
        switch self {
        case .topMedium: CGVector(dx: 2, dy: 0)
        case .topRight: CGVector(dx: 1, dy: 1)
        case .mediumRight: CGVector(dx: 0, dy: 2)
        case .bottomRight: CGVector(dx: -1, dy: 1)
        case .bottomMedium: CGVector(dx: -2, dy: 0)
        case .bottomLeft: CGVector(dx: -1, dy: -1)
        case .mediumLeft: CGVector(dx: 0, dy: -2)
        case .topLeft: CGVector(dx: 1, dy: -1)
        }
    }

    func shadowOffset(_ shadow: PerspectiveShadow) -> CGSize {
        let horizontal = shadow.maximumHorizontalOffset
        let topCornerVertical = (shadow.startVerticalOffset + shadow.cornerVerticalOffset) / 2
        switch self {
        case .topMedium: return CGSize(width: 0, height: shadow.startVerticalOffset)
        case .topRight: return CGSize(width: horizontal / 2, height: topCornerVertical)
        case .mediumRight: return CGSize(width: horizontal, height: shadow.cornerVerticalOffset)
        case .bottomRight: return CGSize(width: horizontal / 2, height: shadow.cornerVerticalOffset)
        case .bottomMedium: return CGSize(width: 0, height: shadow.maximumVerticalOffset)
        case .bottomLeft: return CGSize(width: -horizontal / 2, height: shadow.cornerVerticalOffset)
        case .mediumLeft: return CGSize(width: -horizontal, height: shadow.cornerVerticalOffset)
        case .topLeft: return CGSize(width: -horizontal / 2, height: topCornerVertical)
        }
    }
}

extension PerspectiveConfig {

    func transform(axis: CGVector) -> CATransform3D {
        var transform = CATransform3DIdentity
        if distortion > 0 {
            transform.m34 = 1 / distortion
        }
        return CATransform3DRotate(transform, angle * .pi / 180, axis.dx, axis.dy, 0)
    }

    /* Наклон и смещение тени в точке цикла progress (0...1), начатого с corner.
     Нужно для SwiftUI, где нет CAKeyframeAnimation: соседние положения интерполируются линейно. */
    func frame(from corner: PerspectiveCorner, progress: Double) -> (transform: CATransform3D, shadowOffset: CGSize) {
        guard let animation else {
            return (transform(axis: corner.axis), shadow.map(corner.shadowOffset) ?? .zero)
        }
        let corners = corner.cycle(animation.direction)
        let position = progress * Double(corners.count)
        let index = Int(position) % corners.count
        let t = CGFloat(position - position.rounded(.down))
        let from = corners[index]
        let to = corners[(index + 1) % corners.count]
        let axis = CGVector(
            dx: from.axis.dx + (to.axis.dx - from.axis.dx) * t,
            dy: from.axis.dy + (to.axis.dy - from.axis.dy) * t
        )
        var shadowOffset = CGSize.zero
        if let shadow {
            let fromOffset = from.shadowOffset(shadow)
            let toOffset = to.shadowOffset(shadow)
            shadowOffset = CGSize(
                width: fromOffset.width + (toOffset.width - fromOffset.width) * t,
                height: fromOffset.height + (toOffset.height - fromOffset.height) * t
            )
        }
        return (transform(axis: axis), shadowOffset)
    }
}
