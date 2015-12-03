//
//  TrackTableViewCell.swift
//  Stationdose
//
//  Created by Developer on 12/1/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TrackTableViewCell: PlayableTableViewCell {
    
    var track: Track!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var likedImageView: UIImageView!
    
}
