//
//  PaddingLabel.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/01.
//

import UIKit

class PaddingLabel: UILabel {
    var paddingTop: CGFloat = 0
    var paddingRight: CGFloat = 0
    var paddingBottom: CGFloat = 0
    var paddingLeft: CGFloat = 0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + paddingLeft + paddingRight, height: size.height + paddingTop + paddingBottom)
    }
}
