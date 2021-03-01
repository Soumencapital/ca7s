
#import "CAMusicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "CA7S-Swift.h"
#import "NSUtil.h"

@interface NSArray (GVShuffledArray)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *shuffled;
@end


@implementation NSArray (GVShuffledArray)

- (NSArray *)shuffled {
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (id anObject in self) {
        NSUInteger randomPos = arc4random()%([tmpArray count]+1);
        [tmpArray insertObject:anObject atIndex:randomPos];
    }
    
    return [NSArray arrayWithArray:tmpArray];
}

@end

@interface CAMusicViewController ()<AVAudioSessionDelegate, AVAudioPlayerDelegate>

@property (copy, nonatomic) NSArray *delegates;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVAudioPlayer *localPlayer;
@property (strong, nonatomic) NSArray *originalQueue;
@property (strong, nonatomic, readwrite) NSArray *queue;
@property (strong, nonatomic, readwrite) NSDictionary *nowPlayingItem;
@property (nonatomic, readwrite) NSUInteger indexOfNowPlayingItem;
@property (nonatomic) BOOL interrupted;
@property (nonatomic) BOOL isLoadingAsset;
@end

@implementation CAMusicViewController
+ (CAMusicViewController *)sharedInstance {
    static dispatch_once_t onceQueue;
    static CAMusicViewController *instance = nil;
    dispatch_once(&onceQueue, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

void audioRouteChangeListenerCallback2 (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    CAMusicViewController *controller = (__bridge CAMusicViewController *)inUserData;
    CFDictionaryRef routeChangeDictionary = inPropertyValue;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    CFStringRef oldRouteRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_OldRoute));
    NSString *oldRouteString = (__bridge NSString *)oldRouteRef;
    
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
        if ((controller.playbackState == MPMusicPlaybackStatePlaying) &&
            (([oldRouteString isEqualToString:@"Headphone"]) ||
             ([oldRouteString isEqualToString:@"LineOut"])))
        {
            // Janking out the headphone will stop the audio.
            [controller pause];
        }
    }
}

- (id)init {
    self = [super init];
    if (self) {
        self.indexOfNowPlayingItem = NSNotFound;
        self.delegates = @[];
        self.strAlbumName = [[NSString alloc] init];
        
        // Set defaults
        self.updateNowPlayingCenter = YES;
        self.repeatMode = MPMusicRepeatModeNone;
        self.shuffleMode = false; //MPMusicShuffleModeOff;
        self.shouldReturnToBeginningWhenSkippingToPreviousItem = YES;
        
        // Make sure the system follows our playback status
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *sessionError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        if (!success){
            NSLog(@"setCategory error %@", sessionError);
        }
        success = [audioSession setActive:YES error:&sessionError];
        if (!success){
            NSLog(@"setActive error %@", sessionError);
        }
        [audioSession setDelegate:self];
        // Handle unplugging of headphones
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback2, (__bridge void*)self);
        
//        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        // Listen for volume changes
        [[MPMusicPlayerController systemMusicPlayer] beginGeneratingPlaybackNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handle_VolumeChanged:)
                                                     name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                   object:[MPMusicPlayerController systemMusicPlayer]];
    }
    
    return self;
}

- (void)dealloc {
    [[MPMusicPlayerController systemMusicPlayer] endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                  object:[MPMusicPlayerController systemMusicPlayer]];
}

- (void)addDelegate:(id<MusicPlayerControllerDelegate>)delegate {
    self.delegates = [NSMutableArray new];
    NSMutableArray *delegates = [self.delegates mutableCopy];
    [delegates addObject:delegate];
    self.delegates = delegates;
    
    // Call the delegate's xChanged methods, so it can initialize its UI
    
    if ([delegate respondsToSelector:@selector(musicPlayer:trackDidChange:previousTrack:)]) {
        [delegate musicPlayer:self trackDidChange:self.nowPlayingItem previousTrack:nil];
    }
    
    if ([delegate respondsToSelector:@selector(musicPlayer:playbackStateChanged:previousPlaybackState:)]) {
        [delegate musicPlayer:self playbackStateChanged:self.playbackState previousPlaybackState:MPMusicPlaybackStateStopped];
    }
    
    if ([delegate respondsToSelector:@selector(musicPlayer:volumeChanged:)]) {
        [delegate musicPlayer:self volumeChanged:self.volume];
    }
}

- (void)removeDelegate:(id<MusicPlayerControllerDelegate>)delegate {
    NSMutableArray *delegates = [self.delegates mutableCopy];
    [delegates removeObject:delegate];
    self.delegates = delegates;
}

#pragma mark - Emulate MPMusicPlayerController

