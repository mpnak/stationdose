//
//  MainNavigationController.swift
//  Stationdose
//
//  Created by Hoof on 6/23/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    private var fullscreenView: FullScreenLoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoading() {
        fullscreenView = FullScreenLoadingView()
        fullscreenView!.show()
    }
    
    func hideLoading() {
        if fullscreenView != nil {
            fullscreenView!.hide()
            fullscreenView = nil
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
