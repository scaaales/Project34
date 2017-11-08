//
//  Board.swift
//  Project34
//
//  Created by scales on 04.10.2017.
//  Copyright © 2017 kpi. All rights reserved.
//

import UIKit
import GameplayKit

enum ChipColor: Int {
    case none = 0
    case red
    case black
    
    init(colorString: String) {
        switch colorString.lowercased() {
        case "red": self = .red
        case "black": self = .black
        default: self = .none
        }
    }
}

class Board: NSObject, GKGameModel {
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            slots = board.slots
            currentPlayer = board.currentPlayer
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
                return nil
            }
            
            var moves = [Move]()
            
            for column in 0 ..< Board.width {
                if canMove(inColumn: column) {
                    moves.append(Move(column: column))
                }
            }
            
            return moves
        }
        
        return nil
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? Move {
            add(chip: currentPlayer.chip, inColumn: move.column)
            currentPlayer = currentPlayer.opponent
        }
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) {
                return 1000
            } else if isWin(for: playerObject.opponent) {
                return -1000
            }
        }
        
        return 0
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    static let width = 7
    static let height = 6
    
    var slots = [ChipColor]()
    
    var currentPlayer: Player
    
    override convenience init() {
        self.init(withPlayerColor: "red")
    }
    
    init(withPlayerColor color: String) {
        currentPlayer = Player(chip: .init(colorString: color))
        
        for _ in 0 ..< Board.width * Board.height {
            slots.append(.none)
        }
        
        super.init()
    }
    
    
    
    func isFull() -> Bool {
        for column in 0 ..< Board.width {
            if canMove(inColumn: column) {
                return false
            }
        }
        
        return true
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let chip = (player as! Player).chip
        
        for row in 0 ..< Board.height {
            for col in 0 ..< Board.width {
                if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 0) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 0, moveY: 1) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 1) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: -1) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func squaresMatch(initialChip: ChipColor, row: Int, col: Int, moveX: Int, moveY: Int) -> Bool {
        if row + (moveY * 3) < 0 { return false }
        if row + (moveY * 3) >= Board.height { return false }
        if col + (moveX * 3) < 0 { return false }
        if col + (moveX * 3) >= Board.width { return false }
        
        if chip(inColumn: col, andRow: row) != initialChip { return false }
        if chip(inColumn: col + moveX, andRow: row + moveY) != initialChip { return false }
        if chip(inColumn: col + (moveX * 2), andRow: row + (moveY * 2)) != initialChip { return false }
        if chip(inColumn: col + (moveX * 3), andRow: row + (moveY * 3)) != initialChip { return false }
        
        return true
    }
    
    func chip(inColumn column: Int, andRow row: Int) -> ChipColor {
        return slots[row + column * Board.height]
    }
    
    func set(chip: ChipColor, inColumn column: Int, andRow row: Int) {
        slots[row + column * Board.height] = chip
    }
    
    func nextEmptySlot(inColumn column: Int) -> Int? {
        for row in 0 ..< Board.height {
            if chip(inColumn: column, andRow: row) == .none {
                return row
            }
        }
        
        return nil
    }
    
    func canMove(inColumn column: Int) -> Bool {
        return nextEmptySlot(inColumn: column) != nil
    }

    func add(chip: ChipColor, inColumn column: Int) {
        if let row = nextEmptySlot(inColumn: column) {
            set(chip: chip, inColumn: column, andRow: row)
        }
    }
    
}
