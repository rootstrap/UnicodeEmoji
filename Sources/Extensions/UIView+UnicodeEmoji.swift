#if canImport(UIKit)
import UIKit

extension UIView {

    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = point
        var oldPoint = layer.anchorPoint.convertNormalized(to: bounds)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position: CGPoint = layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point.normalized(for: bounds)
    }
    
}

#endif
