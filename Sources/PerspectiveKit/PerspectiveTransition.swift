import UIKit

/* Переход между ровной вьюхой и наклоном в `PerspectiveView.setTilted(_:animated:)`, как карточка, которую отклеивают
 от страницы. При наклоне вьюха коротко подаётся к зрителю и оседает в наклон, а наклон и тень дорастают пружиной.
 Обратно — зеркально: вьюху подхватывают, выравнивают в воздухе и кладут на место без недолёта и отскока.
 Размер в обоих состояниях один, масштаб меняется только в переходе. */
enum PerspectiveTransition {

    /* Пик подачи раньше, чем пружина наклона доходит до цели: вьюха сначала подскакивает, потом ложится в наклон. */
    static let lift = Pulse(peakScale: 1.035, riseDuration: 0.18, settleDuration: 0.42)
    /* За подхват наклон уходит, за посадку вьюха ложится на место. */
    static let place = Pulse(peakScale: 1.03, riseDuration: 0.24, settleDuration: 0.32)

    /* Тень на верхней точке подхвата: размытие и смещение больше, прозрачность меньше. */
    static let placeShadowGrowth: CGFloat = 1.15
    static let placeShadowOpacity: Float = 0.85

    /* Пружина наклона и тени, как в `UISpringTimingParameters`: время одного колебания и затухание (1 — без отскока). */
    private static let tiltResponse: CGFloat = 0.6
    private static let tiltDampingRatio: CGFloat = 0.8

    /* Аддитивная пружина: досчитывает переход поверх того, что уже анимирует слой. */
    static func tiltSpring(keyPath: String, from: Any?, to: Any?) -> CASpringAnimation {
        let animation = CASpringAnimation(keyPath: keyPath)
        animation.stiffness = pow(2 * .pi / tiltResponse, 2)
        animation.damping = 4 * .pi * tiltDampingRatio / tiltResponse
        animation.duration = animation.settlingDuration
        animation.fromValue = from
        animation.toValue = to
        animation.isAdditive = true
        return animation
    }
}

/* Подача к зрителю и возврат к своему размеру. Обе фазы стартуют и кончаются без скорости,
 поэтому нет рывка ни из покоя, ни на верхней точке, ни в конце. */
struct Pulse {

    let peakScale: CGFloat
    let riseDuration: TimeInterval
    let settleDuration: TimeInterval

    /* Тень на верхней точке подачи: во сколько раз она мягче и ниже, чем в покое. 1 — без всплеска. */
    var peakShadowGrowth: CGFloat = 1

    private static var riseTiming: CAMediaTimingFunction { CAMediaTimingFunction(controlPoints: 0.3, 0, 0.4, 1) }
    private static var settleTiming: CAMediaTimingFunction { CAMediaTimingFunction(controlPoints: 0.45, 0, 0.35, 1) }

    var duration: TimeInterval { riseDuration + settleDuration }

    /* Значения в начале, на верхней точке и в конце. */
    func keyframes(keyPath: String, values: [Any]) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.values = values
        animation.keyTimes = [0, NSNumber(value: riseDuration / duration), 1]
        animation.timingFunctions = [Self.riseTiming, Self.settleTiming]
        animation.duration = duration
        return animation
    }

    func hold(keyPath: String, value: Any?) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = value
        animation.toValue = value
        animation.duration = duration
        return animation
    }
}
