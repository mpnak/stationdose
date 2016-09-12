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
    
    static var sharedInstance = PlaybackManager()
    
    var currentImage:UIImage?
    var currentTrack:Track?
    var needsStandardArtwork: Bool = false
    
    var alwaysOnTop: Bool = true
    
    private var tracksMap = [String: Track]()
    private var player:SPTAudioStreamingController!
    private var trackQueue = [Track]()
    private var trackHistory = [Track]()
    private var deletedTacksMap = [String: Track]()
    private var currentTrackPosition = NSTimeInterval(0)
    private var playbackControlView:PlaybackControlView?
    
    override init() {
        super.init()
        
        //setupPlayer()
       
        setupRemoteCommandCenter()
    }
    
    func setupPlayer() {
        player = SPTAudioStreamingController.sharedInstance()
        try! player.startWithClientId(SpotifyManager.sharedInstance.clientID)
        player.playbackDelegate = self
        player.delegate = self
        player.loginWithAccessToken(SpotifyManager.sharedInstance.session!.accessToken)
    }
    
    func logout() {
        stop()
        player?.logout()
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTarget(self, action: #selector(MPMediaPlayback.play))
        commandCenter.pauseCommand.addTarget(self, action: #selector(PlaybackManager.pause))
        commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(PlaybackManager.togglePlayPause))
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(PlaybackManager.nextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(PlaybackManager.previousTrack))
        
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
    
    //
    
    func setNowPlayingInfo() {
        guard let sptCurrentTrack = player.metadata.currentTrack else {
            return
        }
        
        var info = [String : AnyObject]()
        
        info[MPMediaItemPropertyPlaybackDuration] = Double(sptCurrentTrack.duration)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTrackPosition
        info[MPNowPlayingInfoPropertyPlaybackRate] = player.playbackState.isPlaying ? 1.0 : 0.0
        //        info[MPMediaItemPropertyMediaType] = MPMediaType.Music.rawValue
        info[MPMediaItemPropertyTitle] = currentTrack?.title
        info[MPMediaItemPropertyArtist] = currentTrack?.artist
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: UIImage(named: "lock-screen-featured-placeholder")!)
        
        if let currentImage = currentImage {
            if needsStandardArtwork {
                info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: currentImage)
            }
        }
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
    }
    
    func play() {
        setPlayPauseButtonsEnabled(false)
        player.setIsPlaying(true, callback: { (error) -> Void in })
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.playbackDidResume, object: nil)
    }
    
    func pause() {
        setPlayPauseButtonsEnabled(false)
        player.setIsPlaying(false, callback: { (error) -> Void in })
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.playbackDidPause, object: nil)
    }
    
    func pauseFromMain() {
        setPlayPauseButtonsEnabled(false)
        player.setIsPlaying(false, callback: { (error) -> Void in })
    }
    
    func togglePlayPause() {
        setPlayPauseButtonsEnabled(false)
        player.setIsPlaying(!player.playbackState.isPlaying, callback: { (error) -> Void in })
    }
    
    func stop() {
        player.setIsPlaying(false, callback: { (error) -> Void in })
        reset()
        hide()
    }
    
    func replaceQueue(tracks:[Track]) {
        reset()
        trackQueue = tracks
    }
    
    func reset() {
        trackHistory = []
        trackQueue = []
        deletedTacksMap = [:]
        tracksMap = [:]
    }
    
    func nextTrack() {
        playTracks(trackQueue) { (error) -> Void in }
    }
    
    func previousTrack() {
        trackHistory.popLast()
        if let currentTrack = currentTrack {
            trackQueue.insert(currentTrack, atIndex: 0)
        }
        if let previousTrack = trackHistory.popLast() {
            trackQueue.insert(previousTrack, atIndex: 0)
        }
        playTracks(trackQueue) { (error) in }
    }
    
    func removeTrack(track:Track) {
        if let currentTrack = currentTrack {
            if currentTrack.id == track.id {
                nextTrack()
            }
        }
        
        deletedTacksMap[track.spotifyUrl()] = track
    }
    
    func playTracks(tracks:[Track], callback:(error:NSError?)->()) {
        
        trackQueue = tracks
        
        tracksMap = [:]
        for track in tracks {
            tracksMap[track.spotifyUrl()] = track
        }
        
        guard tracks.count > 0 else {
            stop()
            return
        }
        
        let firstTrack = trackQueue.removeAtIndex(0)
        
        if firstTrack.id != currentTrack?.id {
            cleanPlaybackControlView()
        }
        
        print("Playing Track:")
        print(firstTrack.title!)
        print("Queued:")
        print(trackQueue.map { $0.title! })
        print("History:")
        print(trackHistory.map { $0.title! })
        print("Deleted:")
        
        player.setIsPlaying(false, callback: { (error) -> Void in })
        
        playTrack(firstTrack)
        
        showPlaybackControlView()
    }
    
    func playTrack(track: Track, startingPosition: NSTimeInterval = NSTimeInterval(0)) {
        currentTrackPosition = startingPosition
        player.playSpotifyURI(track.spotifyUrl(), startingWithIndex: 0, startingWithPosition: startingPosition) { error in
            if let error = error {
                print("playSpotifyURI error ", error)
            }
        }
        
        trackHistory.append(track)
    }
    
    private func setupPlaybackControlView() {
        playbackControlView = PlaybackControlView.instanceFromNib()
        playbackControlView?.currentTimeProgressView.progress = 0.0
        cleanPlaybackControlView()
        playbackControlView?.playButton.addTarget(self, action: #selector(MPMediaPlayback.play), forControlEvents: .TouchDown)
        playbackControlView?.pauseButton.addTarget(self, action: #selector(PlaybackManager.pause), forControlEvents: .TouchDown)
    }
    
    private func showPlaybackControlView() {
        if playbackControlView != nil {
            show()
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
        
        show()
    }
    
    func show() {
        let window = UIApplication.sharedApplication().keyWindow!
        let baseViewControllerCustomViewHeight = window.bounds.size.height - 50 /*playback controller height*/ - 64 /*navigation bar height*/
        if BaseViewController.customViewHeight != baseViewControllerCustomViewHeight {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                var frame = self.playbackControlView!.frame
                frame.origin.y = window.bounds.size.height - 50
                self.playbackControlView!.frame = frame
            }) { (success) -> Void in
                BaseViewController.customViewHeight = baseViewControllerCustomViewHeight
            }
        }
    }
    
    func hide() {
        let window = UIApplication.sharedApplication().keyWindow!
        let baseViewControllerCustomViewHeight = window.bounds.size.height - 64 /*navigation bar height*/
        BaseViewController.customViewHeight = baseViewControllerCustomViewHeight
        
        if self.playbackControlView != nil {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                var frame = self.playbackControlView!.frame
                frame.origin.y = window.bounds.size.height
                self.playbackControlView!.frame = frame
            }) { (success) -> Void in }
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

extension PlaybackManager: SPTAudioStreamingDelegate {
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didReceiveError errorCode: SpErrorCode, withName name: String!) {
        AlertView.genericErrorAlert().show()
    }
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
    }
    
    func audioStreamingDidLogout(audioStreaming: SPTAudioStreamingController!) {
        do {
            try player.stop()
        } catch _ {
        }
    }
    
    /** Called when the streaming controller encounters a temporary connection error.
     
     You should not throw an error to the user at this point. The library will attempt to reconnect without further action.
     
     @param audioStreaming The object that sent the message.
     */
    func audioStreamingDidEncounterTemporaryConnectionError(audioStreaming: SPTAudioStreamingController!) {
    }
    
    /** Called when the streaming controller recieved a message for the end user from the Spotify service.
     
     This string should be presented to the user in a reasonable manner.
     
     @param audioStreaming The object that sent the message.
     @param message The message to display to the user.
     */
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        //let alertView = UIAlertView(title: "Message from Spotify", message: message, delegate: nil, cancelButtonTitle: "OK")
        //alertView.show()
    }
    
    /** Called when network connectivity is lost.
     @param audioStreaming The object that sent the message.
     */
    func audioStreamingDidDisconnect(audioStreaming: SPTAudioStreamingController!) {
    }

    /** Called when network connectivitiy is back after being lost.
     @param audioStreaming The object that sent the message.
     */
    func audioStreamingDidReconnect(audioStreaming: SPTAudioStreamingController!) {
    }
}

