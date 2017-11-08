//
//  SocketIOManager.swift
//  Project34
//
//  Created by scales on 17.10.2017.
//  Copyright © 2017 kpi. All rights reserved.
//

import UIKit
import SocketIO

protocol GameDelegate {
    func gameStart(colorString: String)
    func firstPlayerConnect()
    func getMove(column: Int)
}

class SocketIOManager: NSObject {

    static let sharedInstance = SocketIOManager()
    private var numberOfPlayers = 0 {
        didSet {
            switch numberOfPlayers {
            case 1: delegate?.firstPlayerConnect()
            case 2: getColor()
            default: break
            }
        }
    }
    
    private let socket = SocketIOClient(socketURL: URL(string: "http://192.168.1.123:3000")!)
    
    var delegate: GameDelegate?
    
    var isConnected: Bool {
        return socket.status == .connected
    }
    
    private override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
        
        socket.on("numberOfUsers") { (dataArray, ack) in
            self.numberOfPlayers = dataArray[0] as! Int
        }
        
        socket.on("color") { (dataArray, ack) in
            let colorString = dataArray[0] as! String
            self.delegate?.gameStart(colorString: colorString)
        }
        
        socket.on("newMove") { (dataArray, ack) in
            let column = dataArray[0] as! Int
            
            self.delegate?.getMove(column: column)
        }
        
    }
    
    func connectUser() {
        socket.emit("connect")
    }
    
    func getNumberOfPlayers() -> Int {
        return self.numberOfPlayers
    }
    
    func connectionStatusChanged(toConnected connectedHadler: @escaping () -> (), toNotConnected notConnectedHadler: @escaping () -> ()) {
        socket.on(clientEvent: .statusChange) { (dataArray, ack) in
            switch (dataArray[0] as! SocketIOClientStatus) {
            case .connected: connectedHadler()
                print("status changed to connected")
            default: notConnectedHadler()
                print("status changed to not connected")
            }
        }
    }
    
    func getColor() {
        socket.emit("getColor")
    }
    
    func sendMove(column: Int) {
        socket.emit("move", column)
    }
    
    func getMove() {
            socket.on("newMove") { (dataArray, ack) in
                let column = dataArray[0] as! Int
                self.delegate?.getMove(column: column)
            }
    }
    
    func exitGame() {
        socket.emit("exit")
    }
    
    func closeConnection() {
        socket.disconnect()
    }
}
