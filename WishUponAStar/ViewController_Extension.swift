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
