//
//  LinesOverlay.swift
//  WordSearch
//
//  Created by TonyNguyen on 5/10/19.
//  Copyright © 2019 Phuc Nguyen. All rights reserved.
//

import Foundation
import UIKit

class LinesOverlay: UIView {
    var tempLine: Line?
    var permanentLines: [Line] = []
    var row: Int = 0
    var col: Int = 0

    var cellSize: CGSize {
        let w = bounds.width / CGFloat(col)
        let h = bounds.height / CGFloat(row)
        return CGSize(width: w, height: h)
    }

    lazy private var selectingStyle: LineStyle = LineStyle(
        opacity: 0.5,
        lineWidth: min(cellSize.width, cellSize.height) * 0.8,
        strokeColor:
        UIColor.blue.cgColor
    )

    lazy private var selectedStyle: LineStyle = LineStyle(
        opacity: 0.5,
        lineWidth: min(cellSize.width, cellSize.height) * 0.8,
        strokeColor:
        UIColor.orange.cgColor
    )

    func reset() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        tempLine = nil
        permanentLines.removeAll()
    }

    func addTempLine(at position: Position) {
        tempLine = Line(style: selectingStyle)
        tempLine?.cellSize = cellSize
        tempLine?.startPos = position
        tempLine?.endPos = position
    }

    func moveTempLine(to position: Position) -> Bool {
        if tempLine?.attempt(endPos: position) == true {
            tempLine?.draw(on: self)
            return true
        }
        return false
    }

    func removeTempLine() {
        self.tempLine?.removeFromSuperlayer()
        self.tempLine = nil
    }

    func acceptLastLine() {
        if let permLine = tempLine {
            permLine.lineStyle = selectedStyle
            permanentLines.append(permLine)
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        tempLine?.cellSize = cellSize
        tempLine?.draw(on: self)
        for line in permanentLines {
            line.cellSize = cellSize
            line.draw(on: self)
        }
    }
}
