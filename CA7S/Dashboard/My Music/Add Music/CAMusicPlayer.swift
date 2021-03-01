//
//  CAMusicPlayer.swift
//  CA7S
//

import UIKit
import MediaPlayer

protocol TidalMusicPlayerControllerDelegate:AnyObject {
    func musicPlayer(musicPlayer:CAMusicPlayer, trackDidChanged nowPlayingItem:[String:Any], previousTrack:[String:Any])
    func musicPlayer(musicPlayer:CAMusicPlayer, endOfQueueReached lastTrack:[String:Any])
    func musicPlayer(musicPlayer:CAMusicPlayer, playbackStateChanged playbackState:MPMusicPlaybackState, previousPlaybackState:MPMusicPlaybackState)
    func musicPlayer(musicPlayer:CAMusicPlayer, volumeChanged volume:Float)
    func musicPlayerShuffle(musicPlayer:CAMusicPlayer, withCollections collections:Array<[String:Any]>)
    func musicPlayerDuration(musicPlayer:CAMusicPlayer, setduration item:AVPlayerItem)
}

let sharedInstanse = CAMusicPlayer()

class CAMusicPlayer: NSObject, AVAudioSessionDelegate {
    var nowPlayingItem:[String:Any]?
    var playbackState:MPMusicPlaybackState?
    var repeatMode:MPMusicRepeatMode?  // note: MPMusicRepeatModeDefault is not supported
//    var shuffleMode:MPMusicShuffleMode  // note: only MPMusicShuffleModeOff and MPMusicShuffleModeSongs are supported
//    var playerVolume:Float  // 0.0 to 1.0
    var indexOfNowPlayingItem:NSInteger // NSNotFound if no queue
    var updateNowPlayingCenter:Bool  // default YES
    var queue:Array<[String:Any]>?
    var shouldReturnToBeginningWhenSkippingToPreviousItem:Bool
    var shuffleMode:Bool // default YES
    
    private var delegates:Array<Any>?
    private var player:AVPlayer
    private var originalQueue:Array<[String:Any]>?
    private var interrupted:Bool
    private var isLoadingAsset:Bool
    
//    var delegate:Any = {
//
//    }()
    
    
    public override init() {
        super.init()
        
        indexOfNowPlayingItem = NSNotFound
        
        // Set defaults
//        self.playerVolume = 0.7
        updateNowPlayingCenter = true
        repeatMode = MPMusicRepeatMode.none
        shuffleMode = false
        shouldReturnToBeginningWhenSkippingToPreviousItem = true
        
        // Make sure the system follows our playback status
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            
        }
        
        do {
            try audioSession.setActive(true)
        } catch {
            
        }

        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        // Listen for volume changes
        
        MPMusicPlayerController.systemMusicPlayer().beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(handle_volumeChange), name: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange, object: MPMusicPlayerController.systemMusicPlayer())
        
//        [audioSession setDelegate:self];
//        // Handle unplugging of headphones
//        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback2, (__bridge void*)self);

//        return self
    }
    
    func handle_volumeChange() {
        
    }
}
