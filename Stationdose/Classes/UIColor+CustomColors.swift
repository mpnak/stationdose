//
//  UIColor+CustomColors.swift
//  Stationdose
//
//  Created by Developer on 11/18/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import ChameleonFramework

extension UIColor {
    
    //App background
    class func customAppBackgroundColor()->UIColor {
        return UIColor(hexString:"#000000")
    }
    
    //Section dividers; Primary text button; Play head
    class func customSectionDividersColor()->UIColor {
        return UIColor(hexString:"#12D2E0")
    }
    
    //Primary text button - tap
    class func customPrimaryTextButtonTapColor()->UIColor {
        return UIColor(hexString:"#138F98")
    }
    
    //Track/station tap active background; Drawer background
    class func customTrackTapActiveBackgroundColor()->UIColor {
        return UIColor(hexString:"#1B1B1B")
    }
    
    //Play progress bar background; Modal box background
    class func customPlayProgressBarBackgroundColor()->UIColor {
        return UIColor(hexString:"#242424")
    }
    
    //Secondary text button
    class func customSecondaryTextButtonColor()->UIColor {
        return UIColor(hexString:"#808080")
    }
    
    //Secondary text button - tap
    class func customSecondaryTextButtonTapColor()->UIColor {
        return UIColor(hexString:"#b5b5b5")
    }
    
    //Warning/delete/toggle-off
    class func customWarningColor()->UIColor {
        return UIColor(hexString:"#B00B0B")
    }
    
    //Toggle-on
    class func customToggleOnColor()->UIColor {
        return UIColor(hexString:"#6bbb13")
    }
    
    class func customButtonBorderColor()->UIColor {
        return UIColor(hexString:"#1ED760")
    }
    
    class func customButtonBorderTapColor()->UIColor {
        return UIColor(hexString:"#0B923B")
    }
}
