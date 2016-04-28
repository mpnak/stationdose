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
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var likedImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TrackTableViewCell.validatePlaying), name: "playbackCurrentTrackDidChange", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func validatePlaying() {
        self.setPlaying(track.id == PlaybackManager.sharedInstance.currentTrack?.id)
    }
}
