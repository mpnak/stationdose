//
//  StationListTableViewCell.swift
//  Stationdose
//
//  Created by Developer on 11/20/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class StationsListTableViewCell: UITableViewCell {
    
    var station: Station!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var savedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!

}
