//
//  RecommendedSideScrollerViewController.swift
//  Stationdose
//
//  Created by Hoof on 5/31/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

class RecommendedSideScrollerViewController: SideScrollerViewController {

    var contentView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDefaultIndex (index: Int, forParentScrollView: UIScrollView) {
        parentScrollView = forParentScrollView
        parentScrollView!.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
        selectionDefaultIndex = index
        
        let manualLabel = UILabel(frame: scrollView!.bounds)
        manualLabel.textAlignment = .Center
        manualLabel.text = ""
        manualLabel.textColor = .whiteColor()
        manualLabel.backgroundColor = .clearColor()
        scrollView?.addSubview(manualLabel)
        
        if let defaultView = NSBundle.mainBundle().loadNibNamed("EditPlaylistContentView", owner: self, options: nil).first as? EditPlaylistContentView {
            defaultView.frame = scrollView!.bounds
            defaultView.frame.origin.x = scrollView!.bounds.width
            contentView = defaultView
            scrollView?.addSubview(contentView!)
        }
        
        let manualLabel2 = UILabel(frame: scrollView!.bounds)
        manualLabel2.textAlignment = .Center
        manualLabel2.text = ""
        manualLabel2.textColor = .whiteColor()
        manualLabel2.backgroundColor = .clearColor()
        manualLabel2.frame.origin.x = scrollView!.bounds.width * 2
        scrollView?.addSubview(manualLabel2)
        
        scrollView?.contentSize = CGSizeMake(scrollView!.bounds.width * 3, scrollView!.bounds.height)
        
        myCurrentPageIndex = 1
        scrollView?.contentOffset = CGPointMake(scrollView!.bounds.width*CGFloat(myCurrentPageIndex), 0)
        currentOffset = scrollView!.contentOffset
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
