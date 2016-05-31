//
//  WeatherSideScrollerViewController.swift
//  Stationdose
//
//  Created by Hoof on 5/31/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

class WeatherSideScrollerViewController: SideScrollerViewController {

    var conditionsView: EditPlaylistChartWeatherView?
    
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
        manualLabel.text = "Manual Setting"
        manualLabel.textColor = .whiteColor()
        scrollView?.addSubview(manualLabel)
        
        if let defaultView = NSBundle.mainBundle().loadNibNamed("EditPlaylistChartWeatherView", owner: self, options: nil).first as? EditPlaylistChartWeatherView {
            defaultView.frame = scrollView!.bounds
            defaultView.frame.origin.x = scrollView!.bounds.width
            conditionsView = defaultView
            scrollView?.addSubview(conditionsView!)
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
    
    func setConditions (defaultIndex defaultIndex: Int, weather: String?, time: String?, forParentScrollView: UIScrollView) {
        setDefaultIndex(defaultIndex, forParentScrollView: forParentScrollView)
        if weather != nil {
            conditionsView?.weatherImageView?.image = UIImage(named: "icon-" + weather!)
        }
        if time != nil {
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            formatter.AMSymbol = "am"
            formatter.PMSymbol = "pm"
            let date = formatter.dateFromString(time!)
            
            formatter.dateFormat = "EE"
            let day = formatter.stringFromDate(date!)
            conditionsView?.dayLabel?.text = day
            
            formatter.dateFormat = "h:mma"
            let shortTime = formatter.stringFromDate(date!)
            conditionsView?.timeLabel?.text = shortTime
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