- (void)setQueueWithItemCollection:(NSMutableArray *)itemCollection {
    self.originalQueue = [itemCollection mutableCopy];
    self.queue = self.originalQueue;//[itemCollection mutableCopy];
}

- (void)setQueueWithQuery:(NSDictionary *)query {
    self.originalQueue = [query mutableCopy];
}

- (void)skipToNextItem {
    if (self.repeatMode == MPMusicRepeatModeOne) {
        [self skipToBeginning];
        return;
    }
    if (self.indexOfNowPlayingItem+1 < [self.queue count]) {
        // Play next track
        self.indexOfNowPlayingItem++;
    } else {
        if (self.indexOfNowPlayingItem + 1 == [self.queue count]) {
            self.indexOfNowPlayingItem = 0;
        }else{
            if (self.playbackState == MPMusicPlaybackStatePlaying) {
                if (_nowPlayingItem != nil) {
                    for (id <MusicPlayerControllerDelegate> delegate in self.delegates) {
                        if ([delegate respondsToSelector:@selector(musicPlayer:endOfQueueReached:)]) {
                            [delegate musicPlayer:self endOfQueueReached:_nowPlayingItem];
                        }
                    }
                }
                NSLog(@"GVMusicPlayerController: end of queue reached");
                [self pause];
            }
        }
        
    }
}

- (void)skipToBeginning {
    self.currentPlaybackTime = 0.0;
}

- (void)skipToPreviousItem {
    if (self.repeatMode == MPMusicRepeatModeOne) {
        [self skipToBeginning];
        return;
    }
    if (self.indexOfNowPlayingItem > 0) {
        self.indexOfNowPlayingItem--;
    } else{
        self.indexOfNowPlayingItem = 0;
    }
}

-(NSTimeInterval)getTrackDuration {
    if (self.playerType == PlayerTypeRemote) {
        return CMTimeGetSeconds(self.player.currentItem.duration);
    } else {
        return self.localPlayer.duration;
    }

}
#pragma mark - MPMediaPlayback

- (void)play {
    if (self.playerType == PlayerTypeRemote) {
        [self.player play];
    } else {
        [self.localPlayer play];
    }
    
    self.playbackState = MPMusicPlaybackStatePlaying;
    [self doUpdateNowPlayingCenter];
}

- (void)pause {
    if (self.playerType == PlayerTypeRemote) {
        [self.player pause];
    } else {
        [self.localPlayer pause];
    }
    
    self.playbackState = MPMusicPlaybackStatePaused;
    [self doUpdateNowPlayingCenter];
}

- (void)stop {
    if (self.playerType == PlayerTypeRemote) {
        [self.player pause];
    } else {
        [self.localPlayer pause];
    }
    
    self.playbackState = MPMusicPlaybackStateStopped;
}

- (void)prepareToPlay {
    NSLog(@"Not supported");
}

- (void)beginSeekingBackward {
    NSLog(@"Not supported");
}

- (void)beginSeekingForward {
    NSLog(@"Not supported");
}

- (void)endSeeking {
    NSLog(@"Not supported");
}

- (BOOL)isPreparedToPlay {
    return YES;
}

- (NSTimeInterval)currentPlaybackTime {
    
    if (self.playerType == PlayerTypeRemote) {
        if (self.player && (self.player.currentTime.timescale != 0)) {
            return self.player.currentTime.value / self.player.currentTime.timescale;
        } else {
            return 0;
        }
    } else {
        if (self.localPlayer) {
            return self.localPlayer.currentTime;
        } else {
            return 0;
        }
    }
    
    
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    CMTime t = CMTimeMake(currentPlaybackTime, 1);
    if (self.playerType == PlayerTypeRemote) {
        [self.player seekToTime:t];
    } else {
        [self.localPlayer setCurrentTime:currentPlaybackTime];
    }
    
}

- (float)currentPlaybackRate {
    if (self.playerType == PlayerTypeRemote) {
        return self.player.rate;
    } else {
        return 1;
    }
}

- (void)setCurrentPlaybackRate:(float)currentPlaybackRate {
    if (self.playerType == PlayerTypeRemote) {
        self.player.rate = currentPlaybackRate;
    }
}

#pragma mark - Setters and getters

//- (void)setShuffleMode:(MPMusicShuffleMode)shuffleMode {
- (void)setShuffleMode:(BOOL)shuffleMode {
    _shuffleMode = shuffleMode;
    self.queue = self.originalQueue;
    if (shuffleMode) {
        self.indexOfNowPlayingItem = 0;
    }else
        self.indexOfNowPlayingItem = NSNotFound;
    
    for (id <MusicPlayerControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(musicPlayerdidShuffle:withCollections:)]) {
            [delegate musicPlayerdidShuffle:self withCollections:self.queue];
        }
    }
}

