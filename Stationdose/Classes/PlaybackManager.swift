//
//  PlaybackManager.swift
//  Stationdose
//
//  Created by Developer on 12/8/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaybackManager: NSObject {
    
    static let sharedInstance = PlaybackManager()
    
    var currentImage:UIImage?
    var currentTrack:Track?
    
    var alwaysOnTop: Bool
    
    private var tracksMap:[String: Track]
    private let player:SPTAudioStreamingController
    private var currentTimeReloadTimer: NSTimer?
    private var nextQueue:[Track]?
    private var deletedTacksUrls:[String]
    
    private var playbackControlView:PlaybackControlView?
    
    override init() {
        tracksMap = [String: Track]()
        deletedTacksUrls = [String]()
        player = SpotifyManager.sharedInstance.player!
        alwaysOnTop = true
        
        super.init()
        
        player.playbackDelegate = self
        player.loginWithSession(SpotifyManager.sharedInstance.session) { (error) -> Void in
            if let error = error {
                print(error)
            }
        }
        currentTimeReloadTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "currentTimeReload", userInfo: nil, repeats: true)
        setupRemoteCommandCenter()
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTarget(self, action: "play")
        commandCenter.pauseCommand.addTarget(self, action: "pause")
        commandCenter.togglePlayPauseCommand.addTarget(self, action: "togglePlayPause")
        commandCenter.nextTrackCommand.addTarget(self, action: "nextTrack")
        commandCenter.previousTrackCommand.addTarget(self, action: "previousTrack")
        
        commandCenter.likeCommand.enabled = false
        commandCenter.dislikeCommand.enabled = false
        
        commandCenter.stopCommand.enabled = false
        commandCenter.enableLanguageOptionCommand.enabled = false
        commandCenter.disableLanguageOptionCommand.enabled = false
        commandCenter.skipForwardCommand.enabled = false
        commandCenter.skipBackwardCommand.enabled = false
        commandCenter.ratingCommand.enabled = false
        commandCenter.bookmarkCommand.enabled = false
        commandCenter.changePlaybackPositionCommand.enabled = false
    }
    
    func setNowPlayingInfo() {
        var info = [String : AnyObject]()
        info[MPMediaItemPropertyPlaybackDuration] = Double(player.currentTrackDuration)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(player.currentPlaybackPosition)
        info[MPNowPlayingInfoPropertyPlaybackRate] = player.isPlaying ? 1.0 : 0.0
//        info[MPMediaItemPropertyMediaType] = MPMediaType.Music.rawValue
        
        info[MPMediaItemPropertyTitle] = currentTrack?.title
        info[MPMediaItemPropertyArtist] = currentTrack?.artist
        if let currentImage = currentImage {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: currentImage)
        }
//        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: UIImage(named: "station-placeholder")!)
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
    }
    
    func currentTimeReload() {
        if player.currentTrackDuration > 0 {
            playbackControlView?.currentTimeProgressView.progress = Float(player.currentPlaybackPosition/player.currentTrackDuration)
        } else {
            playbackControlView?.currentTimeProgressView.progress = 0.0
        }
        if alwaysOnTop {
            if let superview = playbackControlView?.superview  {
                playbackControlView?.removeFromSuperview()
                superview.addSubview(playbackControlView!)
            }
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
    
    func togglePlayPause() {
        setPlayPauseButtonsEnabled(false)
        player.setIsPlaying(!player.isPlaying, callback: { (error) -> Void in })
    }
    
    func nextTrack() {
        player.skipNext({ (error) -> Void in})
    }
    
    func previousTrack() {
        player.skipPrevious({ (error) -> Void in})
    }
    
    func removeTrack(track:Track) {
        if let currentTrack = currentTrack {
            if currentTrack.id == track.id {
                player.skipNext({ (error) -> Void in })
            }
        }
        
        let url = track.spotifyUrl()
        deletedTacksUrls.append(url)
        tracksMap.removeValueForKey(url)
    }
    
    func playTracks(tracks:[Track], callback:(error:NSError?)->()) {
        
        if tracks.count == 0 {
            return
        }
        
        deletedTacksUrls = [String]()
        nextQueue = nil
        
        if let track = tracks.first {
            if track.id != currentTrack?.id {
                cleanPlaybackControlView()
            }
        }
        
        var urls = [NSURL]()
        for track in tracks {
            let urlString = track.spotifyUrl()
            urls.append(NSURL(string: urlString)!)
            tracksMap[urlString] = track
        }
        
        
        player.setIsPlaying(false, callback: { (error) -> Void in })
        player.stop({ (error) -> Void in })
        
        player.playURIs(urls, withOptions: nil) { (error) -> Void in
            if let error = error {
                print("error ", error)
            }
            callback(error: error)
        }
        
        showPlaybackControlView()
    }
    
    func replaceQueue(tracks:[Track]) {
        nextQueue = tracks
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
        
        window.addObserver(self, forKeyPath: "subviews", options: .New, context: nil)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            var frame = self.playbackControlView!.frame
            frame.origin.y -= 50
            self.playbackControlView!.frame = frame
            }) { (success) -> Void in
                BaseViewController.setCustomViewHeight(window.bounds.size.height - 50 /*playback controller height*/ - 64 /*navigation bar height*/)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print(keyPath)
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
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        if let nextQueue = nextQueue {
            self.nextQueue = nil
            playTracks(nextQueue, callback: { (error) -> () in })
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        for url in deletedTacksUrls {
            if url == trackUri.absoluteString {
                player.skipNext({ (_) -> Void in })
                break
            }
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        playbackControlView?.playButton.alpha = isPlaying ? 0 : 1
        playbackControlView?.pauseButton.alpha = isPlaying ? 1 : 0
        setPlayPauseButtonsEnabled(true)
        setNowPlayingInfo()
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
                setNowPlayingInfo()
                NSNotificationCenter.defaultCenter().postNotificationName("playbackCurrentTrackDidChange", object: nil)
            }
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        AlertView.genericErrorAlert().show()
    }
}
