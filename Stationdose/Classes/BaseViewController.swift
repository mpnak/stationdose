//
//  BaseViewController.swift
//  Stationdose
//
//  Created by Developer on 11/19/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                showCustomBack()
            }
        }
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo-min"))
    }
    
}
