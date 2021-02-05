//
//  ViewController.swift
//  FlappyBird
//
//  Created by user on 2021/01/31.
//  Copyright © 2021 takeshi-2983. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SKViewに型を変更
        let skView = self.view as! SKView
        
        //FPSを表示する
        skView.showsFPS = true
        
        //ノードの数を表示
        skView.showsNodeCount = true
        
        //ビューと同じサイズでシーンを作成する
        let scene = GameScene(size: skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
    }
    
    //ステータスバーを消す
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

}

