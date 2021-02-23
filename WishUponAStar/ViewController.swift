//
//  ViewController.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/02/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // ロケーションマネージャー定義
    let locationManager = CLLocationManager()
    
    // 現在の方角
    var currentDirection: Float = 0.0
    
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
    }
    
    // 方角が変わると呼び出される
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // compassViewを回転
        compassView.transform = CGAffineTransform(rotationAngle: CGFloat(-newHeading.magneticHeading) * CGFloat.pi / 180)
        // 現在の方角を更新
        currentDirection = Float(newHeading.magneticHeading)
    }
    
    @IBAction func star() {
        print(currentDirection)
    }


}

