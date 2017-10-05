//
//  Move.swift
//  Project34
//
//  Created by scales on 05.10.2017.
//  Copyright © 2017 kpi. All rights reserved.
//

import UIKit
import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var column: Int
    
    init(column: Int) {
        self.column = column
    }
}
