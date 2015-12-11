//
//  UIViewController+Stationdose.swift
//  Stationdose
//
//  Created by Developer on 11/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addFullBackground() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "full_background")!)
    }
    
    func showGenericErrorMessage(){
        AlertView.genericErrorAlert().show()
    }
    
    func showCustomBack() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn-back"), style: .Plain, target: self, action: "back")
    }
    
    func back () {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var showUserProfileButton: Bool? {
        get {
            return (self.navigationItem.rightBarButtonItem != nil)
        }
        
        set {
            if let newValue = newValue {
                if newValue {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "profile-icon"), style: .Plain, target: self, action: "oppenUserProfileAction")
                }
            }
        }
    }
    
    func oppenUserProfileAction() {
        print("oppenUserProfileAction")
    }

}
