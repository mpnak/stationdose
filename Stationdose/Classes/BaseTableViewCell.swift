//
//  BaseTableViewCell.swift
//  Stationdose
//
//  Created by Developer on 12/3/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class BaseTableViewCell: MGSwipeTableCell {

    var mySelectedBackgroundView: UIView
    
    var touchDownAction: () -> ()
    var touchUpInsideAction: () -> ()
    var touchUpOutsideAction: () -> ()
    
    required init?(coder aDecoder: NSCoder) {
        
        mySelectedBackgroundView = UIView()
        
        touchDownAction = {_ in }
        touchUpInsideAction = {_ in }
        touchUpOutsideAction = {_ in }
        
        super.init(coder: aDecoder)
        
        mySelectedBackgroundView.frame = contentView.bounds
        mySelectedBackgroundView.backgroundColor = UIColor.customTrackTapActiveBackgroundColor()
        mySelectedBackgroundView.alpha = 0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if mySelectedBackgroundView.superview == nil {
            contentView.insertSubview(mySelectedBackgroundView, atIndex: 0)
        }
        
        if animated {
            UIView.animateWithDuration(0.1) { () -> Void in
                self.mySelectedBackgroundView.alpha = selected ? 1 : 0
            }
        } else {
            mySelectedBackgroundView.alpha = selected ? 1 : 0
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.setSelected(true, animated: true)
        touchDownAction()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.setSelected(false, animated: true)
        touchUpInsideAction()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.setSelected(false, animated: true)
        touchUpOutsideAction()
    }
}
