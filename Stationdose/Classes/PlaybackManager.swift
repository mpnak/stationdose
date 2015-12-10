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
    
    var currentQueue:[Track]
    var currentTrack:Track?
    var playing:Bool
    
    private let playbackControlView:PlaybackControlView
    
    override init() {
        playbackControlView = PlaybackControlView.instanceFromNib()
        currentQueue = []
        currentTrack = nil
        playing = false
        
        super.init()
        
        setupPlaybackControlView()
    }
    
    func play() {
        
        if playing {
            return
        }
        
        if let currentTrack = currentTrack {
            
            playing = true
            
            if let audioStreamingController = SpotifyManager.sharedInstance.audioStreamingController {
                audioStreamingController.loginWithSession(SpotifyManager.sharedInstance.session, callback: { (error) -> Void in
                    if error != nil {
                        print("Error: ", error)
                        self.playing = false
                        return
                    }
                    
                    print("spotifyId ", currentTrack.spotifyId)
                    
                    let trackURI = NSURL(string: String(format: "spotify:track:%@", arguments: [currentTrack.spotifyId!]))
                    audioStreamingController.playURIs([trackURI!], fromIndex: 0, callback: { (error) -> Void in
                        if error != nil {
                            print("Error: ", error)
                            self.playing = false
                            return
                        }
                    })
                })
            } else {
                playing = false
            }
        } else {
            if currentQueue.count > 0 {
                currentTrack = currentQueue.first
                self.play()
            }
        }
    }
    
    func pause() {
        
    }
    
    func preview(track:Track) {
        
    }
    
    func addTrack(track:Track) {
        if currentQueue.count == 0 {
            currentTrack = track
        } else {
            currentQueue.append(track)
        }
    }
    
    func discardCurrentQueue() {
        self.pause()
        currentQueue = []
        changeCurrentTrack(nil)
    }
    
    private func setupPlaybackControlView() {
        changeCurrentTrack(nil)
        playbackControlView.playButton.addTarget(self, action: "play", forControlEvents: .TouchUpInside)
        playbackControlView.pauseButton.addTarget(self, action: "pause", forControlEvents: .TouchUpInside)
        
        let window = UIApplication.sharedApplication().keyWindow!
        var frame = window.bounds
        frame.origin.y = frame.size.height - 50
        frame.size.height = 50
        playbackControlView.frame = frame
        window.addSubview(playbackControlView)
        
    }
    
    private func changeCurrentTrack(track:Track?) {
        currentTrack = track
        
        if let index = currentQueue.indexOf({$0.id == currentTrack!.id}) {
            currentQueue.removeAtIndex(index)
        }
        
        playbackControlView.currentTimeProgressView.progress = 0.0
        playbackControlView.playButton.alpha = 1
        playbackControlView.pauseButton.alpha = 0
        if let track = track {
            playbackControlView.titleLabel.text = track.artist
            playbackControlView.artistLabel.text = track.artist
        } else {
            playbackControlView.titleLabel.text = ""
            playbackControlView.artistLabel.text = ""
        }
    }
}
