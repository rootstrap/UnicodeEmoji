#if canImport(UIKit)
import UIKit

extension CGPoint {

    func convertNormalized(to rect: CGRect) -> CGPoint {
        return CGPoint(x: x * rect.width + rect.origin.x,
                       y: y * rect.height + rect.origin.y)
    }

    func normalized(for rect: CGRect) -> CGPoint {
        return CGPoint(x: max(0, min(1, x / rect.width)),
                       y: max(0, min(1, y / rect.height)))
    }

}

#endif
