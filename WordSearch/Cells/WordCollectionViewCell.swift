//
//  WordCollectionViewCell.swift
//  WordSearch
//
//  Created by TonyNguyen on 5/10/19.
//  Copyright © 2019 Phuc Nguyen. All rights reserved.
//

import UIKit

class WordCollectionViewCell: UICollectionViewCell {

    static let cellId = "WordCell"
    
    @IBOutlet weak var label: UILabel!

    func configure(with text: String, selected: Bool) {
        if selected {
            let attrString = NSMutableAttributedString(string: text)
            let attrsDict = [
                NSAttributedString.Key.strikethroughStyle: 2,
                NSAttributedString.Key.foregroundColor: UIColor.gray,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
                ] as [NSAttributedString.Key : Any]
            attrString.addAttributes(attrsDict, range: NSRange(location: 0, length: text.count))
            label.attributedText = attrString
        } else {
            label.text = text
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 13)
        }
        label.backgroundColor = isSelected ? UIColor.gray.withAlphaComponent(0.5) : UIColor.clear
    }
}
