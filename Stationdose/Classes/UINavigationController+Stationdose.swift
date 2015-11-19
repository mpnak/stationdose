//
//  UINavigationController+Stationdose.swift
//  Stationdose
//
//  Created by Developer on 11/18/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    
    private struct AssociatedKeys {
        static var LogoView = "LogoView"
    }
    
    var showLogo: Bool? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.LogoView) != nil)
        }
        set {
            if let newValue = newValue {
                if let logoView = objc_getAssociatedObject(self, &AssociatedKeys.LogoView) {
                    logoView.removeFromSuperview()
                }
                if newValue {
                    let logoView = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-18, y: 44/2+5, width: 35, height: 29))
                    logoView.image = UIImage(named: "logo_min")
                    self.view.addSubview(logoView)
                    objc_setAssociatedObject(self, &AssociatedKeys.LogoView, logoView as UIImageView?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
        }
    }
}
