//
//  CALayer_Extension.swift
//  WishUponAStar
//
//  Created by nullworkbench on 2021/03/01.
//

import UIKit

extension CALayer {
    func setAnchorPoint(newAnchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPoint(x: self.bounds.size.width * newAnchorPoint.x, y: self.bounds.size.height * newAnchorPoint.y)

        newPoint = newPoint.applying(view.transform)

        var position = self.position

        position.x = newPoint.x
        position.y = newPoint.y

        self.anchorPoint = newAnchorPoint
        self.position = position
    }
}
