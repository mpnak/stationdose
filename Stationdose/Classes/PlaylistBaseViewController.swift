//
//  PlaylistBaseViewController.swift
//  Stationdose
//
//  Created by Hoof on 5/19/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class PlaylistBaseViewController: BaseViewController, UIScrollViewDelegate, UITableViewDataSource {
    
    // TODO var savedStation: SavedStation?
    //var savedStation: Station?
    var station: Station?
    var tracks: [Track]!
    let fullscreenView = FullScreenLoadingView()
    var currentTrackIndex = -1
    var isPlaying = false
    
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
    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var editButton: UIButton?
    //@IBOutlet weak var weatherButton: UIButton!
    //@IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var rightButtonsLayoutConstraint: NSLayoutConstraint!
    
    var bannerViewHeight: CGFloat?
    var bannerImageEffectView: UIView?
    @IBOutlet weak var bannerView: UIView?
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var bannerControlsView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerViewHeight = bannerViewHeightConstraint?.constant
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(PlaylistViewController.willStartStationTracksReGeneration(_:)), name: ModelManagerNotificationKey.WillStartStationTracksReGeneration.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(PlaylistViewController.didEndStationTracksReGeneration(_:)), name: ModelManagerNotificationKey.DidEndStationTracksReGeneration.rawValue, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(PlaylistViewController.stationDidChangeModifiers(_:)), name: ModelManagerNotificationKey.StationDidChangeModifiers.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(PlaylistViewController.stationDidChangeUpdatedAt(_:)), name: ModelManagerNotificationKey.DidUpdatePlaylistTracks.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistViewController.playbackDidPause(_:)), name: Constants.Notifications.playbackDidPause, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistViewController.playbackDidResume(_:)), name: Constants.Notifications.playbackDidResume, object: nil)
        
        showBrandingTitleView()
        showUserProfileButton()
        nameLabel?.text = station?.name
        shortDescriptionLabel?.text = station?.shortDescription
        updatedAtLabel?.text = station?.updatedAtString()
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
        
        PlaybackManager.sharedInstance.needsStandardArtwork = false
        if station?.type == "standard" {
            PlaybackManager.sharedInstance.needsStandardArtwork = true
        }
        
        saveButton?.alpha = station?.savedStation == true ? 0 : 1
        removeButton?.alpha = station?.savedStation == true ? 1 : 0
        savedImageView?.alpha = station?.savedStation == true ? 1 : 0
        
        //        let location = LocationManager.sharedInstance.isEnabled
        //        if location{
        //            ModelManager.sharedInstance.onNexStationSaveUseTime = station?.savedStation == true ? true : ModelManager.sharedInstance.onNexStationSaveUseTime
        //            ModelManager.sharedInstance.onNexStationSaveUseWeather = station?.savedStation == true ? true : ModelManager.sharedInstance.onNexStationSaveUseWeather
        //        }
        //        if let isPlaying = station?.isPlaying where isPlaying { } else {
        //            ModelManager.sharedInstance.onNexStationSaveUseWeather = true
        //            ModelManager.sharedInstance.onNexStationSaveUseTime = true
        //        }
        
        if let _tracks = station?.tracks {
            self.tracks = _tracks
        } else {
            self.tracks = []
            //goto edit playlist view controller
            self.performSegueWithIdentifier("ToEditPlaylistViewController", sender: self)
        }
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(PlaylistViewController.share))
        self.navigationItem.rightBarButtonItem = shareButton
        
        self.view.layoutIfNeeded()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if station?.tracks != nil {
            let ip = NSIndexPath(forRow: 0, inSection: 0)
            self.tracksTableView.scrollToRowAtIndexPath(ip, atScrollPosition: .Top, animated: true)
        }
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func playButtonPressed (sender: AnyObject?) {
        if isPlaying {
            PlaybackManager.sharedInstance.pauseFromMain()
            self.station?.isPlaying = false
            self.isPlaying = false
            self.playButton?.setImage(UIImage(named:"btn-play-list"), forState: .Normal)
        } else {
            if currentTrackIndex < 0 {
                currentTrackIndex = 0
                var tracks = [Track]()
                tracks.append(self.tracks[currentTrackIndex])
                PlaybackManager.sharedInstance.playTracks(tracks, callback: { (error) -> () in })
            } else {
                PlaybackManager.sharedInstance.playFromMain()
            }
            PlaybackManager.sharedInstance.currentImage = self.coverImageView?.image
            self.station?.isPlaying = true
            self.isPlaying = true
            self.playButton?.setImage(UIImage(named:"btn-pause-list"), forState: .Normal)
        }
    }
    
    func playbackDidPause (notification: NSNotification?) {
        self.isPlaying = false
        self.playButton?.setImage(UIImage(named:"btn-play-list"), forState: .Normal)
    }
    
    func playbackDidResume (notification: NSNotification?) {
        self.isPlaying = true
        self.playButton?.setImage(UIImage(named:"btn-pause-list"), forState: .Normal)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            let newHeight = bannerViewHeight! - offsetY
            bannerViewHeightConstraint?.constant = newHeight
            bannerImageEffectView?.frame.size.height = newHeight
            bannerView?.setNeedsLayout()
            bannerView?.layoutIfNeeded()
            bannerImageEffectView?.setNeedsLayout()
            bannerImageEffectView?.layoutIfNeeded()
            let damping: CGFloat = 160
            var alpha = 1 + offsetY / damping
            bannerControlsView?.alpha = 1 + offsetY / damping
            if alpha >= 0.85 {
                alpha = 0.85
            }
            bannerImageEffectView?.alpha = alpha;
        }
    }
    
    func stationDidChangeUpdatedAt(notification:NSNotification) {
        // TODO if let savedStation = notification.object as? SavedStation {
        if let dict = notification.object as? [String: AnyObject] {
            if dict["id"] as? Int == self.station?.id {
                let text = self.station!.updatedAtString()
                updatedAtLabel?.text = text
            }
        }
    }
    
    //    // TODO func updateWeatherIcon(savedStation:SavedStation?) {
    //    func updateWeatherIcon(station: Station?) {
    //        if let station = station where station.isStandardType {
    //            if let useWeather = station.useWeather where useWeather {
    //                weatherButton.setImage(UIImage(named: "btn-weather"), forState: .Normal)
    //            } else {
    //                weatherButton.setImage(UIImage(named: "btn-weather-off"), forState: .Normal)
    //            }
    //        } else if let weatherButton = weatherButton {
    //            if ModelManager.sharedInstance.onNexStationSaveUseWeather {
    //                weatherButton.setImage(UIImage(named: "btn-weather"), forState: .Normal)
    //            } else {
    //                weatherButton.setImage(UIImage(named: "btn-weather-off"), forState: .Normal)
    //            }
    //        }
    //    }
    //
    //    // TODO func updateTimeIcon(savedStation:SavedStation?) {
    //    func updateTimeIcon(station: Station?) {
    //        if let station = station where station.isStandardType {
    //            if let useTime = station.useTimeofday where useTime {
    //                timeButton.setImage(UIImage(named: "btn-time"), forState: .Normal)
    //            } else {
    //                timeButton.setImage(UIImage(named: "btn-time-off"), forState: .Normal)
    //            }
    //        } else if let timeButton = timeButton {
    //            if ModelManager.sharedInstance.onNexStationSaveUseTime {
    //                timeButton.setImage(UIImage(named: "btn-time"), forState: .Normal)
    //            } else {
    //                timeButton.setImage(UIImage(named: "btn-time-off"), forState: .Normal)
    //            }
    //        }
    //    }
    
    func willStartStationTracksReGeneration(notification: NSNotification){
        if let notifInfo = notification.object as? [String: Int], id = notifInfo["id"] where self.station?.id == id {
            fullscreenView.setMessage("Just a moment")
            fullscreenView.show()
        }
    }
    
    //    func willStartStationTracksReGeneration(notification: NSNotification){
    //        if let notifInfo = notification.object as? [String: Int], id = notifInfo["id"] where self.station?.id == id {
    //            fullscreenView.setMessage("Just a moment, we’re generating your playlist")
    //            fullscreenView.show()
    //        }
    //    }
    
    //    func didEndStationTracksReGeneration(notification: NSNotification){
    //        if let notifInfo = notification.object as? [String: Int], id = notifInfo["id"] where self.station?.id == id {
    //                self.tracks = self.station?.tracks
    //                self.tracksTableView.reloadData()
    //                fullscreenView.hide(1.5)
    //        }
    //    }
    
    func didEndStationTracksReGeneration(notification: NSNotification){
        if let notifInfo = notification.object as? [String: Int], id = notifInfo["id"] where self.station?.id == id {
            self.tracks = self.station!.tracks
            self.tracksTableView.reloadData()
            fullscreenView.hide(1.5)
        }
    }
    
    @IBAction func openStationUrl(sender: UIButton) {
        if let urlString = urlLabel.text {
            if let url = NSURL(string: "http://" + urlString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    @IBAction func removeStation(sender: UIButton) {
        sender.enabled = false
        ModelManager.sharedInstance.removeSavedStation(station!) { (removed) -> Void in
            sender.enabled = true
            if removed {
                //self.savedStation = nil
                self.saveButton.alpha = 1
                self.removeButton.alpha = 0
                self.savedImageView.alpha = 0
            }
        }
    }
    
    @IBAction func forceRefresh(sender: UIButton) {
        if let station = self.station {
            ModelManager.sharedInstance.forceGenerateStationTracks(station) {}
        }
    }
    
    @IBAction func share(sender: AnyObject) {
        if let station = station {
            if let text = station.name {
                let shareView = ShareView(text: text, appUrl:"station/123", presenterViewController: self) { (_) -> Void in }
                if let urlString = station.url {
                    if let url = NSURL(string: urlString) {
                        shareView.shareUrl = url
                    }
                }
                if let image = self.coverImageView?.image {
                    shareView.shareImage = image
                }
                shareView.tracks = tracks
                shareView.show()
            }
        }
    }
    
    //    @IBAction func toggleWeather(sender: UIButton) {
    //        if let station = self.station {
    //            station.toggleWeather()
    //            updateWeatherIcon(station)
    //            //showAlertFirstTimeAndSaveStation(station)
    //        }
    ////        } else {
    ////            ModelManager.sharedInstance.onNexStationSaveUseWeather = !ModelManager.sharedInstance.onNexStationSaveUseWeather
    ////            updateWeatherIcon(nil)
    ////        }
    //    }
    //
    //    @IBAction func toggleUseTime(sender: UIButton) {
    //        if let station = station {
    //            station.toggleTime()
    //            updateTimeIcon(station)
    //            //showAlertFirstTimeAndSaveStation(savedStation)
    //        }
    ////        else {
    ////            ModelManager.sharedInstance.onNexStationSaveUseTime = !ModelManager.sharedInstance.onNexStationSaveUseTime
    ////            updateTimeIcon(nil)
    ////        }
    //    }
    
    @IBAction func saveStation(sender: UIButton) {
        sender.enabled = false
        ModelManager.sharedInstance.saveStation(station!) { (saved, savedStation) -> Void in
            sender.enabled = true
            if saved {
                self.station = savedStation
                self.saveButton.alpha = 0
                self.removeButton.alpha = 1
                self.savedImageView.alpha = 1
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? EditStationViewController {
            destinationViewController.station = station
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tracks != nil {
            return tracks.count
        }
        return 0
    }
    
    func like()->MGSwipeButton{
        return MGSwipeButton(title: nil, icon: UIImage(named: "btn-like-track"), backgroundColor: UIColor.customToggleOnColor(), callback: { (cell) -> Bool in
            
            if let cell = cell as? TrackTableViewCell {
                if cell.track.liked == nil || !cell.track.liked! {
                    // TODO SongSortApiManager.sharedInstance.favoriteTrack(self.savedStation!.station!.id!,savedStationId: (self.savedStation?.id)!, trackId: cell.track.id!)
                    SongSortApiManager.sharedInstance.favoriteTrack(
                        self.station!.id!,
                        trackId: cell.track.id!
                    )
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
                    // TODO  SongSortApiManager.sharedInstance.unfavoriteTrack(self.savedStation!.station!.id!,savedStationId: (self.savedStation?.id)!, trackId: cell.track.id!)
                    SongSortApiManager.sharedInstance.unfavoriteTrack(
                        self.station!.id!,
                        trackId: cell.track.id!
                    )
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
            self.currentTrackIndex = indexPath.row
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
            PlaybackManager.sharedInstance.currentImage = self.coverImageView?.image
            self.station?.isPlaying = true
            self.isPlaying = true
            self.playButton?.setImage(UIImage(named:"btn-pause-list"), forState: .Normal)
        }
        
        if let liked = cell.track.liked {
            cell.likedImageView.alpha = liked ? 1 : 0
        } else {
            cell.likedImageView.alpha = 0
        }
        
        if station?.savedStation == true {
            
            let deleteButton = MGSwipeButton(title: nil, icon: UIImage(named: "btn-delete-track"), backgroundColor: UIColor.customWarningColor(), callback: { (cell) -> Bool in
                if let cell = cell as? TrackTableViewCell {
                    // TODO  SongSortApiManager.sharedInstance.banTrack(self.savedStation!.station!.id!,savedStationId: (self.savedStation?.id)!, trackId: cell.track.id!)
                    SongSortApiManager.sharedInstance.banTrack(
                        self.station!.id!,
                        trackId: cell.track.id!
                    )
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if let tracks = self.tracks {
                            var index: Int?
                            for i in 0 ..< tracks.count {
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
        
        cell.validatePlaying()
        return cell
    }
}
