import UIKit

/* Контейнер, который наклоняет contentView. Свои вью кладутся в contentView, как в UIVisualEffectView.
 Перспектива задаётся через sublayerTransform контейнера, поэтому наклонённый край не уходит под соседние вью
 и zPosition трогать не нужно. Тень висит на contentView, так что clipsToBounds у вложенной карточки её не обрезает. */
@MainActor
open class PerspectiveView: UIView {

    public let contentView = UIView()

    /* Каким будет наклон. Пока `isTilted` выключен, вьюха стоит ровно и без тени. */
    open var config: PerspectiveConfig = .widgetAnimatable {
        didSet {
            if config != oldValue {
                updatePerspective()
            }
        }
    }

    /* Наклонена ли вьюха. Меняется сразу, с переходом — `setTilted(_:animated:)`. */
    open var isTilted: Bool {
        get { tilted }
        set { setTilted(newValue, animated: false) }
    }

    private var tilted: Bool

    /* Для corner = nil положение выбирается один раз, чтобы смена конфига не перескакивала на другой угол. */
    private let randomCorner = PerspectiveCorner.allCases.randomElement()!

    public init(config: PerspectiveConfig = .widgetAnimatable, isTilted: Bool = true) {
        self.config = config
        self.tilted = isTilted
        super.init(frame: .zero)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        self.tilted = true
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(contentView)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reduceMotionStatusDidChange),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
        updatePerspective()
    }

    // MARK: - Layout

    /* У contentView есть transform, поэтому размер задаётся через bounds и center, а не frame. */
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.bounds = bounds
        contentView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard tilted, traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        contentView.layer.shadowColor = config.shadow?.color.resolvedColor(with: traitCollection).cgColor
    }

    // MARK: - Transition

    /* Как `UISwitch.setOn(_:animated:)`. Новое состояние ставится сразу, а переход досчитывается поверх него
     от текущего кадра, поэтому его можно прервать на середине. При «Уменьшении движения» — без подачи масштабом.
     Масштаб живёт в перспективе контейнера, `transform` самой вьюхи остаётся свободным. */
    open func setTilted(_ tilted: Bool, animated: Bool) {
        guard tilted != self.tilted else { return }
        let content = contentView.layer.presentation() ?? contentView.layer
        let scale = (layer.presentation() ?? layer).sublayerTransform.m11
        let perspective = layer.sublayerTransform
        self.tilted = tilted
        updatePerspective()
        guard animated else { return }

        if tilted {
            animateTilt(fromScale: scale)
        } else {
            animateLeveling(from: content, scale: scale, perspective: perspective)
        }
    }

    /* Наклон и тень дорастают пружиной поверх цикла покачивания, тень вырастает из-под вьюхи:
     прозрачность, размытие и смещение стартуют с нуля. */
    private func animateTilt(fromScale scale: CGFloat) {
        let card = contentView.layer
        let pulse = PerspectiveTransition.lift
        layer.add(pulse.keyframes(keyPath: "sublayerTransform", values: scaled(layer.sublayerTransform, [scale, pulseScale(pulse), 1])), forKey: Self.sublayerTransitionKey)
        card.add(PerspectiveTransition.tiltSpring(keyPath: "transform", from: CATransform3DInvert(card.transform), to: CATransform3DIdentity), forKey: "PerspectiveKit.transition.transform")
        card.add(PerspectiveTransition.tiltSpring(keyPath: "shadowOpacity", from: -card.shadowOpacity, to: 0), forKey: "PerspectiveKit.transition.shadowOpacity")
        card.add(PerspectiveTransition.tiltSpring(keyPath: "shadowRadius", from: -card.shadowRadius, to: 0), forKey: "PerspectiveKit.transition.shadowRadius")
        card.add(PerspectiveTransition.tiltSpring(keyPath: "shadowOffset", from: CGSize(width: -card.shadowOffset.width, height: -card.shadowOffset.height), to: CGSize.zero), forKey: "PerspectiveKit.transition.shadowOffset")
    }

    /* Наклон уходит за подхват. Тень следует высоте: на верхней точке она мягче, ниже и бледнее,
     а к касанию втягивается под вьюху. Ровное состояние сразу снимает перспективу и цвет тени,
     поэтому они держатся до конца перехода: иначе вьюха рывком сузилась бы, а тень пропала. */
    private func animateLeveling(from current: CALayer, scale: CGFloat, perspective: CATransform3D) {
        let card = contentView.layer
        let pulse = PerspectiveTransition.place
        let offset = current.shadowOffset
        let opacity = current.shadowOpacity
        layer.add(pulse.keyframes(keyPath: "sublayerTransform", values: scaled(perspective, [scale, pulseScale(pulse), 1])), forKey: Self.sublayerTransitionKey)
        card.add(pulse.hold(keyPath: "shadowColor", value: current.shadowColor), forKey: "PerspectiveKit.transition.shadowColor")
        card.add(pulse.keyframes(keyPath: "transform", values: [current.transform, CATransform3DIdentity, CATransform3DIdentity]), forKey: "PerspectiveKit.transition.transform")
        card.add(pulse.keyframes(keyPath: "shadowOpacity", values: [opacity, opacity * PerspectiveTransition.placeShadowOpacity, 0]), forKey: "PerspectiveKit.transition.shadowOpacity")
        card.add(pulse.keyframes(keyPath: "shadowRadius", values: [current.shadowRadius, current.shadowRadius * PerspectiveTransition.placeShadowGrowth, 0]), forKey: "PerspectiveKit.transition.shadowRadius")
        card.add(pulse.keyframes(keyPath: "shadowOffset", values: [offset, CGSize(width: 0, height: offset.height * PerspectiveTransition.placeShadowGrowth), CGSize.zero]), forKey: "PerspectiveKit.transition.shadowOffset")
    }

    private static var sublayerTransitionKey: String { "PerspectiveKit.transition.sublayerTransform" }

    private func pulseScale(_ pulse: Pulse) -> CGFloat {
        UIAccessibility.isReduceMotionEnabled ? 1 : pulse.peakScale
    }

    /* Перспектива с масштабом поверх: масштаб снаружи проекции, как у масштаба самой вьюхи. */
    private func scaled(_ perspective: CATransform3D, _ scales: [CGFloat]) -> [NSValue] {
        scales.map { NSValue(caTransform3D: CATransform3DConcat(perspective, CATransform3DMakeScale($0, $0, 1))) }
    }

    // MARK: - Private

    @objc private func reduceMotionStatusDidChange() {
        updatePerspective()
    }

    private func updatePerspective() {
        guard tilted else {
            layer.sublayerTransform = CATransform3DIdentity
            contentView.layer.removePerspectiveMotion()
            return
        }
        let config = config.respectingReduceMotion(UIAccessibility.isReduceMotionEnabled)
        layer.sublayerTransform = config.perspective
        contentView.layer.applyPerspectiveMotion(
            config,
            corner: config.corner ?? randomCorner,
            base: CATransform3DIdentity,
            traitCollection: traitCollection
        )
    }
}
