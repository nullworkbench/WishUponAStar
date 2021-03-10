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
    
    // directionから方角を求める
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
    
    // 投稿がブロック済のユーザーでないか判定
    func isBlockedUser(uid: String) -> Bool {
        if let blockedUidsArray = UserDefaults.standard.array(forKey: "blockedUidsArray") {
            for blocked in blockedUidsArray {
                if blocked as! String == uid {
                    print("This post was posted by blocking user: \(uid)")
                    return true
                } else {
                    return false
                }
            }
        }
        return false
    }
}


extension UITableView {
    // 要素がない時のView
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        emptyView.backgroundColor = UIColor.WishUponAStar()
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        // コードによるAutoLayout有効化
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
       
        titleLabel.text = title
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 20)
        titleLabel.textAlignment = .center
        
        messageLabel.text = message
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 15)
        messageLabel.textAlignment = .center
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20)
        ])
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    // emptyView無効化
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
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

extension UIColor {
    class func WishUponAStar() -> UIColor {
        let color = UIColor(red: 37/255, green: 41/255, blue: 73/255, alpha: 1)
        return color
    }
}