- (float)volume {
    return [MPMusicPlayerController systemMusicPlayer].volume;
}

- (void)setVolume:(float)volume {
    [MPMusicPlayerController systemMusicPlayer].volume = volume;
    for (id <MusicPlayerControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(musicPlayer:volumeChanged:)]) {
            [delegate musicPlayer:self volumeChanged:volume];
        }
    }
}

- (void)setOriginalQueue:(NSArray *)originalQueue {
    // The original queue never changes, while queue is shuffled
    _originalQueue = originalQueue;
    self.queue = _originalQueue;
}

- (void)setQueue:(NSArray *)queue {
    if (self.shuffleMode) {
        _queue = [queue shuffled];
        
        for (id <MusicPlayerControllerDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(musicPlayerdidShuffle:withCollections:)]) {
                [delegate musicPlayerdidShuffle:self withCollections:self.queue];
            }
        }
        
    }else{
        _queue = queue;
    }
}

- (void)setIndexOfNowPlayingItem:(NSUInteger)indexOfNowPlayingItem {
    
    if (indexOfNowPlayingItem == NSNotFound) {
        return;
    }
    _indexOfNowPlayingItem = indexOfNowPlayingItem;
    self.nowPlayingItem = (self.queue)[indexOfNowPlayingItem];
    
}

- (void)setNowPlayingItem:(NSDictionary *)nowPlayingItem {
//    NSDictionary *dict = nowPlayingItem; //self.queue[indexOfNowPlayingItem];
    [SVProgressHUD show];
    
    if (self.playerType == PlayerTypeRemote) {
        
        [SVProgressHUD dismiss];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        
        
        NSString *source = nowPlayingItem[@"stream_url"];
        if ([source rangeOfString:@"ca7s/storage"].location != NSNotFound) {
            NSString *streamUrl = @"https://www.ca7s.com";
            source = [streamUrl stringByAppendingString:nowPlayingItem[@"stream_url"]];
        }
        
        
        
        
      
       // NSURL *assetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",nowPlayingItem[@"stream_url"]]];

        
        
        
        
      NSURL *assetUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",source]];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:assetUrl];
        
        AVPlayer *player = [[AVPlayer alloc] init];// initWithURL:assetUrl];
        if (self.player!=nil) {
            self.player = player;
        }
        self.player.automaticallyWaitsToMinimizeStalling = true;
        if (self.player) {
            [self.player replaceCurrentItemWithPlayerItem:playerItem];
        } else {
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
        }
        [self.player playImmediatelyAtRate:0];
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndTimeNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    } else {
        [SVProgressHUD dismiss];
        NSURL *assetUrl = [NSUtil getPath:nowPlayingItem[@"title"]];
        self.localPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:assetUrl error:nil];
        self.strAlbumName = nowPlayingItem[@"albumName"];
    }
    
    
    [self doUpdateNowPlayingCenter];
    self.isLoadingAsset = NO;
    
    [self play];
    
    _nowPlayingItem = nowPlayingItem;
    NSDictionary *previousTrack = _nowPlayingItem;
    
    
//    id <MusicPlayerControllerDelegate> delegate = self.delegates[0];
    for (id <MusicPlayerControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(musicPlayer:trackDidChange:previousTrack:)]) {
            [delegate musicPlayer:self trackDidChange:_nowPlayingItem previousTrack:previousTrack];
        }
    }
    self.isLoadingAsset = YES;
}

- (void)playItemAtIndex:(NSUInteger)index {
    [self setIndexOfNowPlayingItem:index];
}

- (void)playItem:(NSDictionary *)item {
    NSUInteger indexOfItem = [self.queue indexOfObject:item];
    [self playItemAtIndex:indexOfItem];
}

// the callback method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    NSLog(@"[VideoView] player status: %li", (long)self.player.status);
    
    if (object == self.player.currentItem && [keyPath isEqualToString:@"status"]){
        if (self.player.currentItem.status == AVPlayerStatusReadyToPlay)
        {
            [self doUpdateNowPlayingCenter];
            
            for (id <MusicPlayerControllerDelegate> delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(musicPlayerDuration:setduration:)]) {
                    [delegate musicPlayerDuration:self setduration:self.player.currentItem];
                }
            }
        }
    }
}

- (void)handleAVPlayerItemDidPlayToEndTimeNotification {
    if (self.isLoadingAsset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.repeatMode == MPMusicRepeatModeOne) {
                // Play the same track again
                self.indexOfNowPlayingItem = self.indexOfNowPlayingItem;
                if (self.playbackState == MPMusicPlaybackStatePlaying) {
                    if (self.playerType == PlayerTypeRemote) {
                        [self.player play];
                    } else {
                        [self.localPlayer play];
                    }
                    
                }
            } else {
                // Go to next track
                if (self.playbackState == MPMusicPlaybackStatePlaying) {
                    [self skipToNextItem];
                    if (self.playerType == PlayerTypeRemote) {
                        [self.player play];
                    } else {
                        [self.localPlayer play];
                    }
                }
            }
        });
    }
}

