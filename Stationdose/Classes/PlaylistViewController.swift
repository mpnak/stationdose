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
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var tracksTableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var savedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showBrandingTitleView()
        showUserProfileButton()
        
        nameLabel?.text = station?.name
        shortDescriptionLabel?.text = station?.shortDescription
        
        if let featuredUrl = station?.art {
            let URL = NSURL(string: featuredUrl)!
            bannerImageView?.af_setImageWithURL(URL)
        }
        
        if let featuredUrl = station?.art {
            let URL = NSURL(string: featuredUrl)!
            coverImageView?.af_setImageWithURL(URL)
        }
        
        saveButton?.alpha = savedStation == nil ? 1 : 0
        removeButton?.alpha = savedStation == nil ? 0 : 1
        savedImageView?.alpha = savedStation == nil ? 0 : 1
        
        if let savedStation = savedStation {
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
    }
    
    @IBAction func removeStation(sender: UIButton) {
        sender.enabled = false
        
        ModelManager.sharedInstance.removeSavedStation(savedStation!) { (removed) -> Void in
            sender.enabled = true
            if removed {
                self.saveButton.alpha = 1
                self.removeButton.alpha = 0
                self.savedImageView.alpha = 0
            }
        }
    }
    
    @IBAction func saveStation(sender: UIButton) {
        sender.enabled = false
        
        ModelManager.sharedInstance.saveStation(station!) { (saved) -> Void in
            sender.enabled = true
            if saved {
                self.saveButton.alpha = 0
                self.removeButton.alpha = 1
                self.savedImageView.alpha = 1
            }
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
            
            print("selected track ", cell.track.title)
            
            PlaybackManager.sharedInstance.playTracks(tracks, callback: { (error) -> () in })
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
                        self.tracksTableView.beginUpdates()
                        self.tracksTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
                        self.tracks?.removeAtIndex(indexPath.row)
                        self.tracksTableView.endUpdates()
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