extension PlaybackManager: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePosition position: NSTimeInterval) {
        
        guard player.metadata.currentTrack != nil else {
            return
        }
        
        currentTrackPosition = position
        
        let progress = Float(player.metadata.currentTrack!.duration > 0 ? position/player.metadata.currentTrack!.duration : 0)

        playbackControlView?.currentTimeProgressView.progress = progress
        
//        if alwaysOnTop {
//            if let superview = playbackControlView?.superview  {
//                playbackControlView?.removeFromSuperview()
//                superview.addSubview(playbackControlView!)
//            }
//        }
        
        //print(progress)
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        nextTrack()
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        guard deletedTacksMap[trackUri] == nil else {
            nextTrack()
            return
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        playbackControlView?.playButton.alpha = isPlaying ? 0 : 1
        playbackControlView?.pauseButton.alpha = isPlaying ? 1 : 0
        setPlayPauseButtonsEnabled(true)
        setNowPlayingInfo()
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeMetadata metadata: SPTPlaybackMetadata!) {
        guard let uri = metadata.currentTrack?.uri else {
            return
        }
        
        guard let  track = tracksMap[uri] else {
            return
        }
        
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

    //    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceivePlaybackEvent:(SpPlaybackEvent)event withName:(NSString*)name;
    //    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePosition:(NSTimeInterval)position;
    //    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToPosition:(NSTimeInterval)position;
    //    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeVolume:(SPTVolume)volume;
    //    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeShuffleStatus:(BOOL)isShuffled;
    //    -(void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeRepeatStatus:(BOOL)isRepeated;
    //    -(void)audioStreamingDidSkipToNextTrack:(SPTAudioStreamingController *)audioStreaming;
    //    -(void)audioStreamingDidSkipToPreviousTrack:(SPTAudioStreamingController *)audioStreaming;
    
    /** Called when the audio streaming object becomes the active playback device on the user's account.
     @param audioStreaming The object that sent the message.
     */
    //   -(void)audioStreamingDidBecomeActivePlaybackDevice:(SPTAudioStreamingController *)audioStreaming;
    
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
