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
    func detailsScrollViewShouldScroll(scrollView: UIScrollView, withPrevPageIndex: Int, current: Int, next: Int)
    func detailsScrollViewSetIndex(defaultIndex: Int)
    func detailsScrollViewScrollingfromIndex(fromIndex: Int, toIndex: Int, direction: Int, withOffsetProportion: CGFloat)
    func detailsScrollViewDidPage(scrollView: UIScrollView, pageIndex: Int)
}

class PageScrollViewController: UIViewController, UIScrollViewDelegate {
    
    var altPlaylistCount = 5
    let kPadding: CGFloat = 40.0
    var prevPageIndex = -1
    var currentPageIndex = 0
    var nextPageIndex = 1
    var myViews: [UIView] = []
    var laidOut = false
    
    var pageScrollDelegate: DetailsPageScrollDelegate?
    
    var defaultPlaylistIndex = 2
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
        
        if !laidOut {
            for i in 0 ..< altPlaylistCount {
                let x = CGFloat(i)*self.scrollView!.bounds.size.width
                let vc = EnergyChartViewController()
                self.addChildViewController(vc)
                
                vc.view.frame = CGRectMake(x, 0, self.scrollView!.bounds.size.width, self.scrollView!.bounds.size.height)
                vc.chartView!.frame = CGRectMake(0, 0, self.scrollView!.bounds.size.width, self.scrollView!.bounds.size.height)
                
                vc.station = station!
                vc.setupChart()
                
                self.scrollView?.addSubview(vc.view)
                myViews.append(vc.view)
            }
            let w: CGFloat = CGFloat(altPlaylistCount) * self.scrollView!.bounds.size.width
            self.scrollView?.contentSize = CGSizeMake(w, self.scrollView!.contentSize.height)
            currentPageIndex = defaultPlaylistIndex
            self.scrollView?.contentOffset = CGPointMake(CGFloat(currentPageIndex)*self.scrollView!.bounds.width, 0)
            self.initializeAnimations()
            
            pageScrollDelegate?.detailsScrollViewSetIndex(defaultPlaylistIndex)
            
            laidOut = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var prevOffsetX: CGFloat = 0.0
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
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
                view.transform = CGAffineTransformMakeScale(0.7, 0.7)
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
    
            if direction > 0 {
                pageScrollDelegate?.detailsScrollViewScrollingfromIndex(currentPageIndex, toIndex: currentPageIndex+1, direction: direction, withOffsetProportion: ratio)
            } else {
                pageScrollDelegate?.detailsScrollViewScrollingfromIndex(currentPageIndex, toIndex: currentPageIndex-1, direction: direction, withOffsetProportion: ratio)
            }
            
            if ratio != 0 {
                if direction > 0 {
                    let currentView = myViews[currentPageIndex]
                    var scale = 1.0 - ratio
                    if scale < 0.7 {
                        scale = 0.7
                    }
                    let t1 = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = t1
                    
                    if currentPageIndex+1 <= myViews.count-1 {
                        let nextView = myViews[currentPageIndex+1]
                        scale = ratio + 0.7
                        if scale >= 1.0 {
                            scale = 1.0
                        }
                        let t2 = CGAffineTransformMakeScale(scale, scale)
                        nextView.transform = t2
                    }
                }
                
                if direction < 0 {
                    
                    let currentView = myViews[currentPageIndex]
                    var scale = max(ratio, 0.7)
                    
                    print("scale-current: \(scale)")
                    let t1 = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = t1
                    
                    if currentPageIndex-1 >= 0 {
                        let prevView = myViews[currentPageIndex-1]
                        scale = 1 - ratio + 0.7
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
            
            if direction < 0 {
                pageScrollDelegate?.detailsScrollViewScrollingfromIndex(currentPageIndex, toIndex: currentPageIndex+1, direction: direction, withOffsetProportion: ratio)
            } else {
                pageScrollDelegate?.detailsScrollViewScrollingfromIndex(currentPageIndex, toIndex: currentPageIndex-1, direction: direction, withOffsetProportion: ratio)
            }
            
            if ratio != 0 {
                if direction < 0 {
                    let currentView = myViews[currentPageIndex]
                    var scale = 1.0 - ratio
                    if scale < 0.7 {
                        scale = 0.7
                    }
                    let t1 = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = t1
                    
                    if currentPageIndex+1 <= myViews.count-1 {
                        let nextView = myViews[currentPageIndex+1]
                        scale = ratio + 0.7
                        if scale >= 1.0 {
                            scale = 1.0
                        }
                        let t2 = CGAffineTransformMakeScale(scale, scale)
                        nextView.transform = t2
                    }
                }
                
                if direction > 0 {
                    
                    let currentView = myViews[currentPageIndex]
                    var scale = max(ratio, 0.7)
                    
                    print("scale-current: \(scale)")
                    let t1 = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = t1
                    
                    if currentPageIndex-1 >= 0 {
                        let prevView = myViews[currentPageIndex-1]
                        scale = 1 - ratio + 0.7
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
