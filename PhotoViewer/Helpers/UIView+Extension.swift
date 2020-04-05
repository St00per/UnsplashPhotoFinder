//
//  UIView+Extension.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 05.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import UIKit

extension UIView {
    //Allows to round selected corners of a view
    func roundCorners(cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}
