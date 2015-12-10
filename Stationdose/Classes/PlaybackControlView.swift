//
//  PlaybackControlView.swift
//  Stationdose
//
//  Created by Developer on 12/9/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class PlaybackControlView: UIView {
    
    class func instanceFromNib() -> PlaybackControlView {
        return UINib(nibName: "PlaybackControlView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! PlaybackControlView
    }
    
    @IBOutlet weak var currentTimeProgressView: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
}
