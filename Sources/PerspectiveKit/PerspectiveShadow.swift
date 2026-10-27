import UIKit

/* Тень смещается вслед за наклоном. Вертикальные смещения задаются по возрастанию: start < corner < maximum. */
public struct PerspectiveShadow: Equatable, Sendable {

    public var color: UIColor
    public var opacity: CGFloat
    public var blurRadius: CGFloat

    /* Смещение вбок в положениях mediumLeft и mediumRight. */
    public var maximumHorizontalOffset: CGFloat

    /* Смещение вниз в положении topMedium. */
    public var startVerticalOffset: CGFloat

    /* Смещение вниз в положениях mediumLeft и mediumRight. */
    public var cornerVerticalOffset: CGFloat

    /* Смещение вниз в положении bottomMedium. */
    public var maximumVerticalOffset: CGFloat

    public init(
        color: UIColor = .black,
        opacity: CGFloat,
        blurRadius: CGFloat,
        maximumHorizontalOffset: CGFloat,
        startVerticalOffset: CGFloat,
        cornerVerticalOffset: CGFloat,
        maximumVerticalOffset: CGFloat
    ) {
        self.color = color
        self.opacity = opacity
        self.blurRadius = blurRadius
        self.maximumHorizontalOffset = maximumHorizontalOffset
        self.startVerticalOffset = startVerticalOffset
        self.cornerVerticalOffset = cornerVerticalOffset
        self.maximumVerticalOffset = maximumVerticalOffset
    }

    /* Тень превью в галерее виджетов iOS 27: ходит по кругу радиусом 17 вокруг (0, 18). */
    public static let widget = PerspectiveShadow(
        opacity: 0.27,
        blurRadius: 18,
        maximumHorizontalOffset: 17,
        startVerticalOffset: 1,
        cornerVerticalOffset: 18,
        maximumVerticalOffset: 35
    )
}
