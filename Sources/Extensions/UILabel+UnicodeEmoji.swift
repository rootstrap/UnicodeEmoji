#if canImport(UIKit)
import UIKit

extension UILabel {

    func makeEmojiFriendly() {
        // Make font size big enough to let the label adjust its font for smaller cells
        font = UIFont(name: "AppleColorEmoji", size: 70)
        textAlignment = .center
        numberOfLines = 1
        adjustsFontSizeToFitWidth = true
        baselineAdjustment = .alignCenters
    }

}

#endif
