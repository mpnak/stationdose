//
//  StationListTableViewCell.swift
//  Stationdose
//
//  Created by Developer on 11/20/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class StationsListTableViewCell: PlayableTableViewCell {
    
    var station: Station!
    @IBOutlet weak var savedImageView: UIImageView!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var addedMessageView: UIView!
    @IBOutlet weak var removedMessageView: UIView!
    
    
}
