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
    
    var currentLocation: CLLocation?
    var featuredStationsTimer: NSTimer?
    
    var myStations: [Station]
    var stationsList: [Station]
    var featuredStations: [Station]
    var sponsoredStations: [Station]
    
    var selectedStation: Station?
    private let fullscreenView = FullScreenLoadingView()
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var featuredStationsCollectionView: UICollectionView!
    @IBOutlet weak var sponsoredImageView: UIImageView!
    @IBOutlet weak var tablesViewContaignerHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var featuresStationsPageControl: UIPageControl!
    @IBOutlet weak var stationsSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var myStationsContainerView: UIView?
    @IBOutlet weak var stationsListContainerView: UIView?
    var originalTableViewHeight: CGFloat = 0.0
    
    var myStationsCollectionViewController: MyStationsCollectionViewController?
    var stationsListTableViewController: StationsListTableViewController?
    
    required init?(coder aDecoder: NSCoder) {
        stationsList = ModelManager.sharedInstance.stations
        featuredStations = []
        myStations = ModelManager.sharedInstance.savedStations
        featuredStations = ModelManager.sharedInstance.featuredStations
        sponsoredStations = ModelManager.sharedInstance.sponsoredStations
        
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.reloadPlaylists as (HomeViewController) -> () -> ()), name: ModelManagerNotificationKey.StationsDidReloadFromServer.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.reloadStations), name: ModelManagerNotificationKey.StationsDidReloadFromServer.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.reloadPlaylists as (HomeViewController) -> () -> ()), name: ModelManagerNotificationKey.AllDataDidReloadFromServer.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.reloadStations), name: ModelManagerNotificationKey.AllDataDidReloadFromServer.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.stationDidChangeModifiers(_:)), name: ModelManagerNotificationKey.StationDidChangeModifiers.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.stationDidChangeUpdatedAt(_:)), name: ModelManagerNotificationKey.DidUpdatePlaylistTracks.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.stationDidChangeUpdatedAt(_:)), name: ModelManagerNotificationKey.DidEndStationTracksReGeneration.rawValue, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showBrandingTitleView()
        self.showUserProfileButton()
        
        originalTableViewHeight = tablesViewContaignerHeightLayoutConstraint.constant
        
        self.featuresStationsPageControl.numberOfPages = self.featuredStations.count
        self.reloadSponsoredStations()
        
        self.stationsSegmentedControl.selectedSegmentIndex = self.myStations.count > 0 ? 0 : 1
        
        self.reloadData()
        
        self.featuredStationsTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(HomeViewController.featuredStationsTimerStep), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.sharedInstance.getCurrentLocation(self) { (location, error) -> () in
            self.currentLocation = location
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ModelManagerNotificationKey.StationsDidChange.rawValue, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.reloadData), name: ModelManagerNotificationKey.StationsDidChange.rawValue, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PlaylistBaseViewController {
            if LocationManager.sharedInstance.isEnabled {}
            destinationViewController.station = selectedStation
        }
        if let cvc = segue.destinationViewController as? MyStationsCollectionViewController {
            myStationsCollectionViewController = cvc
            myStationsCollectionViewController!.parentController = self
        }
        if let vc = segue.destinationViewController as? StationsListTableViewController {
            stationsListTableViewController = vc
            stationsListTableViewController!.parentController = self
        }
        selectedStation = nil
    }
    
    func stationDidChangeModifiers(notification:NSNotification) {
        myStationsCollectionViewController?.collectionView?.reloadData()
    }
    
    func stationDidChangeUpdatedAt(notification:NSNotification) {
        myStationsCollectionViewController?.collectionView?.reloadData()
    }
    
    func featuredStationsTimerStep() {
        let indexPath = featuredStationsCollectionView.indexPathForItemAtPoint(CGPoint(x: featuredStationsCollectionView.contentOffset.x + 1, y: 1))
        var nextIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        if indexPath?.row != nil {
            if indexPath?.row < featuredStations.count - 1 {
                nextIndexPath = NSIndexPath(forRow: (indexPath?.row)! + 1, inSection: 0)
            } else {
                featuredStationsTimer?.invalidate()
                return
            }
        } else {
            featuredStationsTimer?.invalidate()
            return
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
    
    func reloadPlaylists(andStationsList: Bool) {
        myStations = ModelManager.sharedInstance.savedStations
        myStationsCollectionViewController?.collectionView?.reloadData()
        if andStationsList {
            stationsListTableViewController?.tableView.reloadData()
        }
        reloadTablesViewContaignerHeight()
    }
    
    func reloadPlaylists() {
        if myStationsCollectionViewController == nil {
            return
        }
        reloadPlaylists(true)
    }
    
    func reloadStations() {
        if stationsListTableViewController == nil {
            return
        }
        stationsList = ModelManager.sharedInstance.stations
        stationsListTableViewController?.tableView.reloadData()
        reloadTablesViewContaignerHeight()
    }
    
    func reloadTablesViewContaignerHeight() {
        reloadTablesViewContaignerHeight(0, delay: 0)
    }
        
    func reloadTablesViewContaignerHeight(animationDuration: NSTimeInterval, delay: NSTimeInterval) {
        let emptyViewHeight = originalTableViewHeight
        if stationsSegmentedControl.selectedSegmentIndex == 0 {
            self.myStationsCollectionViewController?.view.setNeedsLayout()
            self.myStationsCollectionViewController?.view.layoutIfNeeded()
            tablesViewContaignerHeightLayoutConstraint.constant = max(self.myStationsCollectionViewController!.collectionView!.contentSize.height, emptyViewHeight)
        } else {
            self.stationsListTableViewController?.tableView.setNeedsLayout()
            self.stationsListTableViewController?.tableView.layoutIfNeeded()
            tablesViewContaignerHeightLayoutConstraint.constant = max(self.stationsListTableViewController!.tableView.contentSize.height, emptyViewHeight)
        }
        UIView.animateWithDuration(animationDuration, delay: delay, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func reloadData() {
        myStations = ModelManager.sharedInstance.savedStations
        stationsList = ModelManager.sharedInstance.stations
        
        self.stationsListContainerView?.hidden = stationsSegmentedControl.selectedSegmentIndex == 0
        self.stationsListContainerView?.userInteractionEnabled = stationsSegmentedControl.selectedSegmentIndex == 1
        
        stationsListTableViewController?.tableView.reloadData()
        myStationsCollectionViewController?.collectionView?.reloadData()
        reloadTablesViewContaignerHeight()
    }
    
    @IBAction func showSponsoredStationAction(sender: AnyObject) {
        selectedStation = sponsoredStations.first
        let fullscreenView = FullScreenLoadingView()
        fullscreenView.show(0.5)
        SongSortApiManager.sharedInstance.generateStationTracks((selectedStation!), onCompletion: { (_station, error) -> Void in
            if let tracks = _station?.tracks {
                self.selectedStation!.tracks = tracks
                self.performSegueWithIdentifier("ToFeaturedStationViewController", sender: nil)
                fullscreenView.hide(1.5)
            }
        })
        
    }
    
    @IBAction func showFeaturedStationAction(sender: UIButton) {
        if let cell = self.collectionViewCellForSubview(sender) {
            if let cell = cell as? FeaturedStationsCollectionViewCell {
                if let station = cell.station {
                    selectedStation = station
                    let fullscreenView = FullScreenLoadingView()
                    fullscreenView.show(0.5)
                    SongSortApiManager.sharedInstance.generateStationTracks((selectedStation!), onCompletion: { (_station, error) -> Void in
                        if let tracks = _station?.tracks {
                            self.selectedStation!.tracks = tracks
                            self.performSegueWithIdentifier("ToFeaturedStationViewController", sender: nil)
                            fullscreenView.hide(1.5)
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func addStations(sender: AnyObject) {
        stationsSegmentedControl.selectedSegmentIndex = 1
        stationsSegmentedControlValueChanged(stationsSegmentedControl)
    }
    
    var stationsSegmentedControlValueChangedEnabled = true
    @IBAction func stationsSegmentedControlValueChanged(sender: UISegmentedControl) {
        
        if !stationsSegmentedControlValueChangedEnabled {
            sender.selectedSegmentIndex = sender.selectedSegmentIndex == 0 ? 1 : 0
            return
        }
        stationsSegmentedControlValueChangedEnabled = false
        
        closeTableViewSwipeButtons(stationsListTableViewController!.tableView, animated:true)
        
        let moveToLeft = sender.selectedSegmentIndex == 1
        animateStationsTableTransition(moveToLeft, completion:{ () -> Void in
            self.stationsSegmentedControlValueChangedEnabled = true
            
            self.stationsListContainerView?.userInteractionEnabled = moveToLeft
        })
        
        if moveToLeft {
            self.reloadTablesViewContaignerHeight()
        } else {
            self.reloadTablesViewContaignerHeight(0.5, delay: 0.25)
        }
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
        
        let leftTable = myStationsCollectionViewController!.collectionView!
        let rightTable = stationsListTableViewController!.tableView
        
        let leftInitialTranslation1 = moveToLeft ? CGFloat(0.0) : -leftTable.frame.size.width
        let w = UIScreen.mainScreen().bounds.width/2
        let leftInitialTranslation2 = moveToLeft ? w : -leftTable.frame.size.width
        let leftTargetTranslation1 = moveToLeft ? -leftTable.frame.size.width : CGFloat(0.0)
        let leftTargetTranslation2 = moveToLeft ? -leftTable.frame.size.width : CGFloat(0.0)
        
        animateStationsTableCounter = (leftTable.visibleCells().count>0 ? 1 : 0) + (rightTable.visibleCells.count>0 ? 1 : 0)
        if animateStationsTableCounter == 0 {
            completion()
            return
        }
        
        animateCollectionCells(leftTable, currentTranslation1: leftInitialTranslation1, currentTranslation2: leftInitialTranslation2, translationTarget1: leftTargetTranslation1, translationTarget2: leftTargetTranslation2) { () -> Void in
            
            self.animateStationsTableCounter! -= 1
            if self.animateStationsTableCounter! == 0 {
                completion()
            }
            
        }
        
        let currentTranslation2 = moveToLeft ? leftTable.frame.size.width : CGFloat(0.0)
        let translationTarget2 = moveToLeft ? CGFloat(0.0) : leftTable.frame.size.width
        //setup the beginning frames before animating to targets
        for cell in self.stationsListTableViewController!.tableView.visibleCells {
            cell.layer.transform = CATransform3DMakeTranslation(currentTranslation2, 0.0, 0.0)
        }
        self.stationsListContainerView?.hidden = false
        animateTableCells(rightTable, currentTranslation: currentTranslation2, translationTarget: translationTarget2) { () -> Void in
            
            self.stationsListContainerView?.hidden = !moveToLeft
            
            for cell in self.stationsListTableViewController!.tableView.visibleCells {
                cell.layer.transform = CATransform3DIdentity
            }
            
            self.animateStationsTableCounter! -= 1
            if self.animateStationsTableCounter! == 0 {
                completion()
            }
        }
    }
    
    func animateTableCells(table: UITableView, currentTranslation: CGFloat, translationTarget: CGFloat, completion: () -> Void) {
        
        let animationBaseTime = 0.1
        
        for i in 0 ..< table.visibleCells.count {
            let cell = table.visibleCells[i]
            
            let lastCell = (i == table.visibleCells.count-1)
            
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
    
    func animateCollectionCells(table: UICollectionView, currentTranslation1: CGFloat, currentTranslation2: CGFloat, translationTarget1: CGFloat, translationTarget2: CGFloat, completion: () -> Void) {
        
        let animationBaseTime = 0.1
        
        //first we need to sort the indexPaths by row
        var paths = table.indexPathsForVisibleItems()
        paths = paths.sort { (p1, p2) -> Bool in
            return p1.row < p2.row
        }
        var cellsRemaining = paths.count
        
        for i in 0 ..< paths.count where i % 2 == 0 {
            
            let ip1 = paths[i]
            let cell1 = table.cellForItemAtIndexPath(ip1)
            cellsRemaining -= 1
            var ip2: NSIndexPath?
            var cell2: UICollectionViewCell?
            if i+1 < paths.count {
                ip2 = paths[i+1]
                cellsRemaining -= 1
                cell2 = table.cellForItemAtIndexPath(ip2!)
            }
            
            let lastRow = cellsRemaining == 0 || cellsRemaining == 1
            
            cell1!.layer.transform = CATransform3DMakeTranslation(currentTranslation1, 0.0, 0.0)
            if cell2 != nil {
                cell2!.layer.transform = CATransform3DMakeTranslation(currentTranslation2, 0.0, 0.0)
            }
            
            let delay = Double(i) * animationBaseTime
            let time = 4.0 * animationBaseTime //2.0 * animationBaseTime if the animation don't user damping
            
            UIView.animateWithDuration(time, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .CurveEaseOut, animations: { () -> Void in
                cell1!.layer.transform = CATransform3DMakeTranslation(translationTarget1, 0.0, 0.0)
                if cell2 != nil {
                    cell2!.layer.transform = CATransform3DMakeTranslation(translationTarget2, 0.0, 0.0)
                }
            }, completion: { finished -> Void in
                if lastRow {
                    
                    completion()
                }
            })
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == featuredStationsCollectionView {
            if scrollView.dragging {
                featuredStationsTimer?.invalidate()
            }
            let pageWidth = scrollView.frame.size.width
            let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1)
            featuresStationsPageControl.currentPage = page
        } else if scrollView == mainScrollView {
            scrollView.contentOffset.y = max(scrollView.contentOffset.y, 0)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuredStations.count
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
        
        return cell
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

extension HomeViewController {
    
 
    func buildWeatherButton(on:Bool)->MGSwipeButton{
        return MGSwipeButton(title: nil, icon: UIImage(named: on ? "btn-cell-weather" : "btn-cell-weather-off"), backgroundColor: UIColor.clearColor(), callback: { (cell) -> Bool in
            if let cell = cell as? MyStationsTableViewCell {
                if cell.station != nil {
                    //savedStation.useWeather = !on
                    //cell.leftButtons = [self.buildWeatherButton(!on), cell.leftButtons[1], cell.leftButtons[2]]
//                    self.myStationsTableView.beginUpdates()
//                    let indexPath = self.myStationsTableView.indexPathForCell(cell)
//                    self.myStationsTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
//                    self.myStationsTableView.endUpdates()
                    //self.showAlertFirstTimeAndSaveStation(savedStation)
                }
            }
            return true
        })
    }
    
    func buildTimeButton(on:Bool)->MGSwipeButton{
        return MGSwipeButton(title: nil, icon: UIImage(named: on ? "btn-cell-time" : "btn-cell-time-off"), backgroundColor: UIColor.clearColor(), callback: { (cell) -> Bool in
            if let cell = cell as? MyStationsTableViewCell {
//                if let savedStation = cell.station {
                if cell.station != nil {
                    //savedStation.useTimeofday = !on
                    //cell.leftButtons = [cell.leftButtons[0], self.buildTimeButton(!on), cell.leftButtons[2]]
//                    self.myStationsTableView.beginUpdates()
//                    let indexPath = self.myStationsTableView.indexPathForCell(cell)
//                    self.myStationsTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
//                    self.myStationsTableView.endUpdates()
//                    //self.showAlertFirstTimeAndSaveStation(savedStation)
                }
            }
            return true
        })
    }
    
    func showStationAtIndexPath(indexPath: NSIndexPath) {
//        selectedStation = nil
//        selectedStation = stationsList[indexPath.row]
        if(selectedStation != nil) {
            moveToStationPlaylist()
        }
    }
    
    func moveToStationPlaylist() {
        self.performSegueWithIdentifier("ToPlaylistViewController", sender: nil)
    }
}