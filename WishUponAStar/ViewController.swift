//
//  ViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/02/22.
//

import UIKit
import CoreLocation

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // AppDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // チュートリアル
    var isTutorialGoing: Bool = false // 操作チュートリアルが必要か
    var tutorialIndex: Int = 1 // チュートリアルの進捗
    let screen = UIScreen.main.bounds.size // スクリーンサイズ
    let overlayView = UIView() // チュートリアルを表示するView
    let maskLayer = CAShapeLayer() // くり抜く範囲Layer
    
    // ロケーションマネージャー定義
    let locationManager = CLLocationManager()
    
    // 現在の方角
    var currentDirection: Float = 0.0
    
    // Firestore
    var db: Firestore!
    
    // compassView上のstarの数
    var numOfStars: Int = 0
    
    // コンパスのView
    @IBOutlet var compassView: UIView!
    // Starボタン
    @IBOutlet var starButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animation準備
        self.view.alpha = 0
        
        // ロケーションマネージャーのdelegate指定
        locationManager.delegate = self
        // 方角の更新間隔
        locationManager.headingFilter = 0.1
        // 方角の取得開始
        locationManager.startUpdatingHeading()
        
        
        //Firestore
        let firestoreSettings = FirestoreSettings()
        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 初回起動の場合はTutorialを開始
        // 初回起動判定
        if UserDefaults.standard.bool(forKey: "isNotFirstLaunch") {
            // 2回目以降
            print("Not first Launch!")
            self.view.alpha = 1
            // チュートリアル中であれば操作方法説明
            print(isTutorialGoing)
            if isTutorialGoing {
                self.startTutorial()
                isTutorialGoing = false // チュートリアル終了
            }
            // 更新を監視
            appDelegate.listener = db.collection("posts").addSnapshotListener { (snapshot, err) in
                guard let doc = snapshot else {
                    print("Error fetching documents: \(err!)")
                    return
                }
                doc.documentChanges.forEach { diff in
                    // 更新が追加だった場合
                    if diff.type == .added {
                        let data = diff.document.data()
                        self.numOfStars += 1
                        self.addStarToCompassView(direction: (data["direction"] as? CGFloat)!, wish: (data["wish"] as? String)!)
                    }
                }
            }
        } else {
            // 初回起動
            print("First Launch!")
            UserDefaults.standard.set(true, forKey: "isNotFirstLaunch") // 次回以降は初回起動でないことを保存
            self.performSegue(withIdentifier: "toTutorialView", sender: nil) // チュートリアル開始
        }
    }
    
    // AutoLayout完了
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        print("viewDidLayoutSubviews")
//
//        for starLabel in self.getStarLabelsFromCompassView() {
//            starLabel.layer.setAnchorPoint(newAnchorPoint: CGPoint(x: 0, y: 0), forView: starLabel)
//            print(starLabel.bounds)
//        }
//    }
    
    // 方角が変わると呼び出される
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // compassViewを回転
        compassView.transform = CGAffineTransform(rotationAngle: CGFloat(-newHeading.magneticHeading) * CGFloat.pi / 180)
        // compassViewの子Viewの水平を維持
        for view in compassView.subviews {
            view.transform = CGAffineTransform(rotationAngle: -CGFloat(-newHeading.magneticHeading) * CGFloat.pi / 180)
        }
        // 現在の方角を更新
        currentDirection = Float(newHeading.magneticHeading)
    }
    
    
    // starボタン
    @IBAction func star() {
        // post to firestore
        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data: [
            "direction": currentDirection,
            "wish": UserDefaults.standard.string(forKey: "wish") ?? "いいことありますように",
            "createdAt": FieldValue.serverTimestamp()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

}



// MARK: - Add star to compassView
extension ViewController {
    
    // 60秒で削除する
    func startTimerWithTag(tag: Int) {
        // 60秒のタイマーを開始
        Timer.scheduledTimer(timeInterval: 60,
                                         target: self,
                                         selector: #selector(self.stopTimer(_:)),
                                         userInfo: tag,
                                         repeats: false)
    }
    // 時間経過でタイマーストップ
    @objc func stopTimer(_ timer: Timer) {
        let tag = timer.userInfo as! Int
        // tagで該当する３つのViewを削除
        for _ in 1...3 {
            let target = self.compassView.viewWithTag(tag)!
            print(target.alpha)
//            UIView.animate(withDuration: 1, animations: { target.alpha = 0 }, completion: { _ in
//                target.removeFromSuperview()
//            })
            target.removeFromSuperview()
        }
        timer.invalidate()
        print("timer stopped")
    }
    
    // 方角から位置Xを計算する
    func calcXfromDirection(_ direction: CGFloat) -> CGFloat {
        // compassViewの中心
        let radius = self.compassView.bounds.size.width / 2
        
        // 原点からの距離を、角度と半径から計算
        return (cos(degreeToRadian(direction-90)) * radius) + radius
    }
    // 方角から位置Yを計算する
    func calcYfromDirection(_ direction: CGFloat) -> CGFloat {
        let radius = self.compassView.bounds.size.width / 2
        
        // 原点からの距離を、角度と半径から計算
        return sin(degreeToRadian(direction-90)) * radius + radius
    }
    
    // compassViewにStarを追加
    func addStarToCompassView(direction: CGFloat, wish: String) {
        // 流れ星の尾のアニメーション
        let shootingAnimationView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        shootingAnimationView.translatesAutoresizingMaskIntoConstraints = false // コードによるAutoLayoutを有効化
        shootingAnimationView.backgroundColor = UIColor.clear // 背景色
        shootingAnimationView.tag = numOfStars // tagを設定
        self.compassView.addSubview(shootingAnimationView) //　compassViewに追加
        // 流れ星の尾のLayer
        let shootingAnimationLayer = CAShapeLayer()
        shootingAnimationView.layer.addSublayer(shootingAnimationLayer) // viewに追加
        // 流れ星の尾のパス
        let shootingPath = UIBezierPath()
        shootingPath.move(to: CGPoint(x: self.compassView.frame.width * 0.4, y: 0)) // 起点（右上）
        shootingPath.addLine(to: CGPoint(x: 0, y: self.compassView.frame.width * 0.2 * 0.5)) // 終点（左下）
        shootingPath.close() // 描画を終了
        shootingAnimationLayer.lineWidth = 2.0 // 線の太さ
        shootingAnimationLayer.lineJoin = .round // 線を丸角に
        shootingAnimationLayer.strokeColor = UIColor.white.cgColor // 線の色
        shootingAnimationLayer.path = shootingPath.cgPath // Layerに適用
        // Animation
        // 描画アニメーション
        let shootingAnimation = CABasicAnimation(keyPath: "strokeEnd")
        shootingAnimation.fromValue = 0.0 // 開始値
        shootingAnimation.toValue = 1.0 // 終了値
        shootingAnimation.duration = 1 // 時間
        shootingAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut) // イーズアウト
        shootingAnimationLayer.add(shootingAnimation, forKey: nil) // アニメーション追加
        // 消滅アニメーション
        UIView.animate(withDuration: 0.3,
                       delay: 0.2,
                       options: .curveLinear,
                       animations: {
                        shootingAnimationView.alpha = 0
                       },
                       completion: { _ in 
//                        self.compassView.subviews[self.compassView.subviews.endIndex - 1].removeFromSuperview()
                       })
        
        // starImageViewを作成
        let starPosX: CGFloat = self.calcXfromDirection(direction)
        let starPosY: CGFloat = self.calcYfromDirection(direction)
        let starSize: CGFloat = self.compassView.bounds.size.width * 0.1 // compassView幅の10%
//                    let starImageView = UIImageView(frame: CGRect(x: starPosX - (starSize / 2), y: starPosY - (starSize / 2), width: starSize, height: starSize))
        let starImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        starImageView.tag = numOfStars // tagを設定
        self.compassView.addSubview(starImageView) // starImageViewをcompassViewへ追加
        starImageView.image = UIImage(named: "star") // starImageViewをcompassViewへ追加
        starImageView.translatesAutoresizingMaskIntoConstraints = false // コードによるAutoLayout有効化
        // Animation
        starImageView.alpha = 0
        UIImageView.animate(withDuration: 1,
                            delay: 1, // shootingAnimationを待つ
                            options: .curveEaseIn, animations: {
                                starImageView.alpha = 1
                            }, completion: nil)
        // 60秒後に削除
        startTimerWithTag(tag: numOfStars)
        
        // starLabelViewを作成
        let starLabelView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        starLabelView.tag = numOfStars // tagを設定
        starLabelView.backgroundColor = UIColor.white // 背景色
        starLabelView.translatesAutoresizingMaskIntoConstraints = false // コードによるAutoLayout有効化
        // starLabel作成
        let starLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        starLabelView.addSubview(starLabel) // starLabelViewに追加
        starLabel.text = wish // 願いごとを代入
        starLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 10) // フォント設定
        starLabel.textAlignment = .center // 中央揃え
        starLabel.paddingLeft = 7
        starLabel.paddingTop = 5
        starLabel.paddingRight = 7
        starLabel.paddingBottom = 5
        starLabel.textColor = UIColor.black // 文字色
        starLabel.backgroundColor = UIColor.white // 背景色
//        starLabel.sizeToFit() // frameが確定する
//        starLabel.layer.setAnchorPoint(newAnchorPoint: CGPoint(x: 0, y: 0), forView: starLabel)
        starLabel.translatesAutoresizingMaskIntoConstraints = false // コードによるAutoLayout有効化
        // starLabelViewをcompassViewに追加（必ずAutoLayoutより先に追加する）
        self.compassView.addSubview(starLabelView)
//        self.compassView.addSubview(starLabel)
        // Animation
        starLabelView.alpha = 0
        UIView.animate(withDuration: 1,
                       delay: 1, // shootingAnimationを待つ
                       options: .curveEaseIn,
                       animations: {
                        starLabelView.alpha = 1
                       }, completion: nil)
        
        // AutoLayout
        NSLayoutConstraint.activate([
            // shootingAnimationView
            shootingAnimationView.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 5),
            shootingAnimationView.bottomAnchor.constraint(equalTo: starImageView.topAnchor, constant: starSize / 3),
            shootingAnimationView.widthAnchor.constraint(equalTo: self.compassView.widthAnchor, multiplier: 0.2),
            shootingAnimationView.heightAnchor.constraint(equalTo: self.compassView.widthAnchor, multiplier: 0.1),
            
            // starImageView
            starImageView.leadingAnchor.constraint(equalTo: self.compassView.leadingAnchor, constant: starPosX - (starSize / 2)),
            starImageView.topAnchor.constraint(equalTo: self.compassView.topAnchor, constant: starPosY - (starSize / 2)),
            starImageView.widthAnchor.constraint(equalTo: self.compassView.widthAnchor, multiplier: 0.1), // compassViewの0.1倍
            starImageView.heightAnchor.constraint(equalTo: starImageView.widthAnchor), // widthと同じ
            
            // starLabelView
            starLabelView.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 10), // starImageViewの右端から10
            starLabelView.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor, constant: 0), // starImageViewと中央揃え（Y）
            
            // starLabel
