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

class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // チュートリアルが必要か
    var isTutorialGoing: Bool = true
    var tutorialIndex: Int = 1
    
    // ロケーションマネージャー定義
    let locationManager = CLLocationManager()
    
    // 現在の方角
    var currentDirection: Float = 0.0
    
    // Firestore
    var db: Firestore!
    
    // コンパスのView
    @IBOutlet var compassView: UIView!
    // Starボタン
    @IBOutlet var starButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animation
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
        
        // 更新を監視
        db.collection("posts").addSnapshotListener{ (snapshot, err) in
            guard let doc = snapshot else {
                print("Error fetching documents: \(err!)")
                return
            }
            doc.documentChanges.forEach{diff in
                // 更新が追加だった場合
                if diff.type == .added {
                    let data = diff.document.data()
                    self.addStarToCompassView(direction: (data["direction"] as? CGFloat)!, wish: (data["wish"] as? String)!)
                }
            }
        }
        
//        let listener = db.collection("cities").addSnapshotListener { querySnapshot, error in}
//        listener.remove()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 初回起動の場合はTutorialを開始
        // 初回起動判定
        if UserDefaults.standard.bool(forKey: "isNotFirstLaunch") {
            // 2回目以降
            print("Not first Launch!")
            self.view.alpha = 1
            // チュートリアル中であれば操作方法説明
            if isTutorialGoing {
                self.startTutorial()
            }
        } else {
            // 初回起動
            print("First Launch!")
            UserDefaults.standard.set(true, forKey: "isNotFirstLaunch")
            self.performSegue(withIdentifier: "toTutorialView", sender: nil)
        }
    }
    
    func startTutorial() {
        
        let screen = UIScreen.main.bounds.size
        
        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: screen.width, height: screen.height))
        self.view.addSubview(overlayView)
        
//        overlayView.translatesAutoresizingMaskIntoConstraints = false
//        overlayView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
//        overlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
//        overlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
//        overlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        
        // くり抜かれるLayer
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: screen.width, height: screen.height) // 画面全体を覆う
        overlayLayer.backgroundColor = UIColor(white: 0, alpha: 0.4).cgColor // くり抜かれた場所以外の色
        
        // くり抜く範囲Layer
        let maskLayer = CAShapeLayer()
        maskLayer.frame = overlayLayer.frame
        maskLayer.position = CGPoint(x: screen.width / 2, y: (screen.width / 2) + 110) // くり抜くPosition
        
        let center = CGPoint(x: screen.width / 2, y: screen.height / 2)
        // くり抜く円を描画
        let path1 = UIBezierPath(arcCenter: center, // 中心点
                                radius: screen.width / 2, // 半径
                                startAngle: 0, // 開始角
                                endAngle: CGFloat(Double.pi)*2, // 終了角
                                clockwise: true) // 時計回り
        let path2 = UIBezierPath(arcCenter: CGPoint(x: center.x, y: screen.height - (40 + self.view.safeAreaInsets.bottom)),
                                 radius: screen.width / 6,
                                 startAngle: 0,
                                 endAngle: CGFloat(Double.pi)*2,
                                 clockwise: true)
        
        let rect = UIBezierPath(rect: CGRect(x: 0, y: 0, width: screen.width, height: screen.height)) // くり抜く範囲を反転するために四角を追加
        
        
        if tutorialIndex == 1 {
            path1.append(rect)
            maskLayer.path = path1.cgPath
        } else if tutorialIndex == 2 {
            path2.append(rect)
            maskLayer.path = path2.cgPath
        }
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd // 四角と円が重なっている場所をくり抜く
        overlayLayer.mask = maskLayer
        
        print("overlayView: \(overlayView.bounds)")
        print("overlayLayer: \(overlayLayer.bounds)")
        print("maskLayer: \(maskLayer.bounds)")
        print("maskLayer: \(maskLayer.path)")
        // 親Viewに追加
        overlayView.layer.addSublayer(overlayLayer)
        
        
        // Label
        switch tutorialIndex {
        case 1:
            let descriptionOfCompassLabel = UILabel(frame: CGRect(x: 0, y: center.y + (screen.width / 3.5), width: screen.width, height: screen.width * 0.3))
            descriptionOfCompassLabel.text = "このコンパス上に、だれかの願いごとと共に\n流れ星の報告が表示されます。"
            descriptionOfCompassLabel.numberOfLines = 2
            descriptionOfCompassLabel.textAlignment = NSTextAlignment.center
            descriptionOfCompassLabel.textColor = UIColor.white
            overlayView.addSubview(descriptionOfCompassLabel)
        case 2:
            let descriptionOfStarButton = UILabel(frame: CGRect(x: center.x, y: screen.height - (80 + self.view.safeAreaInsets.bottom), width: screen.width, height: screen.width * 0.2))
            descriptionOfStarButton.textAlignment = NSTextAlignment.center
            descriptionOfStarButton.textColor = UIColor.white
            overlayView.addSubview(descriptionOfStarButton)
        default:
            break
        }
        
        
        // タップ検知
        let overlayViewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: overlayView, action: #selector(overlayViewTapped(_:)))
        overlayViewTapGesture.numberOfTouchesRequired = 1
        overlayViewTapGesture.delegate = self
        overlayView.addGestureRecognizer(overlayViewTapGesture)
        overlayView.isUserInteractionEnabled = true
    }
    
    // チュートリアルのoverlayViewがタップされると呼び出される
    @objc func overlayViewTapped(_ sender: UITapGestureRecognizer) {
        tutorialIndex += 1
    }
    
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
        // starImageViewを作成
        let starPosX: CGFloat = self.calcXfromDirection(direction)
        let starPosY: CGFloat = self.calcYfromDirection(direction)
        let starSize: CGFloat = self.compassView.bounds.size.width * 0.1 // compassView幅の10%
