//
//  BaseViewController.swift
//  Stationdose
//
//  Created by Developer on 11/19/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    static private var _customViewHeight:CGFloat?
    static var customViewHeight:CGFloat? {
        set {
            _customViewHeight = newValue
            NSNotificationCenter.defaultCenter().postNotificationName("BaseViewControllerNewCustomViewHeight", object: nil)
        }
        get {
            return _customViewHeight
        }
    }
    
    func setCustomViewHeight() {
        if let customViewHeight = BaseViewController.customViewHeight {
            var frame = self.view.frame
            frame.size.height = customViewHeight    
            self.view.frame = frame
            self.view.setNeedsLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setCustomViewHeight", name: "BaseViewControllerNewCustomViewHeight", object: nil)
        
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 1 {
                showCustomBack()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        setCustomViewHeight()
    }
}
