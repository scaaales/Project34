//
//  ViewController.swift
//  Project34
//
//  Created by scales on 04.10.2017.
//  Copyright © 2017 kpi. All rights reserved.
//

import UIKit
import GameplayKit

enum GameMode {
    case singleplayer
    case multiplayer
    case online
}

class GameViewController: UIViewController {

    @IBOutlet var columnButtons: [UIButton]!
    
    var placedChips = [[UIView]]()
    var board: Board!
    var gameMode: GameMode = .singleplayer
    
    var strategist: GKMinmaxStrategist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }
        
        columnButtons = columnButtons.sorted { $0.tag < $1.tag }
        
        switch gameMode {
        case .singleplayer: setupAI()
        case .multiplayer: break
        default: let ac = UIAlertController(title: "In next version!", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        present(ac, animated: true)
        }
                
        resetBoard()
    }
    
    func resetBoard() {
        board = Board()
        strategist?.gameModel = board
        
        updateUI()
        
        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                chip.removeFromSuperview()
            }
            
            placedChips[i].removeAll(keepingCapacity: true)
        }
    }
    
    func setupAI() {
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 7
        strategist.randomSource = nil
    }
    
    func updateUI() {
        title = "\(board.currentPlayer.name)'s Turn"
        
        if gameMode == .singleplayer && board.currentPlayer.chip == .black {
            startAIMove()
        }
    }
    
    func columnForIAMove() -> Int? {
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.column
        }
        
        return nil
    }
    
    func makeAIMove(inColumn column: Int) {
        columnButtons.forEach { $0.isEnabled = true }
        navigationItem.rightBarButtonItem = nil
        
        if let row = board.nextEmptySlot(inColumn: column) {
            board.add(chip: board.currentPlayer.chip, inColumn: column)
            addChip(inColumn: column, andRow: row, color: board.currentPlayer.color)
            
            continueGame()
        }
    }
    
    func startAIMove() {
        columnButtons.forEach { $0.isEnabled = false }
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let column = self.columnForIAMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = aiTimeCeiling - delta
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.makeAIMove(inColumn: column)
            }
        }
    }
    
    func continueGame() {
        var gameOverTitle: String? = nil
        
        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) Wins!"
        } else if board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default, handler: { [unowned self] action in
                self.resetBoard()
            })
            
            alert.addAction(alertAction)
            present(alert, animated: true)
            
            return
        }
        
        board.currentPlayer = board.currentPlayer.opponent
        updateUI()
    }

    func addChip(inColumn column: Int, andRow row: Int, color: UIColor) {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        if (placedChips[column].count < row + 1) {
            let newChip = UIView()
            newChip.frame = rect
            newChip.isUserInteractionEnabled = false
            newChip.backgroundColor = color
            newChip.layer.cornerRadius = size / 2
            newChip.center = positionForChip(inColumn: column, andRow: row)
            newChip.transform = CGAffineTransform(translationX: 0, y: -800)
            view.addSubview(newChip)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                newChip.transform = CGAffineTransform.identity
            })
            
            placedChips[column].append(newChip)
        }
    }
    
    func positionForChip(inColumn column: Int, andRow row: Int) -> CGPoint {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        
        let xOffset = button.frame.midX
        var yOffset = view.frame.maxY - size / 2
        yOffset -= size * CGFloat(row)
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        
        if let row = board.nextEmptySlot(inColumn: column) {
            board.add(chip: board.currentPlayer.chip, inColumn: column)
            addChip(inColumn: column, andRow: row, color: board.currentPlayer.color)
            continueGame()
        }
        
    }
    

}

