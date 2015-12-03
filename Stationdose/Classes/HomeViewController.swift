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
    
    @IBOutlet weak var sponsoredImageView: UIImageView!
    
    var myStations: [Playlist]
    var stationsList: [Station]
    var featuredStations: [Station]
    var sponsoredStations: [Station]
    var currentLocation: CLLocation?
    var selectedPlaylist: Playlist?
    
    @IBOutlet weak var featuresStationsPageControl: UIPageControl!
    @IBOutlet weak var stationsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myStationsEmptyView: UIView!
    @IBOutlet weak var myStationsTableView: UITableView!
    @IBOutlet weak var stationsListTableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        stationsList = ModelManager.sharedInstance.stations
        myStations = ModelManager.sharedInstance.playlists
        featuredStations = ModelManager.sharedInstance.featuredStations
        sponsoredStations = ModelManager.sharedInstance.sponsoredStations
        
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadPlylists", name: ModelManagerNotificationKey.PlaylistsDidChange.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadStations", name: ModelManagerNotificationKey.StationsDidChange.rawValue, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        featuresStationsPageControl.numberOfPages = featuredStations.count
        reloadSponsoredStations()
        
        navigationController?.showLogo = true
        showUserProfileButton = true
        stationsSegmentedControl.selectedSegmentIndex = myStations.count > 0 ? 0 : 1
        stationsListTableView.alpha = 1
        myStationsTableView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.sharedInstance.getCurrentLocation(self) { (location, error) -> () in
            self.currentLocation = location;
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PlaylistViewController {
            destinationViewController.playlist = selectedPlaylist
        }
    }
    
    func  reloadSponsoredStations(){
        
        let sponsoredStation = sponsoredStations.first
        
        if let sponsoredUrl = sponsoredStation?.art{
            let URL = NSURL(string: sponsoredUrl)!
            
            sponsoredImageView.af_setImageWithURL(URL)
        }
        

    }
    
    func reloadPlylists() {
        self.myStations = ModelManager.sharedInstance.playlists
        self.myStationsTableView.reloadData()
    }
    
    func reloadStations() {
        self.stationsList = ModelManager.sharedInstance.stations
        self.stationsListTableView.reloadData()
    }
    
    func reloadData() {
        
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
        return featuredStations.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FeaturedStationsCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("FeaturedStationsCollectionViewCellIdentifier", forIndexPath: indexPath) as! FeaturedStationsCollectionViewCell
        let station = featuredStations[indexPath.row]
        cell.titleLabel.text = station.name
        cell.subtitleLabel.text = station.shortDescription
        if let featuredUrl = station.art{
            let URL = NSURL(string: featuredUrl)!
            
            cell.backgroundImage.af_setImageWithURL(URL)
        }
        
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
            
            let deleteButton = MGSwipeButton(title: nil, icon: UIImage(named: "btn-delete-station"), backgroundColor: UIColor.customWarningColor(), callback: { (cell) -> Bool in
                self.removeStation(station!) { (removed) -> Void in
                    if removed {
                        self.reloadData()
                    } else {
                        cell.hideSwipeAnimated(true)
                    }
                }
                return false
            })
            cell.rightButtons = [deleteButton]
            cell.rightSwipeSettings.transition = .Drag
            
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
            cell.nextButton.alpha = 0
            for playlist in myStations {
                if playlist.station!.id == station.id {
                    cell.savedImageView.alpha = 1
                    cell.saveButton.alpha = 0
                    cell.removeButton.alpha = 1
                    cell.nextButton.alpha = 1
                    break
                }
            }
            
            cell.backgroundColor = UIColor.clearColor()
            
            cell.removedMessageView.alpha = 0
            cell.addedMessageView.alpha = 0
            
            return cell
        }
    }
    
    @IBAction func showStation(sender: UIButton) {
        selectedPlaylist = nil
        if let cell = self.tableViewCellForSubview(sender) as? StationsListTableViewCell {
            if let station = cell.station {
                for playlist in myStations {
                    if playlist.station?.id == station.id {
                        selectedPlaylist = playlist
                    }
                }
            }
        } else if let cell = self.tableViewCellForSubview(sender) as? MyStationsTableViewCell {
            if let station = cell.station {
                for playlist in myStations {
                    if playlist.station?.id == station.id {
                        selectedPlaylist = playlist
                    }
                }
            }
        }
        if selectedPlaylist != nil {
            performSegueWithIdentifier("ToPlaylistViewController", sender: nil)
        }
        
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
                
                ModelManager.sharedInstance.savePlaylist(station.id!, onCompletion: { (success) -> Void in
                    sender.enabled = true
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
                removeStation(station) { (removed) -> Void in
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
                        
                        self.myStationsTableView.reloadData()
                    }
                }
            } else {
                sender.enabled = true
            }
        }
    }
    
    func removeStation(station: Station, callback: (removed:Bool) -> Void) {
        AlertView(title: "Remove Station?", message: "Are tou sure you want to remove this station from your favorites", acceptButtonTitle: "Yes", cancelButtonTitle: "Nevermind", callback: { (accept) -> Void in
            if accept {
                let playlistsToDelete = self.myStations.filter() { $0.station!.id == station.id }
                
                for playlistToDelete in playlistsToDelete {
                    SongSortApiManager.sharedInstance.removePlaylist(playlistToDelete.id!)
                }
                self.myStations = self.myStations.filter() { $0.station!.id != station.id }
                
                callback(removed:true)
            } else {
                callback(removed:false)
            }
        }).show()
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

extension HomeViewController: UITableViewDelegate {

}