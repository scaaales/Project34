//
//  InitialViewController.swift
//  Project34
//
//  Created by scales on 08.10.2017.
//  Copyright © 2017 kpi. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select game mode"
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let button = sender as? UIButton {
            if let vc = segue.destination as? GameViewController {
                switch button.tag {
                case 0: vc.gameMode = .singleplayer // first button
                    print("singleplayer")
                case 1: vc.gameMode = .multiplayer // second button
                    print("multiplayer")
                default: vc.gameMode = .online // third button
                    print("online")
                }
            }
        }
    }
 

}
