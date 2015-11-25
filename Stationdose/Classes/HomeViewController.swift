//
//  HomeViewController.swift
//  Stationdose
//
//  Created by Developer on 11/15/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {
    
    var myStations: NSArray
    var stationsList: NSArray
    
    @IBOutlet weak var featuresStationsPageControl: UIPageControl!
    @IBOutlet weak var stationsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myStationsEmptyView: UIView!
    @IBOutlet weak var myStationsTableView: UITableView!
    @IBOutlet weak var stationsListTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        stationsList = ["stationsList 0","stationsList 1","stationsList 2","stationsList 3","stationsList 4","stationsList 5","stationsList 6","stationsList 7"]
        myStations = ["myStations 0","myStations 1","myStations 2","myStations 3","myStations 4","myStations 5","myStations 6","myStations 7"]
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.showLogo = true
        showUserProfileButton = true
        stationsSegmentedControl.selectedSegmentIndex = 1
        stationsListTableView.alpha = 0
        myStationsTableView.alpha = 0
    }
    
    @IBAction func addStations(sender: AnyObject) {
        stationsSegmentedControl.selectedSegmentIndex = 1;
        stationsSegmentedControlValueChanged(stationsSegmentedControl)
    }
    
    var stationsSegmentedControlValueChangedEnabled = true
    @IBAction func stationsSegmentedControlValueChanged(sender: UISegmentedControl) {
        
        if !stationsSegmentedControlValueChangedEnabled {
            sender.selectedSegmentIndex = sender.selectedSegmentIndex == 0 ? 1 : 0
            return
        }
        
        stationsSegmentedControlValueChangedEnabled = false
        
//        var myStationsEmptyViewVisible = false
//        
//        if stationsSegmentedControl.selectedSegmentIndex == 0 && myStations.count > 0 {
//            myStationsEmptyViewVisible = true
//        }
//        
//        let myStationsEmptyViewAlpha:CGFloat = myStationsEmptyViewVisible ? 1 : 0
//        
//        if self.myStationsEmptyView.alpha != myStationsEmptyViewAlpha {
//            
//            UIView.animateWithDuration(0.1, animations: { () -> Void in
//                self.myStationsEmptyView.alpha = myStationsEmptyViewAlpha
//            })
//        }
        
        let moveToLeft = stationsListTableView.alpha == 0
        
        animateStationsTableTransition(moveToLeft, completion:{ () -> Void in
            self.stationsListTableView.alpha = moveToLeft ? 1 : 0
            self.stationsSegmentedControlValueChangedEnabled = true
        })
    }
    
    func animateStationsTableTransition(moveToLeft: Bool, completion: () -> Void) {
        
        let rightTable = stationsListTableView
        let leftTable = myStationsTableView
        
        let leftInitialTranslation = moveToLeft ? CGFloat(0.0) : -leftTable.frame.size.width
        let leftTargetTranslation = moveToLeft ? -leftTable.frame.size.width : CGFloat(0.0)
        
        animateTableCells(leftTable, currentTranslation: leftInitialTranslation, translationTarget: leftTargetTranslation) { () -> Void in
            if leftTargetTranslation != 0 {
                leftTable.alpha = 0
                for var i=0; i<leftTable.visibleCells.count; i++ {
                    let cell = leftTable.visibleCells[i]
                    cell.layer.transform = CATransform3DIdentity
                }
            }
            completion()
        }
        
        let currentTranslation2 = moveToLeft ? leftTable.frame.size.width : CGFloat(0.0)
        let translationTarget2 = moveToLeft ? CGFloat(0.0) : leftTable.frame.size.width
        
        animateTableCells(rightTable, currentTranslation: currentTranslation2, translationTarget: translationTarget2) { () -> Void in
            if translationTarget2 != 0 {
                rightTable.alpha = 0
                for var i=0; i<rightTable.visibleCells.count; i++ {
                    let cell = rightTable.visibleCells[i]
                    cell.layer.transform = CATransform3DIdentity
                }
            }
            completion()
        }
    }
    
    func animateTableCells(table: UITableView, currentTranslation: CGFloat, translationTarget: CGFloat, completion: () -> Void) {
        
        let animationBaseTime = 0.1
        
        for var i=0; i<table.visibleCells.count; i++ {
            let cell = table.visibleCells[i]
            let lastCell = (i == table.visibleCells.count-1)
            cell.layer.transform = CATransform3DMakeTranslation(currentTranslation, 0.0, 0.0)
            if lastCell {
                table.alpha = 1
            }
            
            let delay = Double(i) * animationBaseTime
            let time = 4.0 * animationBaseTime //2.0 * animationBaseTime if the animation don't user damping
            
            UIView.animateWithDuration(time, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .CurveEaseOut, animations: { () -> Void in
                cell.layer.transform = CATransform3DMakeTranslation(translationTarget, 0.0, 0.0)
                }, completion: { finished -> Void in
                    if lastCell {
                        completion()
                    }
            })
            
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1)
        featuresStationsPageControl.currentPage = page
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let datasource = tableView == myStationsTableView ? myStations : stationsList
        return datasource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == myStationsTableView {
            let datasource = myStations
            let cell:MyStationsTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyStationsTableViewCellIdentifier") as! MyStationsTableViewCell
//            cell.label.text = datasource[indexPath.row] as? String
            
            cell.backgroundColor = UIColor.clearColor()
            return cell
        } else {
            let datasource = stationsList
            let cell:StationsListTableViewCell = tableView.dequeueReusableCellWithIdentifier("StationsListTableViewCellIdentifier") as! StationsListTableViewCell
//            cell.label.text = datasource[indexPath.row] as? String
            
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }
}
