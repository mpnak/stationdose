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
    
    var playlist:Playlist?
    var station:Station?
    var tracks:[Track]!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var tracksTableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var savedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = station?.name
        shortDescriptionLabel.text = station?.shortDescription
        
        saveButton.alpha = playlist == nil ? 1 : 0
        removeButton.alpha = playlist == nil ? 0 : 1
        savedImageView.alpha = playlist == nil ? 0 : 1
        
        if let playlist = playlist {
            tracks = playlist.tracks
        } else {
            
            tracks = []
            
            //TODO: loading animation
            
            SongSortApiManager.sharedInstance.getStationTracks((station?.id)!, onCompletion: { (tracks, error) -> Void in
                if let tracks = tracks {
                    self.tracks = tracks
                    self.tracksTableView.reloadData()
                    
                    //TODO: stop animation
                    
                }
            })
        }
    }
    
    @IBAction func removeStation(sender: UIButton) {
        sender.enabled = false
        
        ModelManager.sharedInstance.removePlaylist(station!) { (removed) -> Void in
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
        
        ModelManager.sharedInstance.savePlaylist(station!) { (saved) -> Void in
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackTableViewCellIdentifier") as! TrackTableViewCell
        
        cell.track = tracks![indexPath.row]
        cell.titleLabel.text = cell.track?.title
        cell.subtitleLabel.text = cell.track?.artist
        
        if let liked = cell.track.liked {
            cell.likedImageView.alpha = liked ? 1 : 0
        } else {
            cell.likedImageView.alpha = 0
        }
        
        if playlist != nil {
            
            let deleteButton = MGSwipeButton(title: nil, icon: UIImage(named: "btn-delete-track"), backgroundColor: UIColor.customWarningColor(), callback: { (cell) -> Bool in
                if let cell = cell as? TrackTableViewCell {
                    SongSortApiManager.sharedInstance.banTrack(self.playlist!.id!, trackId: cell.track.id!)
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
                let likeButton = MGSwipeButton(title: nil, icon: UIImage(named: "btn-like-track"), backgroundColor: UIColor.customToggleOnColor(), callback: { (cell) -> Bool in
                    
                    if let cell = cell as? TrackTableViewCell {
                        if cell.track.liked == nil || !cell.track.liked! {
                            SongSortApiManager.sharedInstance.banTrack(self.playlist!.id!, trackId: cell.track.id!)
                            cell.likedImageView.alpha = 1
                            cell.track.liked = true
                            cell.leftButtons = nil
                        }
                    }
                    return true
                })
                likeButton.setPadding(0)
                cell.leftButtons = [likeButton]
                cell.leftSwipeSettings.transition = .Drag
            }
            
        } else {
            cell.rightButtons = nil
            cell.leftButtons = nil
        }
        
        return cell
    }
}