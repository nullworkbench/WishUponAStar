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
                    // starImageViewに画像を設定
                    starImageView.image = UIImage(named: "star")
                    // starImageViewをcompassViewへ追加
                    self.compassView.addSubview(starImageView)
                    
                    // starLabelViewを作成
                    let starLabelViewPosX = starPosX + starSize / 2
                    let starLabelViewPosY = starPosY - starSize / 5
                    let starLabelViewSize = self.compassView.bounds.size.width * 0.3
                    let starLabelView = UIView(frame: CGRect(x: starLabelViewPosX, y: starLabelViewPosY, width: starLabelViewSize, height: starLabelViewSize * 0.3))
//                    let starLabelView = UIView()
                    starLabelView.backgroundColor = UIColor(white: 1, alpha: 0.5) // 背景色
                    // starLabel作成
                    let starLabel = UILabel(frame: CGRect(x: 10, y: 0, width: starLabelViewSize - 20, height: starLabelViewSize * 0.3))
//                    let starLabel = UILabel()
                    starLabel.text = data["wish"] as? String // 願いごとを代入
                    starLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 9) // フォント設定
                    starLabel.textColor = UIColor.black // 文字色
                    starLabel.backgroundColor = UIColor.clear // 背景色
                    starLabelView.addSubview(starLabel) // starLabelViewに追加
                    // AutoLayout
//                    starLabelView.frame = self.view.frame
//                    starLabel.frame = self.view.frame
//                    NSLayoutConstraint.activate([
//                        starLabelView.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
//                        starLabelView.heightAnchor.constraint(equalToConstant: starLabelView.frame.size.width * 0.3),
//                        starLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
//    //                    starLabel.leadingAnchor.constraint(equalTo: starLabelView.leftAnchor, constant: 10),
//    //                    starLabel.trailingAnchor.constraint(equalTo: starLabelView.rightAnchor, constant: 10),
//    //                    starLabel.topAnchor.constraint(equalTo: starLabelView.topAnchor, constant: 10),
//    //                    starLabel.bottomAnchor.constraint(equalTo: starLabelView.bottomAnchor, constant: 10),
//                    ])
                    
                    // starLabelViewをcompassViewに追加
                    self.compassView.addSubview(starLabelView)
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

