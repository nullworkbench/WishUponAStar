//
//  Designable.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/02/22.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
}

extension UIView {
    
    @IBInspectable
    var isCircle: Bool {
        get {
            return true
        }
        set {
            if newValue {
                layer.cornerRadius =  self.frame.size.width / 2
            }
        }
    }
    
    @IBInspectable
    var isRoundedCorner: Bool {
        get {
            return true
        }
        set {
            if newValue {
                layer.cornerRadius =  self.frame.size.width / 8
            }
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
        var borderWidth: CGFloat {
            get {
                return layer.borderWidth
            }
            set {
                layer.borderWidth = newValue
            }
        }

        @IBInspectable
        var borderColor: UIColor? {
            get {
                if let color = layer.borderColor {
                    return UIColor(cgColor: color)
                }
                return nil
            }
            set {
                if let color = newValue {
                    layer.borderColor = color.cgColor
                } else {
                    layer.borderColor = nil
                }
            }
        }
    
}
