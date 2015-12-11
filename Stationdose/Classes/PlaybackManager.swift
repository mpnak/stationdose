//
//  PlaybackManager.swift
//  Stationdose
//
//  Created by Developer on 12/8/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class PlaybackManager: NSObject {
    
    static let sharedInstance = PlaybackManager()
    
    var currentTrack:Track?
    
    private var tracksMap:[String: Track]
    private let player:SPTAudioStreamingController
    private var currentTimeReloadTimer: NSTimer?
    
    private var playbackControlView:PlaybackControlView?
    
    override init() {
        tracksMap = [String: Track]()
        player = SpotifyManager.sharedInstance.player!
        
        super.init()
        
        player.playbackDelegate = self
        player.loginWithSession(SpotifyManager.sharedInstance.session) { (error) -> Void in
            if let error = error {
                print(error)
            }
        }
        currentTimeReloadTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "currentTimeReload", userInfo: nil, repeats: true)
    }
    
    func currentTimeReload() {
        if player.currentTrackDuration > 0 {
            playbackControlView?.currentTimeProgressView.progress = Float(player.currentPlaybackPosition/player.currentTrackDuration)
        }
    }
    
    func play() {
        setPlayPauseButtonsEnabled(false)
        player.setIsPlaying(true, callback: { (error) -> Void in })
    }
    
    func pause() {
        setPlayPauseButtonsEnabled(false)
        player.setIsPlaying(false, callback: { (error) -> Void in })
    }
    
    func playTracks(tracks:[Track], callback:(error:NSError?)->()) {
        
//        self.pause()
        cleanPlaybackControlView()
        print("-----")
        var urls = [NSURL]()
        for track in tracks {
            let urlString = String(format: "spotify:track:%@", arguments: [track.spotifyId!])
            urls.append(NSURL(string: urlString)!)
            tracksMap[urlString] = track
            
            print("track ", track.title)
        }
        print("-----")
        
//        if currentTrack == nil {
        self.player.playURIs(urls, withOptions: nil) { (error) -> Void in
            if let error = error {
                print("error ", error)
            }
            callback(error: error)
            self.play()
        }
//        } else {
//            self.player.replaceURIs(urls, withCurrentTrack: 0, callback: { (error) -> Void in
//                if let error = error {
//                    print("error ", error)
//                }
//                callback(error: error)
//            })
//        }
        
        self.player.playURIs(urls, withOptions: nil) { (error) -> Void in
            if let error = error {
                print("error ", error)
            }
            callback(error: error)
        }
        
        showPlaybackControlView()
    }
    
    private func setupPlaybackControlView() {
        playbackControlView = PlaybackControlView.instanceFromNib()
        playbackControlView?.currentTimeProgressView.progress = 0.0
        cleanPlaybackControlView()
        playbackControlView?.playButton.addTarget(self, action: "play", forControlEvents: .TouchUpInside)
        playbackControlView?.pauseButton.addTarget(self, action: "pause", forControlEvents: .TouchUpInside)
    }
    
    private func showPlaybackControlView() {
        if playbackControlView != nil {
            return
        }
        
        setupPlaybackControlView()
        
        let window = UIApplication.sharedApplication().keyWindow!
        var frame = window.bounds
        frame.origin.y = frame.size.height
        frame.size.height = 50
        playbackControlView!.frame = frame
        window.addSubview(playbackControlView!)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            var frame = self.playbackControlView!.frame
            frame.origin.y -= 50
            self.playbackControlView!.frame = frame
            }) { (success) -> Void in
                BaseViewController.setCustomViewHeight(window.bounds.size.height - 50 /*playback controller height*/ - 64 /*navigation bar height*/)
        }
    }
    
    private func cleanPlaybackControlView() {
        playbackControlView?.playButton.alpha = 1
        playbackControlView?.pauseButton.alpha = 0
        setPlayPauseButtonsEnabled(false)
        playbackControlView?.titleLabel.text = ""
        playbackControlView?.artistLabel.text = ""
    }
    
    private func setPlayPauseButtonsEnabled(enabled:Bool) {
        playbackControlView?.playButton.enabled = enabled
        playbackControlView?.pauseButton.enabled = enabled
    }
}

extension PlaybackManager: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        playbackControlView?.playButton.alpha = isPlaying ? 0 : 1
        playbackControlView?.pauseButton.alpha = isPlaying ? 1 : 0
        setPlayPauseButtonsEnabled(true)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if let url = trackMetadata[SPTAudioStreamingMetadataTrackURI] {
            if let track = tracksMap[url as! String] {
                playbackControlView?.titleLabel.text = track.title
                playbackControlView?.artistLabel.text = track.artist
                playbackControlView?.playButton.alpha = 0
                playbackControlView?.pauseButton.alpha = 1
                setPlayPauseButtonsEnabled(true)
                currentTrack = track
                NSNotificationCenter.defaultCenter().postNotificationName("playbackCurrentTrackDidChange", object: nil)
            }
        }
    }
}
