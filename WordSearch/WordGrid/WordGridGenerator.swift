//
//  WordGrid.swift
//  WordSearch
//
//  Created by TonyNguyen on 5/9/19.
//  Copyright © 2019 Phuc Nguyen. All rights reserved.
//

import Foundation

typealias Grid = [[Character]]

/// Helper class to get a random alpha char
fileprivate class CharacterRandomizer {
    private var alphaSet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    func randomChar() -> Character {
        return alphaSet.randomElement()!
    }
}

// Alias for a 2d-array
// with a helper function to fill out placeholders with random chars.
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

    /// Private helper struct
    /// moving steps of a direction
    /// e.g. an up-left direction should
    /// move the row by -1
    /// and the col by -1
    private struct MovingStep {
        var stepRow: Int
        var stepCol: Int
    }

    private enum Direction: CaseIterable {
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

    /// Private class that holds a state of a grid
    private class State {
        /// Current grid
        var grid: Grid

        /// Remaining words.
        /// Should pick a word and attempt to assign to the grid
        var words: [String]

        /// Available directions to try
        var directions: [Direction]

        /// Available positions to try
        var positions: [Int]

        init(grid: Grid, words: [String], directions: [Direction], positions: [Int]) {
            self.grid = grid
            self.words = words
            self.directions = directions
            self.positions = positions
        }
    }

    var words: [String] = []
    // Key format: "startRow:startCol:endRow:endCol"
    // Value: the corresponding word
    // We will fill this map during grid generation
    // This is efficient to get back the word when user is swiping
    // Where we only know the start and end position of the line.
    var wordsMap: [String: String] = [:]
    var nRow: Int = 10
    var nCol: Int = 10

    private var directions = Direction.allCases

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

    /// Just a helper function to compute the key from positions
    /// and add the word to the words map.
    private func add(word: String, startPos: Position, endPos: Position) {
        wordsMap[WordGridGenerator.wordKey(for: startPos, and: endPos)] = word
    }

    /// Attempt to assign a word to a grid starting from a position,
    /// moving along a direction.
    /// If we could assign the word, return the last position of the last char
    /// To compute the words map.
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
                // Here the word has been assigned correctly.
                break
            }
            // The position is in the grid
            if row < 0 || row >= nRow || col < 0 || col >= nCol {
                return nil
            }
            // This line passes the check above, so the position is valid.
            lastPos = Position(row: row, col: col)

            // If the current char is a "#" or it equals to the char in the grid,
            // Then we are fine to move forward.
            if dupGrid[row][col] == WordGridGenerator.placeholder || dupGrid[row][col] == chars[idx] {
                // update the grid.
                dupGrid[row][col] = chars[idx]
                //move along the direction
                row += mStep.stepRow
                col += mStep.stepCol
                idx += 1
            } else {
                // if it fails at an any step, return nil
                return nil
            }
        }
        return (grid: dupGrid, lastPosition: lastPos)
    }

    /// Main method of the class.
    /// This generates a 2-d grid containing words in random positions and directions.
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
                // If we popped out every state, then there's no solution for such a grid.
                return nil
            }
            // Pop and try the last direction
            var direction = state.directions.last
            state.directions = state.directions.dropLast()
            if direction == nil {
                // No direction worked at the position
                // So we try next position
                state.positions = state.positions.dropLast()
                state.directions = Direction.allCases.shuffled()
                direction = state.directions.last!
            }
            let pos = state.positions.last
            if pos == nil {
                states = states.dropLast()
            } else {
                if state.words.isEmpty {
                    // If we assigned all words, grid is generated.
                    break
                }
                //We are sure that we have remaining words.
                let word = state.words.last!
                if let (grid, lastPos) = assignWord(grid: state.grid, word: word, direction: direction!, position: pos!) {
                    states.append(State(grid: grid, words: state.words.dropLast(), directions: Direction.allCases.shuffled(), positions: positions))
                    // Compute the words map
                    let posRow = pos! / nRow
                    let posCol = pos! % nCol
                    add(word: word, startPos: Position(row: posRow, col: posCol), endPos: lastPos)
                }
            }
        }
        return states.last!.grid.randomizePlaceHolders()
    }
}


