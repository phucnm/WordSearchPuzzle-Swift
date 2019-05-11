//
//  Line.swift
//  WordSearch
//
//  Created by TonyNguyen on 5/10/19.
//  Copyright © 2019 Phuc Nguyen. All rights reserved.
//

import Foundation
import UIKit

struct LineStyle {
    var opacity: Float
    var lineWidth: CGFloat
    var strokeColor: CGColor
}

struct Position {
    var row: Int
    var col: Int
}

class Line: CAShapeLayer {

    /// This property is set externally to compute the
    /// center point of the line
    var cellSize: CGSize = .zero


    /// Line style
    var lineStyle: LineStyle = LineStyle(
        opacity: 0.5,
        lineWidth: 10,
        strokeColor: UIColor.blue.cgColor
    )

    /// Start position of the line. It should be set once in touchesBegan or
    /// at the beginning of the gesture handling.
    var startPos: Position?


    /// End position of the line. It should be updated as the gesture moves.
    var endPos: Position?

    init(style: LineStyle) {
        super.init()
        self.lineStyle = style
    }

    /// To support layer copy when drawing a permanent line of a corrected word
    /// from a temporary line.
    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /// Convert a letter at row, col to center point of the cell
    ///
    /// - Parameter pos: Position object
    /// - Returns: center point of the corresponding cell
    private func point(at pos: Position) -> CGPoint {
        return CGPoint(
            x: CGFloat(pos.col) * cellSize.width + cellSize.width / 2,
            y: CGFloat(pos.row) * cellSize.height + cellSize.height / 2)
    }


    /// Check if start position and end position are horizontal
    ///
    /// - Parameter endPos: target end position of the line
    /// - Returns: they are horizontal
    private func isHorizontal(with endPos: Position) -> Bool {
        guard let startPos = startPos else {
            return false
        }
        return startPos.row == endPos.row
    }


    /// Check if start position and end position are vertical
    ///
    /// - Parameter endPos: target end position of the line
    /// - Returns: they are vertical
    private func isVertical(with endPos: Position) -> Bool {
        guard let startPos = startPos else {
            return false
        }
        return startPos.col == endPos.col
    }

    /// Check if start position and end position are diagonal
    ///
    /// - Parameter endPos: target end position of the line
    /// - Returns: they are diagonal
    private func isDiagonal(with endPos: Position) -> Bool {
        guard let startPos = startPos else {
            return false
        }
        return abs(startPos.row - endPos.row) == abs(startPos.col - endPos.col)
    }


    /// Check if target end position is a valid one that is horizontal,
    /// vertical or diagonal with the start position. If valid, update the current
    /// end position
    ///
    /// - Parameter endPos: target end position of the line
    /// - Returns: if the end position is valid or not
    func attempt(endPos: Position) -> Bool {
        if isHorizontal(with: endPos) ||
            isVertical(with: endPos) ||
            isDiagonal(with: endPos) {
            self.endPos = endPos
            return true
        }
        return false
    }


    /// Draw the line to the containing view
    ///
    /// - Parameter view: containing view
    func draw(on view: UIView) {
        guard let startPos = startPos,
            let endPos = endPos else {
                return
        }
        self.removeFromSuperlayer()
        let tempPath = UIBezierPath()
        tempPath.move(to: point(at: startPos))
        tempPath.addLine(to: point(at: endPos))
        // This is cell each time drawing
        // In case we use different styles for each line
        // at runtime.
        opacity = lineStyle.opacity
        lineCap = .round
        lineWidth = lineStyle.lineWidth
        strokeColor = lineStyle.strokeColor
        path = tempPath.cgPath
        view.layer.addSublayer(self)
    }
}