//                    let starImageView = UIImageView(frame: CGRect(x: starPosX - (starSize / 2), y: starPosY - (starSize / 2), width: starSize, height: starSize))
        let starImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        // starImageViewをcompassViewへ追加
        self.compassView.addSubview(starImageView)
        // starImageViewに画像を設定
        starImageView.image = UIImage(named: "star")
        // コードによるAutoLayout有効化
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        // Animation
        starImageView.alpha = 0
        UIImageView.animate(withDuration: 0.4,
                            delay: 0,
                            options: .curveEaseIn, animations: {
                                starImageView.alpha = 1
                            }, completion: nil)
        
        // starLabelViewを作成
        let starLabelView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        starLabelView.backgroundColor = UIColor(white: 1, alpha: 0.85) // 背景色
        starLabelView.translatesAutoresizingMaskIntoConstraints = false // コードによるAutoLayout有効化
        // starLabel作成
        let starLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        starLabelView.addSubview(starLabel) // starLabelViewに追加
        starLabel.text = wish // 願いごとを代入
        starLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 10) // フォント設定
        starLabel.textAlignment = .center // 中央揃え
        starLabel.textColor = UIColor.black // 文字色
        starLabel.backgroundColor = UIColor.white // 背景色
        starLabel.translatesAutoresizingMaskIntoConstraints = false // コードによるAutoLayout有効化
        // starLabelViewをcompassViewに追加（必ずAutoLayoutより先に追加する）
        self.compassView.addSubview(starLabelView)
        // Animation
        starLabelView.alpha = 0
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        starLabelView.alpha = 1
                       }, completion: nil)
        
        // AutoLayout
        NSLayoutConstraint.activate([
            // starImageView
            starImageView.leadingAnchor.constraint(equalTo: self.compassView.leadingAnchor, constant: starPosX - (starSize / 2)),
            starImageView.topAnchor.constraint(equalTo: self.compassView.topAnchor, constant: starPosY - (starSize / 2)),
            starImageView.widthAnchor.constraint(equalTo: self.compassView.widthAnchor, multiplier: 0.1), // compassViewの0.1倍
            starImageView.heightAnchor.constraint(equalTo: starImageView.widthAnchor), // widthと同じ
            
            // starLabelView
            starLabelView.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 10), // starImageViewの右端から10
            starLabelView.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor, constant: 0), // starImageViewと中央揃え（Y）
            
            // starLabel
//                        starLabel.leadingAnchor.constraint(equalTo: starLabelView.leadingAnchor, constant: 5),
//                        starLabel.topAnchor.constraint(equalTo: starLabelView.topAnchor, constant: 5),
//                        starLabel.trailingAnchor.constraint(equalTo: starLabelView.trailingAnchor, constant: 5),
//                        starLabel.bottomAnchor.constraint(equalTo: starLabelView.bottomAnchor, constant: 5),
        ])
    }
    
    
    @IBAction func star() {
//        print(currentDirection)
        
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
        
        // read all
//        db.collection("posts").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//            }
//        }
    }


}

