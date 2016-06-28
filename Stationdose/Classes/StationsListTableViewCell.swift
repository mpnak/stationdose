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
    var buttonDelegate: StationCellDelegate?
    @IBOutlet weak var savedImageView: UIImageView!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var addedMessageView: UIView?
    @IBOutlet weak var removedMessageView: UIView?
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint?
    @IBOutlet var trailingConstraint: NSLayoutConstraint?
    
    @IBAction func savePressed (sender: AnyObject?) {
        buttonDelegate?.savePressed(self)
    }
    
    @IBAction func removePressed (sender: AnyObject?) {
        buttonDelegate?.removePressed(self)
    }
}
