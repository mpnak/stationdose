//
//  PageScrollViewController.swift
//  Stationdose
//
//  Created by Hoof on 4/29/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

protocol DetailsPageScrollDelegate {
    func detailsScrollViewShouldScroll(scrollView: UIScrollView, withPrevPageIndex: Int, current: Int, next: Int)
    func detailsScrollViewSetIndex(defaultIndex: Int)
    func detailsScrollViewScrollingfromIndex(fromIndex: Int, toIndex: Int, direction: Int, withOffsetProportion: CGFloat)
    func detailsScrollViewDidPage(scrollView: UIScrollView)
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
    
        if prevOffsetX < offsetX {
            animateProperties(1)
        } else {
            if offsetX < myViews.last?.frame.origin.x {
                animateProperties(-1)
            }
        }
        
        prevOffsetX = offsetX
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentPageIndex = calculatePageIndex()
        print("page: \(currentPageIndex)")
        pageScrollDelegate?.detailsScrollViewDidPage(scrollView)
    }
    
    func calculatePageIndex () -> Int {
        let offsetX = scrollView!.contentOffset.x
        return Int(offsetX / self.scrollView!.frame.size.width)
    }
    
    func initializeAnimations () {
        for view in myViews {
            view.transform = CGAffineTransformMakeScale(0.7, 0.7)
        }
        myViews[currentPageIndex].transform = CGAffineTransformMakeScale(1.0, 1.0)
    }

    func animateProperties (direction: Int) {
        
        let offsetX = scrollView!.contentOffset.x
        let modulo = offsetX % scrollView!.bounds.size.width
        let ratio = modulo / scrollView!.bounds.size.width
        
//        let modulo = offsetX % self.view.bounds.size.width
//        let ratio = modulo / self.view.bounds.size.width
        
        print("ratio: \(ratio)")
        
        if direction > 0 {
            pageScrollDelegate?.detailsScrollViewScrollingfromIndex(currentPageIndex, toIndex: currentPageIndex+1, direction: direction, withOffsetProportion: ratio)
        } else {
            pageScrollDelegate?.detailsScrollViewScrollingfromIndex(currentPageIndex, toIndex: currentPageIndex-1, direction: direction, withOffsetProportion: ratio)
        }
        
        if ratio > 0 {
            if direction > 0 && currentPageIndex < myViews.count-1 {
                let oldPage = currentPageIndex
                let newPage = currentPageIndex + 1
                if oldPage <= myViews.count-1 {
                    let oldView = myViews[oldPage]
                    
                    var scale = 1.0 - ratio
                    if scale <= 0.7 {
                        scale = 0.7
                    }
                    let transform = CGAffineTransformMakeScale(scale, scale)
                    oldView.transform = transform
                }
                if newPage <= myViews.count-1 {
                    let newView = myViews[newPage]
                    
                    var scale = ratio + 0.7
                    if scale >= 1.0 {
                        scale = 1.0
                    }
                    let transform = CGAffineTransformMakeScale(scale, scale)
                    newView.transform = transform
                }
            }
            
            if direction < 0 {
                let currentPage = currentPageIndex
                let prevPage = currentPageIndex - 1
                
                if currentPage <= myViews.count-1 && currentPage >= 0 {
                    let currentView = myViews[currentPage]
                    
                    var scale = ratio
                    if scale <= 0.7 {
                        scale = 0.7
                    }
                    let transform = CGAffineTransformMakeScale(scale, scale)
                    currentView.transform = transform
                }
                
                if prevPage >= 0 {
                    print("prevPage: \(prevPage)")
                    let prevView = myViews[prevPage]
                    
                    var scale = 1.0 - ratio + 0.7
                    if scale >= 1.0 {
                        scale = 1.0
                    }
                    let transform = CGAffineTransformMakeScale(scale, scale)
                    prevView.transform = transform
                }
            }
        }
    }
}
