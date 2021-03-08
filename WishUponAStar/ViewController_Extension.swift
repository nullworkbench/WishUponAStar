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
    
    func getJPTime() -> Date {
        let d1 = Date.current
        let d2 = DateFormatter.current("yyyy-MM-dd HH:mm:ss").string(from: d1)
        let d3 = DateFormatter.current("yyyy-MM-dd HH:mm:ss").date(from: d2)
        
        return d3!
    }
    
    func judgeDirection(_ direction: Float) -> String {
        if direction > 22 && direction <= 67 {
            return "北東"
        } else if direction > 67 && direction <= 112 {
            return "東"
        } else if direction > 112 && direction <= 157 {
            return "南東"
        } else if direction > 157 && direction <= 202 {
            return "南"
        } else if direction > 202 && direction <= 247 {
            return "南西"
        } else if direction > 247 && direction <= 292 {
            return "西"
        } else if direction > 292 && direction <= 337 {
            return "北西"
        } else {
            return "北"
        }
    }
}




extension TimeZone {
    static let gmt = TimeZone(secondsFromGMT: 0)!
    static let jst = TimeZone(identifier: "Asia/Tokyo")!
}
extension Locale {
    static let japan = Locale(identifier: "ja_JP")
}
extension DateFormatter {
    static func current(_ dateFormat: String) -> DateFormatter {
        let df = DateFormatter()
        df.timeZone = TimeZone.gmt
        df.locale = Locale.japan
        df.dateFormat = dateFormat
        return df
    }
}
extension Date {
    static var current: Date = Date(timeIntervalSinceNow: TimeInterval(TimeZone.jst.secondsFromGMT()))
}
