import UIKit

/* Зачем: пресеты подобраны на виджете, а перспектива, размытие и смещения тени заданы в пунктах. На вьюхе меньше
 виджета те же пункты почти не видны: иконка 44 pt наклоняется без перспективы, а тень расплывается шире неё самой.
 Поэтому меньшая вьюха получает эти значения в долях своего размера, как уменьшенный виджет. Но уменьшенный виджет
 на маленькой вьюхе всё равно выглядит вялым: несколько пикселей наклона и подачи глаз почти не замечает.
 Поэтому чем меньше вьюха, тем больше угол и сильнее подача. Вьюхи размером с виджет и больше не меняются. */
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

    /* Угол растёт обратно корню из доли: вьюха 100 pt наклоняется на 12°, 44 pt — на 18°. */
    func scaled(by factor: CGFloat) -> PerspectiveConfig {
        guard factor < 1 else { return self }
        var config = self
        config.angle /= factor.squareRoot()
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

    /* Подача обратно доле: в пунктах маленькая вьюха подаётся так же, как виджет. 100 pt — на 4,9%, 44 pt — на 11%. */
    func amplified(by factor: CGFloat) -> Pulse {
        guard factor < 1 else { return self }
        return Pulse(
            peakScale: 1 + (peakScale - 1) / factor,
            riseDuration: riseDuration,
            settleDuration: settleDuration
        )
    }
}
