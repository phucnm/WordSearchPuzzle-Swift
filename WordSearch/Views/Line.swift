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
    var cellSize: CGSize = .zero
    var lineStyle: LineStyle = LineStyle(
        opacity: 0.5,
        lineWidth: 10,
        strokeColor:
        UIColor.blue.cgColor
    )
    var startPos: Position?
    var endPos: Position?
    private var shapeLayer: CAShapeLayer?

    init(style: LineStyle) {
        super.init()
        self.lineStyle = style
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func point(at pos: Position) -> CGPoint {
        return CGPoint(
            x: CGFloat(pos.col) * cellSize.width + cellSize.width / 2,
            y: CGFloat(pos.row) * cellSize.height + cellSize.height / 2)
    }

    private func isHorizontal(with endPos: Position) -> Bool {
        guard let startPos = startPos else {
            return false
        }
        return startPos.row == endPos.row
    }

    private func isVertical(with endPos: Position) -> Bool {
        guard let startPos = startPos else {
            return false
        }
        return startPos.col == endPos.col
    }

    private func isDiagonal(with endPos: Position) -> Bool {
        guard let startPos = startPos else {
            return false
        }
        return abs(startPos.row - endPos.row) == abs(startPos.col - endPos.col)
    }

    func attempt(endPos: Position) -> Bool {
        if isHorizontal(with: endPos) ||
            isVertical(with: endPos) ||
            isDiagonal(with: endPos) {
            self.endPos = endPos
            return true
        }
        return false
    }

    func draw(on view: UIView) {
        guard let startPos = startPos,
            let endPos = endPos else {
                return
        }
        self.removeFromSuperlayer()
        let tempPath = UIBezierPath()
        tempPath.move(to: point(at: startPos))
        tempPath.addLine(to: point(at: endPos))
        opacity = lineStyle.opacity
        lineCap = .round
        lineWidth = lineStyle.lineWidth
        strokeColor = lineStyle.strokeColor
        path = tempPath.cgPath
        view.layer.addSublayer(self)
    }
}
