//
//  GameScene.swift
//  FlappyBird
//
//  Created by user on 2021/01/31.
//  Copyright © 2021 takeshi-2983. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var itemNode:SKNode!
    
    //効果音を定義
    let koukaon = Bundle.main.bundleURL.appendingPathComponent("可愛い足音.mp3")
    var koukaonPlayer = AVAudioPlayer()
    let koukaon1 = Bundle.main.bundleURL.appendingPathComponent("バタンと倒れる.mp3")
    var koukaonPlayer1 = AVAudioPlayer()
    let koukaon2 = Bundle.main.bundleURL.appendingPathComponent("小さな冒険.mp3")
    var koukaonPlayer2 = AVAudioPlayer()
    let koukaon3 = Bundle.main.bundleURL.appendingPathComponent("アイテム取得音.mp3")
    var koukaonPlayer3 = AVAudioPlayer()
    // 衝突判定カテゴリー ↓追加
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemCategory: UInt32 = 1 << 4
    let ItemscoreCategory: UInt32 = 1 << 5
    
    // スコア用
    var score = 0  // ←追加
    var scoreLabelNode:SKLabelNode!    // ←追加
    var bestScoreLabelNode:SKLabelNode!    // ←追加
    let userDefaults:UserDefaults = UserDefaults.standard    // 追加
    
    //Itemスコア用
    var Item = 0
    var ItemLabelNode:SKLabelNode!
    var bestItemLabelNode:SKLabelNode!
    
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self // ←追加
        
        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //アイテム用のノード
        itemNode = SKNode()
        scrollNode.addChild(itemNode)
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        
        setupScoreLabel()   // 追加
        setupItemLabel()
        
        do {
            koukaonPlayer2 = try AVAudioPlayer(contentsOf: koukaon2, fileTypeHint: nil)
            koukaonPlayer2.numberOfLoops = -1
            koukaonPlayer2.play()
        } catch {
            print("エラー")
        }
    }
    
    func setupGround() {
        
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        //速度優先
        groundTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール→元の位置→左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())   // ←追加
            
            //衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory    // ←追加

            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false   // ←追加
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupCloud() {
        //地面の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        //速度優先
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 5)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール→元の位置→左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100  //一番うしろになるようにする
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    
    func setupWall() {
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        //速度優先
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //鳥が通り抜ける隙間の長さを鳥のサイズの3倍に設定
        let slit_length = birdSize.height * 3
        
        //隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3

        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2

        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 // 雲より手前、地面より奥

            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = under_wall_lowest_y + random_y

            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            
            // スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            under.physicsBody?.categoryBitMask = self.wallCategory

            // 衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false    // ←追加
            

            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            
            // スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
            upper.physicsBody?.categoryBitMask = self.wallCategory
            

            // 衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false    // ←追加
            
            wall.addChild(upper)
            
            // スコアアップ用のノード --- ここから ---
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

            wall.addChild(scoreNode)
            // --- ここまで追加 ---

            wall.run(wallAnimation)

            self.wallNode.addChild(wall)
            })

        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)

        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

        wallNode.run(repeatForeverAnimation)
        }
    
    func setupItem() {
        //アイテムの画像を読み込む
        let ItemTexture = SKTexture(imageNamed: "apple-3")
        //速度優先
        ItemTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + ItemTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration: 3)
        
        //自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成
        let ItemAnimation = SKAction.sequence([moveItem, removeItem])
        
        //Itemの画像サイズを取得
        let itemSize = SKTexture(imageNamed: "apple-2").size()
        
        //上下の振れ幅をItemのサイズの15倍とする
        let random_y_range = itemSize.height * 15

        // Itemを生成するアクションを作成
        let createItemAnimation = SKAction.run({
            // Item関連のノードを乗せるノードを作成
            let Item = SKNode()
            Item.position = CGPoint(x: self.frame.size.width, y: 0)
            Item.zPosition = -60 // 雲より手前、壁より手前？　地面より奥

            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            
            let groundsize = SKTexture(imageNamed: "ground").size()
            let ground_y_range = groundsize.height
          

            // Itemを作成
            let Item_1 = SKSpriteNode(texture: ItemTexture)
            Item_1.position = CGPoint(x: 0, y: random_y + ItemTexture.size().width + ground_y_range)
            
            
            // スプライトに物理演算を設定する
            //Item_1.physicsBody = SKPhysicsBody(rectangleOf: ItemTexture.size())    // ←追加
            //Item_1.physicsBody?.categoryBitMask = self.itemCategory

            // 衝突の時に動かないように設定する
            Item_1.physicsBody?.isDynamic = false    // ←追加
            

            Item.addChild(Item_1)
            

            
            // スコアアップ用のノード --- ここから ---
            let itemscoreNode = SKNode()
            itemscoreNode.position = Item_1.position
            itemscoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: Item_1.size.width, height: Item_1.size.height))
            itemscoreNode.physicsBody?.isDynamic = false
            itemscoreNode.physicsBody?.categoryBitMask = self.ItemscoreCategory
            itemscoreNode.physicsBody?.contactTestBitMask = self.birdCategory

            Item.addChild(itemscoreNode)
            // --- ここまで追加 ---

            Item.run(ItemAnimation)

            self.itemNode.addChild(Item)
            })

        // 次のItem作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 6)

        // Itemを作成->時間待ち->Itemを作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))

        itemNode.run(repeatForeverAnimation)
        }
    

    
    func setupBird() {
        
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear

        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)

        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false    // ←追加
        
        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory    // ←追加
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory    // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory    // ←追加

        // アニメーションを設定
        bird.run(flap)

        // スプライトを追加する
        addChild(bird)
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 { // 追加
        
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero

            // 鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            
            // タッチ時の効果音
            do {
                koukaonPlayer = try AVAudioPlayer(contentsOf: koukaon, fileTypeHint: nil)
                koukaonPlayer.play()
            } catch {
                print("エラー")
            }
                
            } else if bird.speed == 0 { // --- ここから ---
                restart()
            } // --- ここまで追加 ---
    }
    
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            do {
                koukaonPlayer1 = try AVAudioPlayer(contentsOf: koukaon1, fileTypeHint: nil)
                koukaonPlayer1.play()
            } catch {
                print("エラー")
            }
            return
        }

        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"    // ←追加

            
            // ベストスコア更新か確認する --- ここから ---
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"    // ←追加
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            } else if (contact.bodyA.categoryBitMask & ItemscoreCategory) == ItemscoreCategory || (contact.bodyB.categoryBitMask & ItemscoreCategory) == ItemscoreCategory {
                    // Itemと衝突した
                    print("ItemScoreUp")
                    Item += 1
                    ItemLabelNode.text = "Item:\(Item)"    // ←追加
                
                //アイテムを取り除くアクション
                let Remove = SKAction.removeFromParent()
                itemNode.run(Remove)
                
                //再度アイテムを出現させる
                itemNode = SKNode()
                scrollNode.addChild(itemNode)
                setupItem()
                
                
                //アイテム取得時の効果音
                do {
                    koukaonPlayer = try AVAudioPlayer(contentsOf: koukaon3, fileTypeHint: nil)
                    koukaonPlayer.play()
                } catch {
                    print("エラー")
                }
                
                
                    
                    // ベストスコア更新か確認する --- ここから ---
                    var bestItem = userDefaults.integer(forKey: "BESTItem")
                    if Item > bestItem {
                        bestItem = Item
                        bestItemLabelNode.text = "Best Item:\(bestItem)"    // ←追加
                        userDefaults.set(bestItem, forKey: "BESTItem")
                        userDefaults.synchronize()
                    }
        // --- ここまで追加---
            
        } else {
            // 壁か地面と衝突した
            print("GameOver")

            // スクロールを停止させる
            scrollNode.speed = 0

            bird.physicsBody?.collisionBitMask = groundCategory

            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        score = 0
        scoreLabelNode.text = "Score:\(score)"    // ←追加
        
        Item = 0
        
        ItemLabelNode.text = "Item:\(Item)"

        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0

        wallNode.removeAllChildren()

        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)

        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left

        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    func setupItemLabel() {
        Item = 0
        ItemLabelNode = SKLabelNode()
        ItemLabelNode.fontColor = UIColor.black
        ItemLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        ItemLabelNode.zPosition = 110 // 一番手前に表示する
        ItemLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        ItemLabelNode.text = "Item:\(Item)"
        self.addChild(ItemLabelNode)

        bestItemLabelNode = SKLabelNode()
        bestItemLabelNode.fontColor = UIColor.black
        bestItemLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 150)
        bestItemLabelNode.zPosition = 110 // 一番手前に表示する
        bestItemLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left

        let bestItem = userDefaults.integer(forKey: "BESTItem")
        bestItemLabelNode.text = "Best Item:\(bestItem)"
        self.addChild(bestItemLabelNode)
    }
    
    }