//            starLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 10), // starImageViewの右端から10
//            starLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor, constant: 0), // starImageViewと中央揃え（Y）
        ])
    }
    
    // compassViewのSubViewsから型がPaddingLabelのものだけをstarLabelsとして抽出
//    func getStarLabelsFromCompassView() -> [PaddingLabel] {
//        var starLabels = [PaddingLabel]()
//        for subView in compassView.subviews {
//            if type(of: subView) == PaddingLabel.self {
//                starLabels.append(subView as! PaddingLabel)
//            }
//        }
//        return starLabels
//    }
}




// MARK: - Tutorial
extension ViewController: UIGestureRecognizerDelegate {
    
    func startTutorial() {
        // overlayViewのframeを設定
        overlayView.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
        // overlayViewを親Viewに追加
        self.view.addSubview(overlayView)
        
        // くり抜かれるLayer
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height) // 画面全体を覆う
        overlayLayer.backgroundColor = UIColor(white: 0, alpha: 0.4).cgColor // くり抜かれた場所以外の色
        
        // くり抜く範囲Layer
        maskLayer.frame = overlayLayer.frame
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd // 四角と円が重なっている場所をくり抜く
        overlayLayer.mask = maskLayer // マスクを設定
        
        // 親Viewに追加
        overlayView.layer.addSublayer(overlayLayer)
        
