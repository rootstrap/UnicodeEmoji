//
//  StickerCollectionCell.swift
//  promptchal
//
//  Created by German on 5/30/19.
//  Copyright © 2019 TopTier labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public protocol StickerCellSelectionDelegate: AnyObject {
    func stickerCell(didBeginLongPress cell: StickerCollectionCell)
    func stickerCell(didEndLongPress cell: StickerCollectionCell, at touchUpPoint: CGPoint)
}

public class StickerCollectionCell: UICollectionViewCell {

    public static let reuseIdentifier = "StickerCollectionCell"

    public weak var delegate: StickerCellSelectionDelegate?

    var textContainer: UILabel!

    public var emoji: Emoji! {
        didSet {
            textContainer.text = emoji.prettyPrinted
            addLongPressRecongnizerIfNeeded()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textContainer = UILabel(frame: bounds)
        textContainer.makeEmojiFriendly()
        addSubview(textContainer)
    }

    private func addLongPressRecongnizerIfNeeded() {
        if emoji.variants.isEmpty { return }

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress)
        )
        addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            delegate?.stickerCell(didBeginLongPress: self)
        case .ended, .cancelled:
            delegate?.stickerCell(didEndLongPress: self, at: gesture.location(in: self))
        default:
            break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
