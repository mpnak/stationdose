//
//  SideScrollerViewController.swift
//  Stationdose
//
//  Created by Hoof on 5/4/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit
import ObjectMapper

class SideScrollerViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView?
    
    var selectionDefaultIndex = 0
    var myCurrentPageIndex: Int = 0
    var prevPageIndex: Int = 0
    var currentOffset: CGPoint = CGPointZero
    
    var parentScrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let newValue = change?[NSKeyValueChangeNewKey]?.CGPointValue() {
           
            let scaleFactor = self.scrollView!.frame.size.width / parentScrollView!.frame.size.width
            let realOffsetX = scaleFactor * newValue.x
            print("contentOffset changed changed: \(newValue) , scaleFactor: \(scaleFactor) , realOffsetX: \(realOffsetX)")
            
            let modNext = CGFloat(selectionDefaultIndex)*self.scrollView!.frame.size.width
            if realOffsetX > modNext {
                let newOffsetX = self.scrollView!.frame.size.width + realOffsetX % modNext
                if newOffsetX < 2 * self.scrollView!.frame.size.width {
                    self.scrollView!.contentOffset = CGPointMake(newOffsetX, 0)
                }
            }
            let modPrev = CGFloat(selectionDefaultIndex-1)*self.scrollView!.frame.size.width
            if realOffsetX < modNext && realOffsetX > modPrev {
                let newOffsetX = realOffsetX % modPrev
                self.scrollView!.contentOffset = CGPointMake(newOffsetX, 0)
            }
        }
    }
    
    deinit {
        parentScrollView?.removeObserver(self, forKeyPath: "contentOffset", context: nil)
    }
    
    func scrollViewDidPage(pageScrollView: UIScrollView, pageIndex: Int) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
