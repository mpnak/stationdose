//
//  PlaylistViewController.swift
//  Stationdose
//
//  Created by Developer on 12/1/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class PlaylistViewController: PlaylistBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create effect
        let blur = UIBlurEffect(style: .Dark)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.frame = self.bannerImageView.frame
        effectView.alpha = 0.8
        bannerImageEffectView = effectView
        self.bannerImageView.addSubview(bannerImageEffectView!)
    }
}