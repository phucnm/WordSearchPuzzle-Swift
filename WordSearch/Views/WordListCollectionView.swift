//
//  WordListCollectionView.swift
//  WordSearch
//
//  Created by TonyNguyen on 5/10/19.
//  Copyright © 2019 Phuc Nguyen. All rights reserved.
//

import Foundation
import UIKit

/// This view shows the list of words to be searched
class WordListCollectionView: UICollectionView {

    /// The left and right inset of the collection view
    private let inset: CGFloat = 10
    fileprivate let cellId = "WordCell"

    /// This is computed to store states of the words if they are selected or not
    fileprivate var wordSelectedMap: [String: Bool] = [:]

    var words: [String] = [] {
        didSet {
            wordSelectedMap = Dictionary(uniqueKeysWithValues: words.lazy.map { ($0, false) })
            reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
    }

    /// A corrected word has been selected
    func select(word: String) {
        guard let index = words.firstIndex(of: word) else {
            return
        }
        wordSelectedMap[word] = true
        let indexPath = IndexPath(item: index, section: 0)
        reloadItems(at: [indexPath])
    }

    /// Reset states of words and collection view
    func reset() {
        for key in wordSelectedMap.keys { wordSelectedMap[key] = false }
        reloadData()
    }
}

extension WordListCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! WordCollectionViewCell
        let word = words[indexPath.row]
        let isSelected = wordSelectedMap[word, default: false]
        cell.configure(with: word, selected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((bounds.width - 2 * inset) - 20) / 3
        let height = bounds.height / 3
        return CGSize(width: width, height: height)
    }
}
