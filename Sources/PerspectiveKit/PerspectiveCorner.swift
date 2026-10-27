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

    @available(*, deprecated, message: "Pass nil as corner to get a random one")
    public static var random: PerspectiveCorner {
        allCases.randomElement()!
    }

    @available(*, deprecated, message: "Animation now moves continuously around the circle and doesn't use this order")
    public func cycle(_ direction: PerspectiveDirection) -> [PerspectiveCorner] {
        var order: [PerspectiveCorner] = [.topMedium, .topRight, .mediumRight, .bottomRight, .bottomMedium, .bottomLeft, .mediumLeft, .topLeft]
        if direction == .counterclockwise {
            order.reverse()
        }
        let index = order.firstIndex(of: self)!
        return Array(order[index...] + order[..<index])
    }

    // MARK: - Internal

    /* Положение на круге наклона в долях оборота по часовой стрелке от topMedium. */
    var phase: Double {
        switch self {
        case .topMedium: 0
        case .topRight: 1 / 8
        case .mediumRight: 2 / 8
        case .bottomRight: 3 / 8
        case .bottomMedium: 4 / 8
        case .bottomLeft: 5 / 8
        case .mediumLeft: 6 / 8
        case .topLeft: 7 / 8
        }
    }
}
