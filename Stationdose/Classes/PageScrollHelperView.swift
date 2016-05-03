//
//  PageScrollHelperView.swift
//  Stationdose
//
//  Created by Hoof on 4/29/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

class PageScrollHelperView: UIView {
    
    @IBOutlet weak var pageScrollView: UIScrollView?

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if pageScrollView != nil {
            return pageScrollView
        }
        return nil
    }

}
