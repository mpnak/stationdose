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
    
    var tracksMap:[String: Track]
    let player:SPTAudioStreamingController
    var currentTimeReloadTimer: NSTimer?
    
    private let playbackControlView:PlaybackControlView
    
    override init() {
        playbackControlView = PlaybackControlView.instanceFromNib()
        tracksMap = [String: Track]()
        player = SpotifyManager.sharedInstance.player!
        
        super.init()
        
        setupPlaybackControlView()
        player.playbackDelegate = self
        currentTimeReloadTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "currentTimeReload", userInfo: nil, repeats: true)
    }
    
    func currentTimeReload() {
        if player.currentTrackDuration > 0 {
            playbackControlView.currentTimeProgressView.progress = Float(player.currentPlaybackPosition/player.currentTrackDuration)
        }
    }
    
    func play() {
        player.setIsPlaying(true, callback: { (error) -> Void in
            print("")
        })
    }
    
    func pause() {
        player.setIsPlaying(false, callback: { (error) -> Void in
            print("")
        })
    }
    
    func preview(track:Track) {
        
    }
    
    func addTracks(tracks:[Track], callback:(error:NSError?)->()) {
        
        var urls = [NSURL]()
        for track in tracks {
            urls.append(NSURL(string: String(format: "spotify:track:%@", arguments: [track.spotifyId!]))!)
        }
        
        player.playURIs(urls, fromIndex: 0) { (error) -> Void in
            callback(error: error)
        }
    }
    
    func discardCurrentQueue() {
                
        showCurrentTrack(nil)
    }
    
    private func setupPlaybackControlView() {
        showCurrentTrack(nil)
        playbackControlView.playButton.addTarget(self, action: "play", forControlEvents: .TouchUpInside)
        playbackControlView.pauseButton.addTarget(self, action: "pause", forControlEvents: .TouchUpInside)
        
        let window = UIApplication.sharedApplication().keyWindow!
        var frame = window.bounds
        frame.origin.y = frame.size.height - 50
        frame.size.height = 50
        playbackControlView.frame = frame
        window.addSubview(playbackControlView)
        
    }
    
    private func showCurrentTrack(track:Track?) {
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

extension PlaybackManager: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        playbackControlView.playButton.alpha = isPlaying ? 0 : 1
        playbackControlView.pauseButton.alpha = isPlaying ? 1 : 0
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        print("trackMetadata ", trackMetadata)
    }
    
    /** Called when playback status changes.
    @param audioStreaming The object that sent the message.
    @param isPlaying Set to `YES` if the object is playing audio, `NO` if it is paused.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying;
    
    /** Called when playback is seeked "unaturally" to a new location.
    @param audioStreaming The object that sent the message.
    @param offset The new playback location.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToOffset:(NSTimeInterval)offset;
    
    /** Called when playback volume changes.
    @param audioStreaming The object that sent the message.
    @param volume The new volume.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeVolume:(SPTVolume)volume;
    
    /** Called when shuffle status changes.
    @param audioStreaming The object that sent the message.
    @param isShuffled Set to `YES` if the object requests shuffled playback, otherwise `NO`.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeShuffleStatus:(BOOL)isShuffled;
    
    /** Called when repeat status changes.
    @param audioStreaming The object that sent the message.
    @param isRepeated Set to `YES` if the object requests repeated playback, otherwise `NO`.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeRepeatStatus:(BOOL)isRepeated;
    
    /** Called when playback moves to a new track.
    @param audioStreaming The object that sent the message.
    @param trackMetadata Metadata for the new track. See -currentTrackMetadata for keys.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata;
    
    
    
    
    
    
    
    
    
    
    /** Called when the streaming controller fails to play a track.
    
    This typically happens when the track is not available in the current users' region, if you're playing
    multiple tracks the playback will start playing the next track automatically
    
    @param audioStreaming The object that sent the message.
    @param trackUri The URI of the track that failed to play.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri;
    
    /** Called when the streaming controller begins playing a new track.
    
    @param audioStreaming The object that sent the message.
    @param trackUri The URI of the track that started to play.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStartPlayingTrack:(NSURL *)trackUri;
    
    /** Called before the streaming controller begins playing another track.
    
    @param audioStreaming The object that sent the message.
    @param trackUri The URI of the track that stopped.
    */
//    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri;
    
    /** Called when the audio streaming object requests playback skips to the next track.
    @param audioStreaming The object that sent the message.
    */
//    -(void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming;
    
    /** Called when the audio streaming object requests playback skips to the previous track.
    @param audioStreaming The object that sent the message.
    */
//    -(void)audioStreamingDidSkipToPreviousTrack:(SPTAudioStreamingController *)audioStreaming;
    
    /** Called when the audio streaming object becomes the active playback device on the user's account.
    @param audioStreaming The object that sent the message.
    */
//    -(void)audioStreamingDidBecomeActivePlaybackDevice:(SPTAudioStreamingController *)audioStreaming;
    
    /** Called when the audio streaming object becomes an inactive playback device on the user's account.
    @param audioStreaming The object that sent the message.
    */
//    -(void)audioStreamingDidBecomeInactivePlaybackDevice:(SPTAudioStreamingController *)audioStreaming;
    
    /** Called when the streaming controller lost permission to play audio.
    
    This typically happens when the user plays audio from their account on another device.
    
    @param audioStreaming The object that sent the message.
    */
//    -(void)audioStreamingDidLosePermissionForPlayback:(SPTAudioStreamingController *)audioStreaming;
    
    /** Called when the streaming controller popped a new item from the playqueue.
    
    @param audioStreaming The object that sent the message.
    */
//    -(void)audioStreamingDidPopQueue:(SPTAudioStreamingController *)audioStreaming;
}
