//
//  PlayableTableViewCell.swift
//  Stationdose
//
//  Created by Developer on 12/3/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class PlayableTableViewCell: BaseTableViewCell {
    
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setPlaying(selected: Bool) {
        titleLabel?.textColor = selected ? UIColor.customSectionDividersColor() : UIColor.whiteColor()
    }
    
}
