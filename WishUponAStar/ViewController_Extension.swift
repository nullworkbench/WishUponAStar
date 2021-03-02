//
//  ViewController_Extension.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/02/23.
//

import UIKit

extension UIViewController {
    func degreeToRadian(_ degree: CGFloat) -> CGFloat {
        return degree * .pi / 180
    }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
