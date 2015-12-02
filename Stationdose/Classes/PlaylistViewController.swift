//
//  PlaylistViewController.swift
//  Stationdose
//
//  Created by Developer on 12/1/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class PlaylistViewController: BaseViewController {

    var playlist:Playlist?
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = playlist?.station?.name
        shortDescriptionLabel.text = playlist?.station?.shortDescription
    }
    
    @IBAction func removeStation(sender: AnyObject) {
        
    }
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tracks = playlist?.tracks {
            return tracks.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = playlist?.tracks![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackTableViewCellIdentifier") as! TrackTableViewCell
        
        cell.titleLabel.text = track?.title
        cell.subtitleLabel.text = track?.artist
        
//        let deleteButton = MGSwipeButton(title: nil, icon: UIImage(named: "btn-delete-station"), backgroundColor: UIColor.customWarningColor(), callback: { (cell) -> Bool in
////            self.removeStation(track) { () -> Void in
////                cell.hideSwipeAnimated(true)
////            }
//            
//            return false
//        })
//        cell.rightButtons = [deleteButton]
//        cell.rightSwipeSettings.transition = .Drag
        
        
        //customToggleOnColor
        
        return cell
    }
}
