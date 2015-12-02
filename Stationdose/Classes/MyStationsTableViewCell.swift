//
//  MyStationsTableViewCell.swift
//  Stationdose
//
//  Created by Developer on 11/20/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class MyStationsTableViewCell: MGSwipeTableCell {
    
    var station: Station!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mySelectedBackgroundView: UIView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.1) { () -> Void in
                self.mySelectedBackgroundView.alpha = selected ? 1 : 0
            }
        } else {
            mySelectedBackgroundView.alpha = selected ? 1 : 0
        }
        
        nameLabel.textColor = selected ? UIColor.customSectionDividersColor() : UIColor.whiteColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.setSelected(true, animated: true)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.setSelected(false, animated: true)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.setSelected(false, animated: true)
    }
}
