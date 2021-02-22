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
    
    // コンパスのView
    @IBOutlet var compassView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(compassView.frame.size.width / 2.1)
        
        // ロケーションマネージャーのdelegate指定
        locationManager.delegate = self
        // 方角の更新間隔
        locationManager.headingFilter = 0.1
        // 方角の取得開始
        locationManager.startUpdatingHeading()
    }
    
    // 方角が変わると呼び出される
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        compassView.transform = CGAffineTransform(rotationAngle: CGFloat(-newHeading.magneticHeading) * CGFloat.pi / 180)
    }


}

