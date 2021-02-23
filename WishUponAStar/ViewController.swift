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
                    let posX: CGFloat = self.calcXfromDirection((data["direction"] as? CGFloat)!)
                    let posY: CGFloat = self.calcYfromDirection((data["direction"] as? CGFloat)!)
                    let width: CGFloat = self.compassView.bounds.size.width * 0.5 // compassView幅の50%
                    let height: CGFloat = width * 0.2 // width:height = 10:2
                    let postView: PostView = PostView(frame: CGRect(x: posX - (width * 0.1), y: posY - (height / 2), width: width, height: height)) // サイズと位置を指定
                    
                    postView.wishLabel.text = data["wish"] as? String // 願いごとを代入
                    self.compassView.addSubview(postView) // 親Viewに追加
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

