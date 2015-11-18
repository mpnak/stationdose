//
//  UIViewController+Stationdose.swift
//  Stationdose
//
//  Created by Developer on 11/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addFullBackground(){
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "fullBackground")!)
    }
    
    func showErrorMessage(message:String){
        let alertController = UIAlertController(title: "Default Style", message: message, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

}
