//
//  GridCollectionViewCell.swift
//  WordSearch
//
//  Created by TonyNguyen on 5/9/19.
//  Copyright © 2019 Phuc Nguyen. All rights reserved.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {

    static let cellId = "GridCell"

    private let animationScaleFactor: CGFloat = 1.5

    @IBOutlet weak var label: UILabel!

    override var isSelected: Bool {
        didSet {
            let transform = isSelected ? CGAffineTransform(scaleX: animationScaleFactor, y: animationScaleFactor) : .identity
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: {
                self.label.transform = transform
            }) { (_) in }
        }
    }
}
