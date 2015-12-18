//
//  PlaylistViewController.swift
//  Stationdose
//
//  Created by Developer on 12/1/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class PlaylistViewController: BaseViewController {
    
    var savedStation:SavedStation?
    var station:Station?
    var tracks:[Track]!
    let fullscreenView = FullScreenLoadingView()
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var tracksTableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var savedImageView: UIImageView!
    
    @IBOutlet weak var weatherButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var rightButtonsLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftButtonsLayoutConstraint: NSLayoutConstraint!
    
    let rightButtonsLayoutConstraintConstantForStation:CGFloat = -95.0
    let rightButtonsLayoutConstraintConstantForSavedStation:CGFloat = 7.0
    let leftButtonsLayoutConstraintConstantForStation:CGFloat = -38.0
    let leftButtonsLayoutConstraintConstantForSavedStation:CGFloat = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"willStartSavedStationTracksReGeneration:", name: ModelManagerNotificationKey.WillStartSavedStationTracksReGeneration.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"didEndSavedStationTracksReGeneration:", name: ModelManagerNotificationKey.DidEndSavedStationTracksReGeneration.rawValue, object: nil)
        
        showBrandingTitleView()
        showUserProfileButton()
        
        nameLabel?.text = station?.name
        shortDescriptionLabel?.text = station?.shortDescription
        if let url = station?.url {
            urlLabel?.text = url.stringByReplacingOccurrencesOfString("http://", withString: "").stringByReplacingOccurrencesOfString("https://", withString: "")
        }
        
        if let featuredUrl = station?.art {
            let URL = NSURL(string: featuredUrl)!
            bannerImageView?.af_setImageWithURL(URL)
            coverImageView?.af_setImageWithURL(URL, placeholderImage: UIImage(named: "station-placeholder"))
        } else {
            coverImageView.image = UIImage(named: "station-placeholder")
        }
        
        saveButton?.alpha = savedStation == nil ? 1 : 0
        removeButton?.alpha = savedStation == nil ? 0 : 1
        savedImageView?.alpha = savedStation == nil ? 0 : 1
        
        rightButtonsLayoutConstraint?.constant = savedStation == nil ? rightButtonsLayoutConstraintConstantForStation : rightButtonsLayoutConstraintConstantForSavedStation
        leftButtonsLayoutConstraint?.constant = savedStation == nil ? leftButtonsLayoutConstraintConstantForStation : leftButtonsLayoutConstraintConstantForSavedStation
        
        if let savedStation = savedStation {
            updateWeatherIcon(savedStation)
            updateTimeIcon(savedStation)

            tracks = []
            if let theTracks = savedStation.tracks{
                tracks = theTracks
            }else{
                SongSortApiManager.sharedInstance.generateSavedStationTracks((savedStation.id)!, onCompletion: { (tracks, error) -> Void in
                    if let tracks = tracks {
                        self.tracks = tracks
                        self.tracksTableView.reloadData()
                        
                    }
                })
            }
        } else {
            
            if let theTracks = station?.tracks{
                tracks = theTracks
                self.tracksTableView.reloadData()
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func updateWeatherIcon(savedStation:SavedStation){
        if let useWeather = savedStation.useWeather where useWeather{
            weatherButton.setImage(UIImage(named: "btn-weather"), forState: .Normal)
        }else{
            weatherButton.setImage(UIImage(named: "btn-weather-off"), forState: .Normal)
        }
    }
    
    func updateTimeIcon(savedStation:SavedStation){
        if let useTime = savedStation.useTimeofday where useTime{
            timeButton.setImage(UIImage(named: "btn-time"), forState: .Normal)
        }else{
            timeButton.setImage(UIImage(named: "btn-time-off"), forState: .Normal)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func willStartSavedStationTracksReGeneration(notification:NSNotification){
        if let notifInfo = notification.object as? Dictionary<String,Int>, id = notifInfo["id"] where self.savedStation?.id == id {
            fullscreenView.setMessage("Just a moment, we’re generating your playlist")
            fullscreenView.show(0)
        }
        
    }
    
    func didEndSavedStationTracksReGeneration(notification:NSNotification){
        if let notifInfo = notification.object as? Dictionary<String,Int>, id = notifInfo["id"] where self.savedStation?.id == id {
            
            self.tracks = self.savedStation!.tracks
            self.tracksTableView.reloadData()
            
            fullscreenView.hide(1.5)
        }
    }
    
    @IBAction func openStationUrl(sender: UIButton) {
        if let urlString = station?.url {
            if let url = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    @IBAction func removeStation(sender: UIButton) {
        sender.enabled = false
        
        ModelManager.sharedInstance.removeSavedStation(savedStation!) { (removed) -> Void in
            sender.enabled = true
            if removed {
                self.savedStation = nil
                
                self.saveButton.alpha = 1
                self.removeButton.alpha = 0
                self.savedImageView.alpha = 0
                
                self.rightButtonsLayoutConstraint?.constant = self.rightButtonsLayoutConstraintConstantForStation
                self.leftButtonsLayoutConstraint?.constant = self.leftButtonsLayoutConstraintConstantForStation
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    @IBAction func forceRefresh(sender: UIButton) {
        ModelManager.sharedInstance.forceGenerateSavedStationTracks(self.savedStation!){
        }
        
    }
    
    
    @IBAction func toggleWeather(sender: UIButton) {
        
        
        
        if let savedStation = self.savedStation{
            

            
            savedStation.toggleWeather()
            updateWeatherIcon(savedStation)
            showAlertFirstTimeAndSaveStation(savedStation)

        }

        
    }
    
    @IBAction func toggleUseTime(sender: UIButton) {
        
        
        
        if let savedStation = savedStation{
            
            savedStation.toggleTime()

            updateTimeIcon(savedStation)
            showAlertFirstTimeAndSaveStation(savedStation)
        }

    }
    
    @IBAction func saveStation(sender: UIButton) {
        sender.enabled = false
        
        ModelManager.sharedInstance.saveStation(station!) { (saved, savedStation) -> Void in
            sender.enabled = true
            if saved {
                self.savedStation = savedStation
                
                self.saveButton.alpha = 0
                self.removeButton.alpha = 1
                self.savedImageView.alpha = 1
                
                self.rightButtonsLayoutConstraint?.constant = self.rightButtonsLayoutConstraintConstantForSavedStation
                self.leftButtonsLayoutConstraint?.constant = self.leftButtonsLayoutConstraintConstantForSavedStation
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? EditStationViewController {
            destinationViewController.savedStation = savedStation
        }
    }
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func like()->MGSwipeButton{
        return MGSwipeButton(title: nil, icon: UIImage(named: "btn-like-track"), backgroundColor: UIColor.customToggleOnColor(), callback: { (cell) -> Bool in
            
            if let cell = cell as? TrackTableViewCell {
                if cell.track.liked == nil || !cell.track.liked! {
                    SongSortApiManager.sharedInstance.favoriteTrack(self.savedStation!.station!.id!,savedStationId: (self.savedStation?.id)!, trackId: cell.track.id!)
                    cell.likedImageView.alpha = 1
                    cell.track.liked = true
                    cell.leftButtons = [self.unlike()]
                    self.tracksTableView.beginUpdates()
                    let indexPath = self.tracksTableView.indexPathForCell(cell)
                    self.tracksTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                    self.tracksTableView.endUpdates()
                    
                    
                    
                }
            }
            return true
        })
    }
    
    func unlike()->MGSwipeButton{
        return MGSwipeButton(title: nil, icon: UIImage(named: "btn-unlike-track"), backgroundColor: UIColor.customToggleOnColor(), callback: { (cell) -> Bool in
            
            if let cell = cell as? TrackTableViewCell {
                if cell.track.liked! {
                    SongSortApiManager.sharedInstance.unfavoriteTrack(self.savedStation!.station!.id!,savedStationId: (self.savedStation?.id)!, trackId: cell.track.id!)
                    cell.likedImageView.alpha = 0
                    cell.track.liked = false
                    cell.leftButtons = [self.like()]
                    self.tracksTableView.beginUpdates()
                    let indexPath = self.tracksTableView.indexPathForCell(cell)
                    self.tracksTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                    self.tracksTableView.endUpdates()
                    
                }
            }
            return true
        })
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackTableViewCellIdentifier") as! TrackTableViewCell
        
        cell.track = tracks![indexPath.row]
        cell.validatePlaying()
        
        cell.titleLabel.text = cell.track?.title
        cell.subtitleLabel.text = cell.track?.artist
        
        cell.touchUpInsideAction = {
            var tracks = [Track]()
            var addTacks = false
            for track in self.tracks {
                if track.id == cell.track.id {
                    addTacks = true
                }
                if addTacks {
                    tracks.append(track)
                }
            }
            
            PlaybackManager.sharedInstance.playTracks(tracks, callback: { (error) -> () in })
            
            self.station?.isPlaying = true
        }
        
        if let liked = cell.track.liked {
            cell.likedImageView.alpha = liked ? 1 : 0
        } else {
            cell.likedImageView.alpha = 0
        }
        
        if savedStation != nil {
            
            let deleteButton = MGSwipeButton(title: nil, icon: UIImage(named: "btn-delete-track"), backgroundColor: UIColor.customWarningColor(), callback: { (cell) -> Bool in
                if let cell = cell as? TrackTableViewCell {
                    SongSortApiManager.sharedInstance.banTrack(self.savedStation!.station!.id!,savedStationId: (self.savedStation?.id)!, trackId: cell.track.id!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if let tracks = self.tracks {
                            var index: Int?
                            for var i = 0; i<tracks.count; i++ {
                                if cell.track?.id == tracks[i].id {
                                    index = i
                                    break
                                }
                            }
                            
                            if let index = index {
                                self.tracksTableView.beginUpdates()
                                self.tracksTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Middle)
                                self.tracks?.removeAtIndex(index)
                                self.tracksTableView.endUpdates()
                            }
                            
                            PlaybackManager.sharedInstance.removeTrack(cell.track)
                        }
                        
                    })
                }
                
                return false
            })
            deleteButton.setPadding(0)
            cell.rightButtons = [deleteButton]
            cell.rightSwipeSettings.transition = .Drag
            
            if cell.likedImageView.alpha == 0 {
                
                let likeButton = like()
                likeButton.setPadding(0)
                cell.leftButtons = [likeButton]
                cell.leftSwipeSettings.transition = .Drag
            }else{
                let unLikeButton = unlike()
                unLikeButton.setPadding(0)
                cell.leftButtons = [unLikeButton]
                cell.leftSwipeSettings.transition = .Drag
            }
            
        } else {
            cell.rightButtons = nil
            cell.leftButtons = nil
        }
        
        return cell
    }
}
