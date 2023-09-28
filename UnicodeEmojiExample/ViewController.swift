//
//  ViewController.swift
//  UnicodeEmojiExample
//
//  Created by German on 16/4/21.
//  Copyright © 2021 Rootstrap. All rights reserved.
//

import UIKit
import UnicodeEmoji

class ViewController: UIViewController {

    private var emojis: [Emoji] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    private var emojiVariantsView: EmojiVariantsView?

    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Emoji \(UnicodeEmojiVersion.current)"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .orange
        label.textAlignment = .center

        return label
    }()

    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.contentInset = UIEdgeInsets(top: 20, left: 12, bottom: 10, right: 12)

        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupCollectionView()
        setupLayout()

        if
            let emojiCollection = EmojiLoader.shared.emojiCollection,
            !EmojiLoader.shared.needsReload
        {
            emojis = emojiCollection.groups.flatMap { $0.allEmojis }
            return
        }
    }

    private func setupCollectionView() {
        collectionView.register(
            StickerCollectionCell.self,
            forCellWithReuseIdentifier: StickerCollectionCell.reuseIdentifier
        )
        collectionView.dataSource = self
    }

    private func setupLayout() {
        view.addSubview(collectionView)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

}

extension ViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        emojis.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StickerCollectionCell.reuseIdentifier,
            for: indexPath
        )

        if let cell = cell as? StickerCollectionCell, indexPath.item < emojis.count {
            cell.emoji = emojis[indexPath.item]
            cell.delegate = self
        }
        return cell
    }
    
}

extension ViewController: StickerCellSelectionDelegate {

    func stickerCell(didBeginLongPress cell: StickerCollectionCell) {
        guard cell.emoji.variants.count > 0 else {
            return
        }
        emojiVariantsView = EmojiVariantsView(
            emojiVariants: cell.emoji.variants,
            variantSize: cell.frame.size
        )
        guard let selectionView = emojiVariantsView else { return }

        setPosition(emojisView: selectionView, fromCell: cell)
        let targetPoint = selectionView.convert(cell.center, from: collectionView)
        selectionView.pointTo(targetPoint)
        view.addSubview(selectionView)
        selectionView.animate(toVisible: true)
    }

    func stickerCell(
        didEndLongPress cell: StickerCollectionCell,
        at touchUpPoint: CGPoint
    ) {
        guard let selectionView = emojiVariantsView else { return }

        let touchPointInView = cell.convert(touchUpPoint, to: selectionView)

        if let selectedEmoji = selectionView.emoji(at: touchPointInView) {
            debugPrint(selectedEmoji)
            selectionView.removeFromSuperview()
            emojiVariantsView = nil
        } else {
            let targetPoint = selectionView.convert(cell.center, from: collectionView)
            selectionView.animate(toVisible: false, anchorPoint: targetPoint)
        }
    }

    // Positions the view within the superview's bounds
    private func setPosition(
        emojisView: EmojiVariantsView,
        fromCell cell: UICollectionViewCell
    ) {
        let cellFrame = collectionView.convert(cell.frame, to: view)
        let idealXposition = cellFrame.midX - emojisView.frame.size.width / 2
        let maxXPosition = view.frame.width - emojisView.frame.size.width
        let minXPosition = max(0, idealXposition)
        let finalXPosition = min(minXPosition, maxXPosition)
        let verticalPosition = cellFrame.origin.y - emojisView.frame.height// + stickerSectionInset

        emojisView.frame.origin = CGPoint(x: finalXPosition, y: verticalPosition)
    }
}
