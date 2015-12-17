//
//  EditStationViewController.swift
//  Stationdose
//
//  Created by Washington Miranda on 12/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class EditStationViewController: BaseViewController {
    
    internal var savedStation: SavedStation?
    
    @IBOutlet weak internal var coverImageView: UIImageView!
    
    @IBOutlet weak internal var nameLabel: UILabel!
    
    @IBOutlet weak var updatedAtLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
            
        nameLabel?.text = savedStation?.station?.name
        
        if let imageUrl = savedStation?.station?.art {
            let url = NSURL(string: imageUrl)!
            coverImageView?.af_setImageWithURL(url)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
