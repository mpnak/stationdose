//
//  HomeViewController.swift
//  Stationdose
//
//  Created by Developer on 11/15/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import CoreLocation
import MGSwipeTableCell
import AlamofireImage

class HomeViewController: BaseViewController {
    
    var myStations: [SavedStation]
    var stationsList: [Station]
    var featuredStations: [Station]
    var sponsoredStations: [Station]
    var currentLocation: CLLocation?
    var selectedSavedStation: SavedStation?
    var selectedStation: Station?
    var featuredStationsTimer: NSTimer?
    
    @IBOutlet weak var featuredStationsCollectionView: UICollectionView!
    @IBOutlet weak var sponsoredImageView: UIImageView!
    @IBOutlet weak var tablesViewContaignerHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var featuresStationsPageControl: UIPageControl!
    @IBOutlet weak var stationsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myStationsEmptyView: UIView!
    @IBOutlet weak var myStationsTableView: UITableView!
    @IBOutlet weak var stationsListTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        stationsList = ModelManager.sharedInstance.stations
        featuredStations = []
        myStations = ModelManager.sharedInstance.savedStations
//        featuredStations = ModelManager.sharedInstance.featuredStations
        if(ModelManager.sharedInstance.featuredStations.count>0){
            featuredStations = Array(count: 5, repeatedValue: ModelManager.sharedInstance.featuredStations.first!)
        }

        
        sponsoredStations = ModelManager.sharedInstance.sponsoredStations
        
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadPlaylists", name: ModelManagerNotificationKey.SavedStationsDidReloadFromServer.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadStations", name: ModelManagerNotificationKey.StationsDidReloadFromServer.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadPlaylists", name: ModelManagerNotificationKey.AllDataDidReloadFromServer.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadStations", name: ModelManagerNotificationKey.AllDataDidReloadFromServer.rawValue, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showUserProfileButton = true;
        
        featuresStationsPageControl.numberOfPages = featuredStations.count
        reloadSponsoredStations()
        
        showUserProfileButton = true
        stationsSegmentedControl.selectedSegmentIndex = myStations.count > 0 ? 0 : 1
        stationsListTableView.alpha = 1
        myStationsTableView.alpha = 0
        
        reloadData()
        
