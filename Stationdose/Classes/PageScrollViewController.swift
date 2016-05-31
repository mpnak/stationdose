//
//  PageScrollViewController.swift
//  Stationdose
//
//  Created by Hoof on 4/29/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit
import Foundation

protocol DetailsPageScrollDelegate {
    func detailsScrollViewSetIndex(defaultIndex: Int)
    func detailsScrollViewDidPage(scrollView: UIScrollView, pageIndex: Int)
}

class PageScrollViewController: UIViewController, UIScrollViewDelegate {
    
    var altPlaylistCount = 6
    let kPadding: CGFloat = 20.0
    var prevPageIndex = -1
    var currentPageIndex = 0
    var nextPageIndex = 1
    var myViews: [UIView] = []
    var laidOut = false
    var inited = false
    
    var SCALE_MIN: CGFloat = 0.8
    
    var pageScrollDelegate: DetailsPageScrollDelegate?
    var forcedScroll = false
    
    var defaultPlaylistIndex = 0 {
        didSet {
            if !laidOut {
                for i in 0 ..< altPlaylistCount {
                    let x = CGFloat(i)*self.scrollView!.bounds.size.width
                    let vc = EnergyChartViewController()
                    self.addChildViewController(vc)
                    
                    vc.view.frame = CGRectMake(x, 0, self.scrollView!.bounds.size.width, self.scrollView!.bounds.size.height)
                    vc.chartView!.frame = CGRectMake(0, 0, self.scrollView!.bounds.size.width, self.scrollView!.bounds.size.height)
                    
                    vc.station = station!
                    vc.chartName = "graph-\(i+1)"
                    vc.setupChart()
                    
                    self.scrollView?.addSubview(vc.view)
                    myViews.append(vc.view)
                }
                let w: CGFloat = CGFloat(altPlaylistCount) * self.scrollView!.bounds.size.width
                self.scrollView?.contentSize = CGSizeMake(w, self.scrollView!.contentSize.height)
                currentPageIndex = defaultPlaylistIndex
                self.scrollView?.contentOffset = CGPointMake(CGFloat(currentPageIndex)*self.scrollView!.bounds.width, 0)
                self.prevOffsetX = CGFloat(currentPageIndex)*self.scrollView!.bounds.width
                self.initializeAnimations()
                
                pageScrollDelegate?.detailsScrollViewSetIndex(defaultPlaylistIndex)
                
                laidOut = true
            }
        }
    }
    var prevDirection = 0
    var pagingCancelled = false
    
    @IBOutlet weak var scrollView: UIScrollView?
    var station: Station?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clearColor()
        self.scrollView?.bounces = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func advanceNext () {
        let newOffsetX = self.scrollView!.contentOffset.x + self.scrollView!.frame.size.width
        self.scrollView!.setContentOffset(CGPointMake(newOffsetX, 0), animated: true)
        prevDirection = 0
        pagingCancelled = false
        prevOffsetX = newOffsetX
        currentPageIndex += 1
        pageScrollDelegate?.detailsScrollViewDidPage(self.scrollView!, pageIndex: currentPageIndex)
    }
    
    func advancePrev () {
        let newOffsetX = self.scrollView!.contentOffset.x - self.scrollView!.frame.size.width
        self.scrollView!.setContentOffset(CGPointMake(newOffsetX, 0), animated: true)
        prevDirection = 0
        pagingCancelled = false
        prevOffsetX = newOffsetX
        currentPageIndex -= 1
        pageScrollDelegate?.detailsScrollViewDidPage(self.scrollView!, pageIndex: currentPageIndex)
    }
    
