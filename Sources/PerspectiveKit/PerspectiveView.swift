import UIKit

/* Контейнер, который наклоняет contentView. Свои вью кладутся в contentView, как в UIVisualEffectView.
 Перспектива задаётся через sublayerTransform контейнера, поэтому наклонённый край не уходит под соседние вью
 и zPosition трогать не нужно. Тень висит на contentView, так что clipsToBounds у вложенной карточки её не обрезает. */
@MainActor
open class PerspectiveView: UIView {

    public let contentView = UIView()

    open var config: PerspectiveConfig = .widgetAnimatable {
        didSet {
            if config != oldValue {
                updatePerspective()
            }
        }
    }

    /* Для corner = nil положение выбирается один раз, чтобы смена конфига не перескакивала на другой угол. */
    private let randomCorner = PerspectiveCorner.allCases.randomElement()!

    public init(config: PerspectiveConfig = .widgetAnimatable) {
        self.config = config
        super.init(frame: .zero)
        commonInit()
    }

    public required init?(coder: NSCoder) {
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
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        contentView.layer.shadowColor = config.shadow?.color.resolvedColor(with: traitCollection).cgColor
    }

    // MARK: - Private

    @objc private func reduceMotionStatusDidChange() {
        updatePerspective()
    }

    private func updatePerspective() {
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
