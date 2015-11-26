//
//  HomeViewController.swift
//  Stationdose
//
//  Created by Developer on 11/15/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: BaseViewController {
    
    var myStations: [Playlist]
    var stationsList: [Station]
    var currentLocation:CLLocation?
    
    @IBOutlet weak var featuresStationsPageControl: UIPageControl!
    @IBOutlet weak var stationsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myStationsEmptyView: UIView!
    @IBOutlet weak var myStationsTableView: UITableView!
    @IBOutlet weak var stationsListTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        stationsList = []
        myStations = []
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SongSortApiManager.sharedInstance.getStationsList { (serversStationsList, error) -> Void in
            if let serversStationsList = serversStationsList {
                self.stationsList = serversStationsList
                self.reloadData()
            } else {
                print("Error: ", error)
            }
        }
        
        SongSortApiManager.sharedInstance.getPlaylists { (myPlaylists:[Playlist]?, error) -> Void in
            if let myPlaylists = myPlaylists {
//                var serversMyStations:[Station] = []
//                for myPlaylist in myPlaylists {
//                    if let station = myPlaylist.station {
//                        serversMyStations.append(station)
//                    }
//                }
                
                self.myStations = myPlaylists
                self.reloadData()
            } else {
                print("Error: ", error)
            }
        }
        
        navigationController?.showLogo = true
        showUserProfileButton = true
        stationsSegmentedControl.selectedSegmentIndex = 1
        stationsListTableView.alpha = 1
        myStationsTableView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.sharedInstance.getCurrentLocation(self) { (location, error) -> () in
            self.currentLocation = location;
        }
    }
    
    func reloadData() {
        stationsListTableView.reloadData()
        myStationsTableView.reloadData()
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
        
        
        let moveToLeft = stationsListTableView.alpha == 0
        
        
        if myStations.count == 0 {
            UIView.animateWithDuration(0.1, delay: moveToLeft ? 0.0 : 0.1, options: .CurveEaseInOut, animations: { () -> Void in
                self.myStationsEmptyView.alpha = moveToLeft ? 0 : 1
            }, completion: nil)
        }
        
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FeaturedStationsCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("FeaturedStationsCollectionViewCellIdentifier", forIndexPath: indexPath) as! FeaturedStationsCollectionViewCell
        //cell.titleLabel.text = "Title"
        //cell.subtitleLabel.text = "Subtitle"
        return cell;
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSizeMake(collectionView.frame.width, collectionView.frame.height)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myStationsTableView {
            return myStations.count
        } else {
            return stationsList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == myStationsTableView {
            let station = myStations[indexPath.row].station
            let cell:MyStationsTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyStationsTableViewCellIdentifier") as! MyStationsTableViewCell
            
            cell.station = station
            cell.nameLabel.text = station!.name
            cell.shortDescriptionLabel.text = station!.shortDescription
            
            cell.backgroundColor = UIColor.clearColor()
            return cell
            
        } else {
            let station = stationsList[indexPath.row]
            let cell:StationsListTableViewCell = tableView.dequeueReusableCellWithIdentifier("StationsListTableViewCellIdentifier") as! StationsListTableViewCell
            
            cell.station = station
            cell.nameLabel.text = station.name
            cell.shortDescriptionLabel.text = station.shortDescription
            
            cell.savedImageView.alpha = 0
            cell.saveButton.alpha = 1
            cell.removeButton.alpha = 0
            for myStation in myStations {
                if myStation.id == station.id {
                    cell.savedImageView.alpha = 1
                    cell.saveButton.alpha = 0
                    cell.removeButton.alpha = 1
                    break
                }
            }
            
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }
    
    
    @IBAction func saveStation(sender: UIButton) {
        sender.enabled = false
        if let cell = tableViewCellForSubview(sender) as? StationsListTableViewCell {
            if let station = cell.station {
//                myStations.append(station)
                self.reloadData()
            }
        }
        sender.enabled = true
    }
    
    @IBAction func removeStation(sender: UIButton) {
        sender.enabled = false
        if let cell = tableViewCellForSubview(sender) as? StationsListTableViewCell {
            if let station = cell.station {
                
                myStations = myStations.filter() { $0.id != station.id }
                
                self.reloadData()
            }
        }
        sender.enabled = true
    }
    
    func tableViewCellForSubview(subview: UIView) -> UITableViewCell? {
        if let cell = subview as? UITableViewCell {
            return cell
        }
        if let superview = subview.superview {
            if let result = tableViewCellForSubview(superview) {
                return result
            }
        }
        return nil
    }
}