    var prevOffsetX: CGFloat = -999.0
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (inited) {
            let offsetX = scrollView.contentOffset.x
            print(offsetX)
            
            var direction = 0
            if prevOffsetX < offsetX {
                direction = 1
            } else {
                if offsetX < myViews.last?.frame.origin.x {
                    direction = -1
                }
            }
            if prevDirection != direction && prevDirection != 0 {
                pagingCancelled = true
            }
            animateProperties(direction)
            prevDirection = direction
            prevOffsetX = offsetX
        } else {
            inited = true;
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        prevDirection = 0
        pagingCancelled = false
        
        currentPageIndex = Int(round(calculatePageIndex()))
        print("page: \(currentPageIndex)")
    
        pageScrollDelegate?.detailsScrollViewDidPage(scrollView, pageIndex: currentPageIndex)
        UIView.animateWithDuration(0.2) {
            self.initializeAnimations()
        }
    }
    
    func calculatePageIndex () -> Double {
        let offsetX = scrollView!.contentOffset.x
        return Double(offsetX / self.scrollView!.frame.size.width)
    }
    
    func initializeAnimations () {
        let currentView = myViews[currentPageIndex]
        for view in myViews {
            if view != currentView {
                view.transform = CGAffineTransformMakeScale(SCALE_MIN, SCALE_MIN)
            }
        }
        currentView.transform = CGAffineTransformMakeScale(1.0, 1.0)
    }
    
    func animateProperties (direction: Int) {
        
        let offsetX = scrollView!.contentOffset.x
        let modulo = offsetX % scrollView!.bounds.size.width
        let ratio = modulo / scrollView!.bounds.size.width
        print("ratio: \(ratio)")
        
        if !pagingCancelled {
    
            if ratio != 0 {
                if direction > 0 {
                    let currentView = myViews[currentPageIndex]
                    var scale = 1.0 - ratio
                    if scale < SCALE_MIN {
                        scale = SCALE_MIN
                    }
                    let t1 = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = t1
                    
                    if currentPageIndex+1 <= myViews.count-1 {
                        let nextView = myViews[currentPageIndex+1]
                        scale = ratio + SCALE_MIN
                        if scale >= 1.0 {
                            scale = 1.0
                        }
                        let t2 = CGAffineTransformMakeScale(scale, scale)
                        nextView.transform = t2
                    }
                }
                
                if direction < 0 {
                    
                    let currentView = myViews[currentPageIndex]
                    var scale = max(ratio, SCALE_MIN)
                    
                    print("scale-current: \(scale)")
                    let t1 = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = t1
                    
                    if currentPageIndex-1 >= 0 {
                        let prevView = myViews[currentPageIndex-1]
                        scale = 1 - ratio + SCALE_MIN
                        if scale >= 1.0 {
                            scale = 1.0
                        }
                        print("scale-prev: \(scale)")
                        let t2 = CGAffineTransformMakeScale(scale, scale)
                        prevView.transform = t2
                    }
                }
            }
        } else {
            print("PAGING CANCELLED!!!!!!!!!!!")
            
            if ratio != 0 {
                if direction < 0 {
                    let currentView = myViews[currentPageIndex]
                    var scale = 1.0 - ratio
                    if scale < SCALE_MIN {
                        scale = SCALE_MIN
                    }
                    let t1 = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = t1
                    
                    if currentPageIndex+1 <= myViews.count-1 {
                        let nextView = myViews[currentPageIndex+1]
                        scale = ratio + SCALE_MIN
                        if scale >= 1.0 {
                            scale = 1.0
                        }
                        let t2 = CGAffineTransformMakeScale(scale, scale)
                        nextView.transform = t2
                    }
                }
                
                if direction > 0 {
                    
                    let currentView = myViews[currentPageIndex]
                    var scale = max(ratio, SCALE_MIN)
                    
                    print("scale-current: \(scale)")
                    let t1 = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = t1
                    
                    if currentPageIndex-1 >= 0 {
                        let prevView = myViews[currentPageIndex-1]
                        scale = 1 - ratio + SCALE_MIN
                        if scale >= 1.0 {
                            scale = 1.0
                        }
                        print("scale-prev: \(scale)")
                        let t2 = CGAffineTransformMakeScale(scale, scale)
                        prevView.transform = t2
                    }
                }
            }
            
        }
            
    }
}
