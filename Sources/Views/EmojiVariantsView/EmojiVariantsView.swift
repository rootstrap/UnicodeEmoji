//
//  EmojiVariantsView.swift
//  promptchal
//
//  Created by German on 6/4/19.
//  Copyright © 2019 TopTier labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public class EmojiVariantsView: UIView {

    static let viewIdentifier = "EmojiVariantsView"
    static let verticalSpacing: CGFloat = 12
    static let horizontalStackSpacing: CGFloat = 10

    @IBOutlet weak var backgroundBlurView: UIVisualEffectView!
    @IBOutlet weak var emojisStack: UIStackView!

    var tipPathLimits: (start: CGFloat, end: CGFloat)?
    var emojiSize = CGSize(width: 50, height: 50)
    var emojis: [Emoji] = [] {
        didSet {
            updateStackContents()
        }
    }

    public convenience init(emojiVariants: [Emoji], variantSize: CGSize) {
        let emojiCount = CGFloat(emojiVariants.count)
        let totalWidth = EmojiVariantsView.horizontalStackSpacing * (emojiCount + 1)
            + variantSize.width * emojiCount
        let totalHeight = variantSize.height + EmojiVariantsView.verticalSpacing
            + EmojiVariantsView.horizontalStackSpacing * 2
        let size = CGSize(width: totalWidth, height: totalHeight)
        self.init(frame: CGRect(origin: .zero, size: size))
        emojiSize = variantSize
        emojis = emojiVariants
        updateStackContents()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadFromNib()
        setupUI()
    }

    public override func draw(_ rect: CGRect) {
        let limits = tipPathLimits ?? (start: 0.5, end: 0.5)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = backgroundBlurView.bounds
        var roundRectFrame = backgroundBlurView.bounds
        roundRectFrame.size.height -= EmojiVariantsView.verticalSpacing
        let path = UIBezierPath(roundedRect: roundRectFrame, cornerRadius: 7)
        let tipPath = UIBezierPath()
        let pivotPoint = CGPoint(x: limits.start, y: 0)
        tipPath.move(to: pivotPoint.convertNormalized(to: backgroundBlurView.bounds))
        let points = [CGPoint(x: limits.end, y: 0),
                      CGPoint(x: (limits.start + limits.end) / 2, y: 1),
                      pivotPoint]
        for point in points {
            tipPath.addLine(to: point.convertNormalized(to: backgroundBlurView.bounds))
        }
        tipPath.close()
        path.append(tipPath)
        maskLayer.path = path.cgPath
        backgroundBlurView.layer.mask = maskLayer
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadFromNib()
        setupUI()
    }


    /// The target point needs to be converted to this view's coordinate space.
    public func pointTo(_ point: CGPoint) {
        let pointTip = point.x / frame.width
        let tipTrianglePathTopSide: CGFloat = 0.5
        let tipPathXPivot = pointTip - tipTrianglePathTopSide / 2
        let tipPathXEnd = tipPathXPivot + tipTrianglePathTopSide

        tipPathLimits = (start: tipPathXPivot, end: tipPathXEnd)
        setNeedsDisplay()
    }

    private func setupUI() {
        emojisStack.spacing = EmojiVariantsView.horizontalStackSpacing
        isOpaque = false
    }

    private func updateStackContents() {
        emojisStack.subviews.forEach { $0.removeFromSuperview() }

        emojis.forEach { emoji in
            let label = UILabel(frame: CGRect(origin: .zero, size: emojiSize))
            label.makeEmojiFriendly()
            label.text = emoji.prettyPrinted
            emojisStack.addArrangedSubview(label)
        }
    }

    private func loadFromNib() {
        let nib = UINib(
            nibName: EmojiVariantsView.viewIdentifier,
            bundle: Bundle(for: EmojiVariantsView.self)
        )

        guard let contentView = nib.instantiate(withOwner: self).first as? UIView else { return }
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }

    public func emoji(at point: CGPoint) -> Emoji? {
        let horizontalPosition = Int(point.x / (emojisStack.frame.width / CGFloat(emojis.count)))
        guard emojisStack.frame.contains(point),
              horizontalPosition < emojis.count else { return nil }
        return emojis[horizontalPosition]
    }

    public func animate(toVisible visible: Bool, anchorPoint: CGPoint? = nil) {
        setInitialState(forVisibility: visible, anchorPoint: anchorPoint)

        UIView.animate(
            withDuration: Animation.Duration.normal, delay: 0,
            usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .curveEaseInOut,
            animations: {
                self.alpha = visible ? 1 : 0
                self.transform = self.transform(forVisibility: visible)
            }, completion: { _ in
                if !visible {
                    self.removeFromSuperview()
                }
            })
    }

    /**
     Sets initial state for animating entrance or exit.
     - Note: Preserves always the Y anchor and animates out to desired point in the X axis.
     */
    private func setInitialState(forVisibility visible: Bool, anchorPoint: CGPoint?) {
        alpha = visible ? 0 : 1
        transform = transform(forVisibility: !visible)
        var customAnchor: CGPoint?
        if let anchor = anchorPoint {
            customAnchor = CGPoint(x: anchor.x, y: bounds.midY)
        }
        setAnchorPoint(customAnchor ?? CGPoint(x: bounds.midX, y: bounds.midY))
    }

    private func transform(forVisibility visible: Bool) -> CGAffineTransform {
        if visible { return .identity }
        
        return CGAffineTransform(translationX: 0, y: frame.height / 2)
            .scaledBy(x: Animation.Scale.toTenPercent, y: Animation.Scale.toTenPercent)
    }
}

fileprivate extension EmojiVariantsView {
    enum Animation {
        enum Scale {
            static let dissapear: CGFloat = 0.01
            static let toTenPercent: CGFloat = 0.1
            static let original: CGFloat = 1
            static let growAQuarter: CGFloat = 1.25
        }

        enum Duration {
            static let normal: Double = 0.35
            static let fast: Double = 0.2
            static let faster: Double = 0.15
        }
    }
}
#endif
