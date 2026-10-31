import UIKit

/* Зачем: пресеты подобраны на виджете, а перспектива, размытие и смещения тени заданы в пунктах. На вьюхе меньше
 виджета те же пункты почти не видны: иконка 44 pt наклоняется без перспективы, а тень расплывается шире неё самой.
 Поэтому меньшая вьюха получает эти значения в долях своего размера, как уменьшенный виджет. Подача масштабом
 и так в долях, но 3,5% от маленькой вьюхи — пара пикселей, поэтому она сильнее. Вьюхи размером с виджет
 и больше не меняются. */
extension PerspectiveConfig {

    /* Сторона самого маленького small-виджета iPhone. */
    private static let calibrationSide: CGFloat = 141

    /* Доля от размера виджета, 1 — виджет и больше. Ширина или высота, что больше: у широкой карточки
     перспектива и тень видны по длинной стороне. */
    static func sizeFactor(for size: CGSize) -> CGFloat {
        let side = max(size.width, size.height)
        guard side > 0 else { return 1 }
        return min(side / calibrationSide, 1)
    }

    func scaled(by factor: CGFloat) -> PerspectiveConfig {
        guard factor < 1 else { return self }
        var config = self
        config.distortion *= factor
        if var shadow {
            shadow.blurRadius *= factor
            shadow.maximumHorizontalOffset *= factor
            shadow.startVerticalOffset *= factor
            shadow.cornerVerticalOffset *= factor
            shadow.maximumVerticalOffset *= factor
            config.shadow = shadow
        }
        return config
    }
}

extension Pulse {

    /* Подача растёт медленнее, чем уменьшается вьюха: вдвое меньшая вьюха подаётся в 1,4 раза сильнее. */
    func amplified(by factor: CGFloat) -> Pulse {
        guard factor < 1 else { return self }
        return Pulse(
            peakScale: 1 + (peakScale - 1) / factor.squareRoot(),
            riseDuration: riseDuration,
            settleDuration: settleDuration
        )
    }
}