- (void)doUpdateNowPlayingCenter {
    if (!self.updateNowPlayingCenter || !self.nowPlayingItem) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
    
        NSString *imageurl = self.nowPlayingItem[@"image_url"];
        NSData *data0 = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]];
        __block UIImage *image = [UIImage imageWithData:data0];
                
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
            NSMutableDictionary *songInfo;
            if (self.playerType == PlayerTypeRemote) {
                
                AVPlayerItem *currentItem = self.player.currentItem;
                NSTimeInterval duration = CMTimeGetSeconds(currentItem.duration);
                NSTimeInterval currentTime = CMTimeGetSeconds(currentItem.currentTime);
                
                
          //      NSLog("@@@@@@@@@@@ %@ @@@@@@@@@@@", self.nowPlayingItem)
                
                
                
                songInfo = [NSMutableDictionary dictionaryWithDictionary:@{MPMediaItemPropertyArtist: self.nowPlayingItem[@"artist"][@"name"] ?: @"", MPMediaItemPropertyTitle: self.nowPlayingItem[@"title"] ?: @"", MPMediaItemPropertyAlbumTitle: self.nowPlayingItem[@"album"][@"title"] ?: @"", MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:duration] ?:@0,MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:currentTime] }];
            } else {
                NSTimeInterval duration = self.localPlayer.duration;
                NSTimeInterval currentTime = self.localPlayer.currentTime;
                
                songInfo = [NSMutableDictionary dictionaryWithDictionary:@{MPMediaItemPropertyArtist:@"", MPMediaItemPropertyTitle: self.nowPlayingItem[@"title"] ?: @"", MPMediaItemPropertyAlbumTitle: self.nowPlayingItem[@"albumName"] ?: @"", MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:duration] ?:@0,MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:currentTime] }];
            }
            
            // Add the artwork if it exists
            if (image == nil) {
                image = [UIImage imageNamed:@"placeholder"];
            }
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
            if (artwork) {
                songInfo[MPMediaItemPropertyArtwork] = artwork;
            }
            center.nowPlayingInfo = songInfo;
            
        });
    });
}


- (void)setPlaybackState:(MPMusicPlaybackState)playbackState {
    if (playbackState == _playbackState) {
        return;
    }
    
    MPMusicPlaybackState oldState = _playbackState;
    _playbackState = playbackState;
    
    for (id <MusicPlayerControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(musicPlayer:playbackStateChanged:previousPlaybackState:)]) {
            [delegate musicPlayer:self playbackStateChanged:_playbackState previousPlaybackState:oldState];
        }
    }
}

- (void)handle_VolumeChanged:(NSNotification *)notification {
    
    float v;
    if (self.playerType == PlayerTypeRemote) {
        v = self.player.volume;
    } else {
        v = self.localPlayer.volume;
    }
    
    for (id <MusicPlayerControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(musicPlayer:volumeChanged:)]) {
            [delegate musicPlayer:self volumeChanged:v];
        }
    }
}

#pragma AVAudioPlayerDelegate Methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        
    }
}

#pragma mark - AVAudioSessionDelegate

- (void)beginInterruption {
    if (self.playbackState == MPMusicPlaybackStatePlaying) {
        self.interrupted = YES;
    }
    [self pause];
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
    if (self.interrupted && (flags & AVAudioSessionInterruptionOptionShouldResume)) {
        [self play];
    }
    self.interrupted = NO;
}

#pragma mark - Other public methods

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type != UIEventTypeRemoteControl) {
        return;
    }
    
    switch (receivedEvent.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause: {
            if (self.playbackState == MPMusicPlaybackStatePlaying) {
                [self pause];
            } else {
                [self play];
            }
            break;
        }
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self skipToNextItem];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self skipToPreviousItem];
            break;
            
        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;
            
        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;
            
        case UIEventSubtypeRemoteControlStop:
            [self stop];
            break;
            
        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            [self beginSeekingBackward];
            break;
            
        case UIEventSubtypeRemoteControlBeginSeekingForward:
            [self beginSeekingForward];
            break;
            
        case UIEventSubtypeRemoteControlEndSeekingBackward:
        case UIEventSubtypeRemoteControlEndSeekingForward:
            [self endSeeking];
            break;
            
        default:
            break;
    }
}

-(void)updateNowPlayingForKey:(NSDictionary *)newObject {
    _nowPlayingItem = newObject;
}

@end
