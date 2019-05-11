//
//  WordGrid.swift
//  WordSearch
//
//  Created by TonyNguyen on 5/9/19.
//  Copyright © 2019 Phuc Nguyen. All rights reserved.
//

import Foundation

typealias Grid = [[Character]]

fileprivate class CharacterRandomizer {
    private var alphaSet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    func randomChar() -> Character {
        return alphaSet.randomElement()!
    }
}

fileprivate extension Grid {
    func randomizePlaceHolders() -> Grid {
        var grid = self
        guard !self.isEmpty && !self[0].isEmpty else {
            return grid
        }
        let randomizer = CharacterRandomizer()
        for i in 0..<self.count {
            for j in 0..<self[0].count {
                if grid[i][j] == WordGridGenerator.placeholder {
                    grid[i][j] = randomizer.randomChar()
                }
            }
        }
        return grid
    }
}

class WordGridGenerator {
    public struct MovingStep {
        var stepRow: Int
        var stepCol: Int
    }

    public enum Direction: CaseIterable {
        case up
        case down
        case left
        case right
        case upLeft
        case upRight
        case downLeft
        case downRight

        func getMovingSteps() -> MovingStep {
            switch self {
            case .up:
                return MovingStep(stepRow: -1, stepCol: 0)
            case .down:
                return MovingStep(stepRow: 1, stepCol: 0)
            case .left:
                return MovingStep(stepRow: 0, stepCol: -1)
            case .right:
                return MovingStep(stepRow: 0, stepCol: 1)
            case .upLeft:
                return MovingStep(stepRow: -1, stepCol: -1)
            case .upRight:
                return MovingStep(stepRow: -1, stepCol: 1)
            case .downLeft:
                return MovingStep(stepRow: 1, stepCol: -1)
            case .downRight:
                return MovingStep(stepRow: 1, stepCol: 1)
            }
        }
    }

    var words: [String] = []
    // Key format: "startRow:startCol:endRow:endCol"
    // Value: the corresponding word
    // We will fill this map during grid generation
    var wordsMap: [String: String] = [:]
    var directions = Direction.allCases
    var nRow: Int = 10
    var nCol: Int = 10

    private class State {
        var grid: Grid
        var words: [String]
        var directions: [Direction]
        var positions: [Int]
        init(grid: Grid, words: [String], directions: [Direction], positions: [Int]) {
            self.grid = grid
            self.words = words
            self.directions = directions
            self.positions = positions
        }
    }

    init(words: [String], row: Int, column: Int) {
        self.words = words
        self.nRow = row
        self.nCol = column
    }

    static let placeholder: Character = "#"

    // We declare this to be a static func to be used by other classes too
    // We can also define this as an extension method of String
    static func wordKey(for startPos: Position, and endPos: Position) -> String {
        return "\(startPos.row):\(startPos.col):\(endPos.row):\(endPos.col)"
    }

    private func add(word: String, startPos: Position, endPos: Position) {
        wordsMap[WordGridGenerator.wordKey(for: startPos, and: endPos)] = word
    }

    private func assignWord(
        grid: Grid,
        word: String,
        direction: Direction,
        position: Int) -> (grid: Grid, lastPosition: Position)?  {
        var dupGrid = grid
        var row = position / nRow
        var col = position % nCol
        var idx = 0
        let chars = Array(word)
        let mStep = direction.getMovingSteps()
        var lastPos = Position(row: row, col: col)
        while true {
            if idx == chars.count {
                break
            }
            if row < 0 || row >= nRow || col < 0 || col >= nCol {
                return nil
            }
            lastPos = Position(row: row, col: col)
            if dupGrid[row][col] == WordGridGenerator.placeholder || dupGrid[row][col] == chars[idx] {
                dupGrid[row][col] = chars[idx]
                row += mStep.stepRow
                col += mStep.stepCol
                idx += 1
            } else {
                return nil
            }
        }
        return (grid: dupGrid, lastPosition: lastPos)
    }

    public func generate() -> Grid? {
        let empty = Grid(repeating: [Character](repeating: WordGridGenerator.placeholder, count: nCol), count: nRow)
        let positions = Array(0..<(nRow * nCol)).shuffled()
        let initialState = State(
            grid: empty,
            words: words,
            directions: directions,
            positions: positions.shuffled()
        )
        var states: [State] = [initialState]

        while true {
            guard let state = states.last else {
                return nil
            }
            var direction = state.directions.last
            state.directions = state.directions.dropLast()
            if direction == nil {
                state.positions = state.positions.dropLast()
                state.directions = Direction.allCases.shuffled()
                direction = state.directions.last!
            }
            let pos = state.positions.last
            if pos == nil {
                states = states.dropLast()
            } else {
                if state.words.isEmpty {
                    break
                }
                //We are sure that we have remaining words.
                let word = state.words.last!
                if let (grid, lastPos) = assignWord(grid: state.grid, word: word, direction: direction!, position: pos!) {
                    states.append(State(grid: grid, words: state.words.dropLast(), directions: Direction.allCases.shuffled(), positions: positions))
                    let posRow = pos! / nRow
                    let posCol = pos! % nCol
                    add(word: word, startPos: Position(row: posRow, col: posCol), endPos: lastPos)
                }
            }
        }
        return states.last!.grid.randomizePlaceHolders()
    }
}


