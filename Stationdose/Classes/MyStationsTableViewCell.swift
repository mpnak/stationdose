//
//  MyStationsTableViewCell.swift
//  Stationdose
//
//  Created by Developer on 11/20/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class MyStationsTableViewCell: PlayableTableViewCell {
    
    var station: Station!
    var buttonDelegate: StationCellDelegate?
    //var savedStation: SavedStation!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
}
