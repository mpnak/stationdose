//
//  SideScrollerViewController.swift
//  Stationdose
//
//  Created by Hoof on 5/4/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

class SideScrollerViewController: UIViewController {

    var initialized = false
    @IBOutlet weak var scrollView: UIScrollView?
    
    var selectionDefaultIndex = 0
    var myCurrentPageIndex: Int = 0
    var prevPageIndex: Int = 0
    var currentOffset: CGPoint = CGPointZero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if !initialized {
            initialized = true
        }
    }
    
    func setDefaultIndex (index: Int) {
        selectionDefaultIndex = index
        
        let manualLabel = UILabel(frame: scrollView!.bounds)
        manualLabel.textAlignment = .Center
        manualLabel.text = "Manual Setting"
        manualLabel.textColor = .whiteColor()
        scrollView?.addSubview(manualLabel)
        
        if let defaultView = NSBundle.mainBundle().loadNibNamed("EditPlaylistChartWeatherView", owner: self, options: nil).first as? EditPlaylistChartWeatherView {
            defaultView.frame = scrollView!.bounds
            defaultView.frame.origin.x = scrollView!.bounds.width
            scrollView?.addSubview(defaultView)
        }
        
        let manualLabel2 = UILabel(frame: scrollView!.bounds)
        manualLabel2.textAlignment = .Center
        manualLabel2.text = "Manual Setting"
        manualLabel2.textColor = .whiteColor()
        manualLabel2.frame.origin.x = scrollView!.bounds.width * 2
        scrollView?.addSubview(manualLabel2)
        
        scrollView?.contentSize = CGSizeMake(scrollView!.bounds.width * 3, scrollView!.bounds.height)
        
        myCurrentPageIndex = 1
        scrollView?.contentOffset = CGPointMake(scrollView!.bounds.width*CGFloat(myCurrentPageIndex), 0)
        currentOffset = scrollView!.contentOffset
    }
    
    func scrollingFromIndex (fromIndex: Int, toIndex: Int, direction: Int, withOffsetProportion: CGFloat) {
        if withOffsetProportion > 0 {
//            print("sideScrollView offset: \(scrollView!.contentOffset.x)")
            if toIndex > fromIndex && fromIndex == selectionDefaultIndex {
                scrollView?.contentOffset = CGPointMake(scrollView!.bounds.width+withOffsetProportion*scrollView!.bounds.width, 0)
                
            }
            if toIndex > fromIndex && toIndex == selectionDefaultIndex {
                scrollView?.contentOffset = CGPointMake(withOffsetProportion*scrollView!.bounds.width, 0)
                
            }
            if toIndex < fromIndex && fromIndex == selectionDefaultIndex {
                scrollView?.contentOffset = CGPointMake(withOffsetProportion*scrollView!.bounds.width, 0)
                
            }
            if toIndex < fromIndex && toIndex == selectionDefaultIndex {
                scrollView?.contentOffset = CGPointMake(scrollView!.bounds.width+withOffsetProportion*scrollView!.bounds.width, 0)
                
            }
        }
    }
    
    func scrollViewDidPage(pageScrollView: UIScrollView, pageIndex: Int) {
        if pageIndex < selectionDefaultIndex {
            self.scrollView?.contentOffset = CGPointMake(0, 0)
        }
        if pageIndex == selectionDefaultIndex {
            self.scrollView?.contentOffset = CGPointMake(self.scrollView!.bounds.width, 0)
        }
        if pageIndex > selectionDefaultIndex {
            self.scrollView?.contentOffset = CGPointMake(self.scrollView!.bounds.width*2, 0)
        }
        myCurrentPageIndex = pageIndex
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
