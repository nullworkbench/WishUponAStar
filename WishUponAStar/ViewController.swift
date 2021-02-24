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
                    print("new: \(data)")
                    
                    // PostViewをコンパスに追加
//                    let posX: CGFloat = self.calcXfromDirection((data["direction"] as? CGFloat)!)
//                    let posY: CGFloat = self.calcYfromDirection((data["direction"] as? CGFloat)!)
//                    let width: CGFloat = self.compassView.bounds.size.width * 0.5 // compassView幅の50%
//                    let height: CGFloat = width * 0.2 // width:height = 10:2
//                    let postView: PostView = PostView(frame: CGRect(x: posX - (width * 0.1), y: posY - (height / 2), width: width, height: height)) // サイズと位置を指定
//
//                    postView.wishLabel.text = data["wish"] as? String // 願いごとを代入
//                    self.compassView.addSubview(postView) // 親Viewに追加
                    
                    // starViewを作成
                    let starPosX: CGFloat = self.calcXfromDirection((data["direction"] as? CGFloat)!)
                    let starPosY: CGFloat = self.calcYfromDirection((data["direction"] as? CGFloat)!)
                    let starSize: CGFloat = self.compassView.bounds.size.width * 0.1 // compassView幅の50%
                    let starImageView = UIImageView(frame: CGRect(x: starPosX - (starSize / 2), y: starPosY - (starSize / 2), width: starSize, height: starSize))
                    // starImageViewをcompassViewへ追加
                    self.compassView.addSubview(starImageView)
                    // starImageViewに画像を設定
                    starImageView.image = UIImage(named: "star")
                    // Animation
                    starImageView.alpha = 0
                    UIImageView.transition(with: starImageView,
                                           duration: 0.4,
                                           options: [.curveEaseIn],
                                           animations: {
                                            starImageView.alpha = 1
                                           }, completion: nil)
                    
                    // starLabelViewを作成
                    let starLabelView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                    starLabelView.backgroundColor = UIColor(white: 1, alpha: 0.5) // 背景色
                    starLabelView.translatesAutoresizingMaskIntoConstraints = false // コードによるAutoLayout有効化
                    // starLabel作成
                    let starLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                    starLabel.text = data["wish"] as? String // 願いごとを代入
                    starLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 9) // フォント設定
                    starLabel.textAlignment = .center // 中央揃え
                    starLabel.sizeToFit()
//                    starLabel.frame.size.width += 50 // padding
                    starLabel.textColor = UIColor.black // 文字色
                    starLabel.backgroundColor = UIColor.white // 背景色
                    starLabel.translatesAutoresizingMaskIntoConstraints = false // コードによるAutoLayout有効化
                    starLabelView.addSubview(starLabel) // starLabelViewに追加
                    // starLabelViewをcompassViewに追加（必ずAutoLayoutより先に追加する）
                    self.compassView.addSubview(starLabelView)
                    // Animation
                    starLabelView.alpha = 0
                    UIView.transition(with: starLabelView,
                                      duration: 0.4,
                                      options: [.curveEaseIn],
                                      animations: {
                                        starLabelView.alpha = 1
                                        
                                      }, completion: nil)
                    
                    // AutoLayout
                    NSLayoutConstraint.activate([
                        starLabelView.leftAnchor.constraint(equalTo: starImageView.rightAnchor, constant: 10), // starImageViewの右端から10
                        starLabelView.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor, constant: 0), // starImageViewと中央揃え（Y）
//                        starLabelView.widthAnchor.constraint(equalTo: starLabel.widthAnchor, multiplier: 1.1), // starLabelの1.1倍
//                        starLabelView.heightAnchor.constraint(equalTo: starLabel.heightAnchor, multiplier: 1.2), // starLabelの1.2倍
//                        starLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 10), // 10以上で文字数に合わせる
//                        starLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 10), // 10以上で行数に合わせる
//                        starLabel.leadingAnchor.constraint(equalTo: starLabelView.leftAnchor, constant: 10),
//                        starLabel.trailingAnchor.constraint(equalTo: starLabelView.rightAnchor, constant: 10),
//                        starLabel.topAnchor.constraint(equalTo: starLabelView.topAnchor, constant: 10),
//                        starLabel.bottomAnchor.constraint(equalTo: starLabelView.bottomAnchor, constant: 10),
                    ])
                }
            }
        }
        
//        let listener = db.collection("cities").addSnapshotListener { querySnapshot, error in}
//        listener.remove()
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
    
    // 方角から位置を計算する
    func calcXfromDirection(_ direction: CGFloat) -> CGFloat {
        // compassViewの中心
        let radius = self.compassView.bounds.size.width / 2
        
        // 原点からの距離を、角度と半径から計算
        return (cos(degreeToRadian(direction-90)) * radius) + radius
    }
    
    func calcYfromDirection(_ direction: CGFloat) -> CGFloat {
        let radius = self.compassView.bounds.size.width / 2
        
        // 原点からの距離を、角度と半径から計算
        return sin(degreeToRadian(direction-90)) * radius + radius
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

