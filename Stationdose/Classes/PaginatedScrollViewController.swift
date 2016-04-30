//
//  PaginatedScrollViewController.swift
//  Stationdose
//
//  Created by Hoof on 4/29/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

class PaginatedScrollViewController: UIPageViewController {
    
    static var altPlaylistCount = 5
    var station: Station?

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var vcs: [UIViewController] = []
        for i in 0 ..< altPlaylistCount {
         vcs.append(self.newEnergyChartViewController())
        }
        return vcs
    }()
    
    private func newEnergyChartViewController() -> UIViewController {
        let vc =  UIStoryboard(name: "Edit", bundle: nil) .
            instantiateViewControllerWithIdentifier("EnergyChartViewController") as! EnergyChartViewController
        vc.station = station
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
                
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .Forward,
                               animated: true,
                               completion: nil)
        }
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

// MARK: UIPageViewControllerDataSource

extension PaginatedScrollViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}
