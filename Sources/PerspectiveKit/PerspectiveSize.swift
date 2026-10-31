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

    /* Угол растёт чуть-чуть: вьюха 100 pt наклоняется на 11°, 44 pt — на 13°. Круче маленькая вьюха выглядит заваленной,
     живость ей даёт подача. */
    func scaled(by factor: CGFloat) -> PerspectiveConfig {
        guard factor < 1 else { return self }
        var config = self
        config.angle /= pow(factor, 0.25)
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

    /* Подача растёт быстрее, чем уменьшается вьюха: 100 pt подаётся на 7%, 44 pt — на 36%. Тень на верхней точке
     растёт вместе с добавкой к подаче: у 44 pt она в 2,3 раза мягче и ниже. */
    func amplified(by factor: CGFloat) -> Pulse {
        guard factor < 1 else { return self }
        let amplifiedScale = 1 + (peakScale - 1) / (factor * factor)
        return Pulse(
            peakScale: amplifiedScale,
            riseDuration: riseDuration,
            settleDuration: settleDuration,
            peakShadowGrowth: 1 + (amplifiedScale - peakScale) * 4
        )
    }
}