        // pathとLabel設定＆表示
        self.nextTutorial()
        
        // タップ検知
        let overlayViewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapped(_:)))
        overlayView.addGestureRecognizer(overlayViewTapGesture)
    }
    
    // チュートリアルのoverlayViewがタップされると呼び出される
    @objc func overlayViewTapped(_ sender: UITapGestureRecognizer) {
        tutorialIndex += 1
        self.nextTutorial()
    }
    
    // チュートリアル処理
    func nextTutorial() {
        let center = CGPoint(x: screen.width / 2, y: screen.height / 2)
        
        // くり抜く円を描画
        // path1
        let compassViewCenter = CGPoint(x: center.x, y: (self.view.safeAreaInsets.top + 110) + (screen.width / 2))
        let compassViewRadius = screen.width / 2
        let path1 = UIBezierPath(arcCenter: compassViewCenter, // 中心点（AutoLayout調整分＋半径）
                                radius: compassViewRadius, // 半径
                                startAngle: 0, // 開始角
                                endAngle: CGFloat(Double.pi)*2, // 終了角
                                clockwise: true) // 時計回り
        // path2
        let starButtonCenter = CGPoint(x: center.x, y: screen.height - ((self.view.safeAreaInsets.bottom + 40) + ((screen.width * 0.25) / 2)))
        let starButtonRadius = screen.width * 0.25 / 2
        let path2 = UIBezierPath(arcCenter: starButtonCenter,
                                 radius: starButtonRadius + 10,
                                 startAngle: 0,
                                 endAngle: CGFloat(Double.pi)*2,
                                 clockwise: true)
        // path3
        let wishButtonRadius = screen.width * 0.18 / 2
        let wishButtonCenter = CGPoint(x: starButtonCenter.x - starButtonRadius - 40 - wishButtonRadius, y: starButtonCenter.y)
        let path3 = UIBezierPath(arcCenter: wishButtonCenter,
                                 radius: wishButtonRadius + 10,
                                 startAngle: 0,
                                 endAngle: CGFloat(Double.pi)*2,
                                 clockwise: true)
        
        // くり抜く範囲を反転するための四角
        let rect = UIBezierPath(rect: CGRect(x: 0, y: 0, width: screen.width, height: screen.height))
        
        // チュートリアルを切り替え
        switch tutorialIndex {
        case 1:
            // path
            path1.append(rect)
            maskLayer.path = path1.cgPath
            // Label
            let descriptionOfCompassLabel = UILabel(frame: CGRect(x: 0, y: compassViewCenter.y + compassViewRadius * 0.9, width: screen.width, height: screen.width * 0.3))
            descriptionOfCompassLabel.text = "このコンパス上に、だれかの願いごとと共に\n流れ星の報告が表示されます。"
            descriptionOfCompassLabel.numberOfLines = 2
            descriptionOfCompassLabel.textAlignment = NSTextAlignment.center
            descriptionOfCompassLabel.textColor = UIColor.white
            overlayView.addSubview(descriptionOfCompassLabel)
        case 2:
            // path
            path2.append(rect)
            maskLayer.path = path2.cgPath
            // Label
            overlayView.subviews[0].removeFromSuperview() // 前回のLabelを削除
            let descriptionOfStarButton = UILabel(frame: CGRect(x: 0, y: starButtonCenter.y - starButtonRadius * 3, width: screen.width, height: screen.width * 0.3))
            descriptionOfStarButton.text = "流れ星を見つけたらその方向を向いてタップ！\nみんなに共有できます。"
            descriptionOfStarButton.numberOfLines = 2
            descriptionOfStarButton.textAlignment = NSTextAlignment.center
            descriptionOfStarButton.textColor = UIColor.white
            overlayView.addSubview(descriptionOfStarButton)
        case 3:
            // path
            path3.append(rect)
            maskLayer.path = path3.cgPath
            // Label
            overlayView.subviews[0].removeFromSuperview()
            let descriptionOfWishButton = UILabel(frame: CGRect(x: 20, y: starButtonCenter.y - starButtonRadius * 2.5, width: screen.width, height: screen.width * 0.3))
            descriptionOfWishButton.text = "ここでお願いごとを設定できるよ！"
            descriptionOfWishButton.textAlignment = NSTextAlignment.left
            descriptionOfWishButton.textColor = UIColor.white
            overlayView.addSubview(descriptionOfWishButton)
        case 4:
            // チュートリアルを終了
            self.view.subviews[self.view.subviews.endIndex - 1].removeFromSuperview()
        default:
            break
        }
    }
}