        //featuredStationsTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "featuredStationsTimerStep", userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.sharedInstance.getCurrentLocation(self) { (location, error) -> () in
            self.currentLocation = location;
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ModelManagerNotificationKey.SavedStationsDidChange.rawValue, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadData", name: ModelManagerNotificationKey.SavedStationsDidChange.rawValue, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PlaylistViewController {
            destinationViewController.savedStation = selectedSavedStation
            destinationViewController.station = selectedStation
            
            
            
        }
    
    }
    
    func featuredStationsTimerStep() {
        let indexPath = featuredStationsCollectionView.indexPathForItemAtPoint(CGPoint(x: featuredStationsCollectionView.contentOffset.x + 1, y: 1))
        var nextIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if indexPath?.row < featuredStations.count - 1 {
            nextIndexPath = NSIndexPath(forRow: (indexPath?.row)! + 1, inSection: 0)
        } else {
            featuredStationsTimer?.invalidate()
        }
        featuredStationsCollectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
    }
    
    func reloadSponsoredStations(){
        
        let sponsoredStation = sponsoredStations.first
        
        if let sponsoredUrl = sponsoredStation?.art{
            let URL = NSURL(string: sponsoredUrl)!
            sponsoredImageView.af_setImageWithURL(URL)
        }
    }
    
    func reloadPlaylists() {
        myStations = ModelManager.sharedInstance.savedStations
        myStationsTableView.reloadData()
        stationsListTableView.reloadData()
        reloadTablesViewContaignerHeight()
    }
    
    func reloadStations() {
        stationsList = ModelManager.sharedInstance.stations
        stationsListTableView.reloadData()
        reloadTablesViewContaignerHeight()
    }
    
    func reloadTablesViewContaignerHeight() {
        let stationsListTableViewHeight = CGFloat(stationsList.count) * stationsListTableView.rowHeight
        let myStationsTableViewHeight = CGFloat(myStations.count) * myStationsTableView.rowHeight
        let myStationsEmptyViewHeight = myStationsEmptyView.frame.size.height
        
        tablesViewContaignerHeightLayoutConstraint.constant = max(max(stationsListTableViewHeight, myStationsTableViewHeight), myStationsEmptyViewHeight)
    }
    
    func reloadData() {
        
        myStations = ModelManager.sharedInstance.savedStations
        stationsList = ModelManager.sharedInstance.stations
        
        let showMyStations = stationsSegmentedControl.selectedSegmentIndex == 0
        
        if showMyStations {
            self.stationsListTableView.alpha = 0
            if myStations.count == 0 {
                self.myStationsEmptyView.alpha = 1
                self.myStationsTableView.alpha = 0
            } else {
                self.myStationsEmptyView.alpha = 0
                self.myStationsTableView.alpha = 1
            }
        } else {
            self.myStationsEmptyView.alpha = 0
            self.myStationsTableView.alpha = 0
            self.stationsListTableView.alpha = 1
        }
        
        stationsListTableView.reloadData()
        myStationsTableView.reloadData()
        reloadTablesViewContaignerHeight()
    }
    
    @IBAction func showSponsoredStationAction(sender: AnyObject) {
        selectedStation = sponsoredStations.first
        let fullscreenView = FullScreenLoadingView()

        fullscreenView.show()
        
        SongSortApiManager.sharedInstance.generateStationTracks((selectedStation!.id)!, onCompletion: { (tracks, error) -> Void in
            if let tracks = tracks {
                self.selectedStation!.tracks = tracks
                self.performSegueWithIdentifier("ToFeaturedStationViewController", sender: nil)
                fullscreenView.hide()
                
                
            }
        })
        
    }
    
    @IBAction func showFeaturedStationAction(sender: UIButton) {
        
        if let cell = self.collectionViewCellForSubview(sender) {
            if let cell = cell as? FeaturedStationsCollectionViewCell {
                if let station = cell.station {
                    selectedStation = station
                    let fullscreenView = FullScreenLoadingView()
                    fullscreenView.show()
                    
                    SongSortApiManager.sharedInstance.generateStationTracks((selectedStation!.id)!, onCompletion: { (tracks, error) -> Void in
                        if let tracks = tracks {
                            self.selectedStation!.tracks = tracks
                            self.performSegueWithIdentifier("ToFeaturedStationViewController", sender: nil)
                            fullscreenView.hide()
                            
                            
                        }
                    })
                }
            }
        }
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
        
        closeTableViewSwipeButtons(myStationsTableView, animated:true)
        closeTableViewSwipeButtons(stationsListTableView, animated:true)
        
        animateStationsTableTransition(moveToLeft, completion:{ () -> Void in
            self.stationsListTableView.alpha = moveToLeft ? 1 : 0
            self.stationsSegmentedControlValueChangedEnabled = true
        })
    }
    
    func closeTableViewSwipeButtons(tableview: UITableView, animated: Bool) {
        for cell in tableview.visibleCells {
            if let cell = cell as? MGSwipeTableCell {
                cell.hideSwipeAnimated(animated)
            }
        }
    }
    
    var animateStationsTableCounter: Int?
    func animateStationsTableTransition(moveToLeft: Bool, completion: () -> Void) {
        
        let rightTable = stationsListTableView
        let leftTable = myStationsTableView
        
        let leftInitialTranslation = moveToLeft ? CGFloat(0.0) : -leftTable.frame.size.width
        let leftTargetTranslation = moveToLeft ? -leftTable.frame.size.width : CGFloat(0.0)
        
        animateStationsTableCounter = (leftTable.visibleCells.count>0 ? 1 : 0) + (rightTable.visibleCells.count>0 ? 1 : 0)
        
        if animateStationsTableCounter == 0 {
            completion()
            return
        }
        
        animateTableCells(leftTable, currentTranslation: leftInitialTranslation, translationTarget: leftTargetTranslation) { () -> Void in
            if leftTargetTranslation != 0 {
                leftTable.alpha = 0
                for var i=0; i<leftTable.visibleCells.count; i++ {
                    let cell = leftTable.visibleCells[i]
                    cell.layer.transform = CATransform3DIdentity
                }
            }
            if --self.animateStationsTableCounter! == 0 {
                completion()
            }
            
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
            if --self.animateStationsTableCounter! == 0 {
                completion()
            }
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
        if scrollView.dragging {
            featuredStationsTimer?.invalidate()
        }
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
        return featuredStations.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FeaturedStationsCollectionViewCellIdentifier", forIndexPath: indexPath) as! FeaturedStationsCollectionViewCell
        cell.station = featuredStations[indexPath.row]
        cell.titleLabel.text = cell.station!.name
        cell.subtitleLabel.text = cell.station!.shortDescription
        if let featuredUrl = cell.station!.art {
            let URL = NSURL(string: featuredUrl)!
            
            cell.backgroundImage.af_setImageWithURL(URL)
        }
        
        return cell;
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        return CGSizeMake(collectionView.frame.width, collectionView.frame.height)
    }
    
    func collectionViewCellForSubview(subview: UIView) -> UICollectionViewCell? {
        if let cell = subview as? UICollectionViewCell {
            return cell
        }
        if let superview = subview.superview {
            if let result = collectionViewCellForSubview(superview) {
                return result
            }
        }
        return nil
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
            let savedStation = myStations[indexPath.row]
            let station = savedStation.station
            let cell:MyStationsTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyStationsTableViewCellIdentifier") as! MyStationsTableViewCell
            
            cell.station = station
            cell.savedStation = savedStation
            cell.nameLabel.text = station!.name
            cell.shortDescriptionLabel.text = station!.shortDescription
            
            cell.backgroundColor = UIColor.clearColor()
            
            let deleteButton = MGSwipeButton(title: nil, icon: UIImage(named: "btn-delete-station"), backgroundColor: UIColor.customWarningColor(), callback: { (cell) -> Bool in
                ModelManager.sharedInstance.removeSavedStation(savedStation) { (removed) -> Void in
                    if removed {
                        self.reloadPlaylists()
                        
                    } else {
                        cell.hideSwipeAnimated(true)
                    }
                }
                return false
            })
            deleteButton.setPadding(0)
            cell.rightButtons = [deleteButton]
            cell.rightSwipeSettings.transition = .Drag
            
            cell.touchUpInsideAction = {
                self.showStation(cell)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    cell.setSelected(false, animated: true)
                }
                
            }
            
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
            for savedStation in myStations {
                if savedStation.station!.id == station.id {
                    cell.savedImageView.alpha = 1
                    cell.saveButton.alpha = 0
                    cell.removeButton.alpha = 1
                    break
                }
            }
            
            cell.backgroundColor = UIColor.clearColor()
            
            cell.removedMessageView.alpha = 0
            cell.addedMessageView.alpha = 0
            
            cell.touchUpInsideAction = {
                self.showStation(cell)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    cell.setSelected(false, animated: true)
                }
            }
            
            return cell
        }
    }
    
    @IBAction func showStation(sender: UIView) {
        selectedSavedStation = nil
        selectedStation = nil
        if let cell = self.tableViewCellForSubview(sender) as? StationsListTableViewCell {
            if let station = cell.station {
                selectedStation = station
            }
        } else if let cell = self.tableViewCellForSubview(sender) as? MyStationsTableViewCell {
            if let station = cell.savedStation {
                selectedSavedStation = station
            }
        }
        
        if selectedStation != nil || selectedSavedStation != nil {
                if let savedStation = self.selectedSavedStation where savedStation.tracks == nil {
                    moveToSavedStationPlaylist()
                }
                else if let station = self.selectedStation{
                    
                    for savedStation in myStations {
                        if savedStation.station!.id == station.id {
                            self.selectedSavedStation = savedStation
                            
                            break
                        }
                    }
                    if let savedStation = self.selectedSavedStation where savedStation.tracks == nil {
                        moveToSavedStationPlaylist()
                    }else if let _ = self.selectedSavedStation{
                        self.performSegueWithIdentifier("ToPlaylistViewController", sender: nil)
                    }else{
                        moveToStationPlaylist()
                    }
                }else{
                    self.performSegueWithIdentifier("ToPlaylistViewController", sender: nil)
                }
            
        }
        
    }
    
    func moveToSavedStationPlaylist(){
        let fullscreenView = FullScreenLoadingView()
        

            fullscreenView.show()
            SongSortApiManager.sharedInstance.generateSavedStationTracks((selectedSavedStation!.id)!, onCompletion: { (tracks, error) -> Void in
                if let tracks = tracks {
                    self.selectedSavedStation!.tracks = tracks
                    self.performSegueWithIdentifier("ToPlaylistViewController", sender: nil)
                    
                    fullscreenView.hide()
                    
                }
            })
        
    }
    
    func moveToStationPlaylist(){
        let fullscreenView = FullScreenLoadingView()
        fullscreenView.show()
        
        SongSortApiManager.sharedInstance.generateStationTracks((selectedStation!.id)!, onCompletion: { (tracks, error) -> Void in
            if let tracks = tracks {
                self.selectedStation!.tracks = tracks
                self.performSegueWithIdentifier("ToPlaylistViewController", sender: nil)
                fullscreenView.hide()
                
                
            }
        })
    }
    
    @IBAction func saveStation(sender: UIButton) {
        sender.enabled = false
        if let cell = tableViewCellForSubview(sender) as? StationsListTableViewCell {
            if let station = cell.station {
                
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    cell.addedMessageView.alpha = 1
                    }, completion: { (_) -> Void in
                        UIView.animateWithDuration(0.1, delay: 1.5, options: .CurveEaseInOut, animations: { () -> Void in
                            cell.addedMessageView.alpha = 0
                            }, completion:nil)
                })
                
                cell.saveButton.alpha = 0
                cell.removeButton.alpha = 1
                cell.savedImageView.alpha = 1
                
                ModelManager.sharedInstance.saveStation(station, onCompletion: { (success) -> Void in
                    sender.enabled = true
                    self.reloadPlaylists()
                })
            } else {
                sender.enabled = true
            }
        }
    }
    
    @IBAction func removeStation(sender: UIButton) {
        sender.enabled = false
        
        if let cell = self.tableViewCellForSubview(sender) as? StationsListTableViewCell {
            if let station = cell.station {
                
                let savedStationsToRemove = myStations.filter { $0.station?.id == station.id}
                
                ModelManager.sharedInstance.removeSavedStation(savedStationsToRemove.first!) { (removed) -> Void in
                    sender.enabled = true
                    if removed {
                        cell.saveButton.alpha = 1
                        cell.removeButton.alpha = 0
                        cell.savedImageView.alpha = 0
                        
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                                cell.removedMessageView.alpha = 1
                            }, completion: { (_) -> Void in
                                UIView.animateWithDuration(0.1, delay: 1.5, options: .CurveEaseInOut, animations: { () -> Void in
                                        cell.removedMessageView.alpha = 0
                                    }, completion:nil)
                        })
                        
                        self.reloadPlaylists()
                    }
                }
            } else {
                sender.enabled = true
            }
        }
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