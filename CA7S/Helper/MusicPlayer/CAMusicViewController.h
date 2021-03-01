#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@class CAMusicViewController;

@protocol MusicPlayerControllerDelegate <NSObject>
@optional
- (void)musicPlayer:(CAMusicViewController *)musicPlayer trackDidChange:(NSDictionary *)nowPlayingItem previousTrack:(NSDictionary *)previousTrack;
- (void)musicPlayer:(CAMusicViewController *)musicPlayer endOfQueueReached:(NSDictionary *)lastTrack;
- (void)musicPlayer:(CAMusicViewController *)musicPlayer playbackStateChanged:(MPMusicPlaybackState)playbackState previousPlaybackState:(MPMusicPlaybackState)previousPlaybackState;
- (void)musicPlayer:(CAMusicViewController *)musicPlayer volumeChanged:(float)volume;
- (void)musicPlayerdidShuffle:(CAMusicViewController *)musicPlayer withCollections:(NSArray *)collections;
- (void)musicPlayerDuration:(CAMusicViewController *)musicPlayer setduration:(AVPlayerItem *)item;

@end

typedef NS_ENUM(NSInteger, PlayerType) {
    PlayerTypeRemote = 0,
    PlayerTypeLocal
};

@interface CAMusicViewController : NSObject<MPMediaPlayback>

@property (strong, nonatomic, readonly) NSDictionary *nowPlayingItem;
@property (nonatomic) MPMusicPlaybackState playbackState;
@property (nonatomic) MPMusicRepeatMode repeatMode; // note: MPMusicRepeatModeDefault is not supported
//@property (nonatomic) MPMusicShuffleMode shuffleMode; // note: only MPMusicShuffleModeOff and MPMusicShuffleModeSongs are supported
@property (nonatomic) float volume; // 0.0 to 1.0
@property (nonatomic, readonly) NSUInteger indexOfNowPlayingItem; // NSNotFound if no queue
@property (nonatomic) BOOL updateNowPlayingCenter; // default YES
@property (nonatomic, readonly) NSArray *queue;
@property (nonatomic) BOOL shouldReturnToBeginningWhenSkippingToPreviousItem; // default YES
@property (nonatomic) BOOL shuffleMode;
@property (nonatomic, strong) NSString *strAlbumName;
@property (nonatomic, strong) NSString *strAlbumID;
@property (nonatomic) PlayerType playerType;

/*!
 @brief method for initiat class
 @return id - The id of the object.
 */
+ (CAMusicViewController *)sharedInstance;

/*!
 @brief method for adding delegates
 */
- (void)addDelegate:(id<MusicPlayerControllerDelegate>)delegate;

/*!
 @brief method for removing delegates
 */
- (void)removeDelegate:(id<MusicPlayerControllerDelegate>)delegate;

/*!
 @brief method to detect user actions from notification center and take actions accordingly
 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;

/*!
 @brief method to set items in queue
 */
- (void)setQueueWithItemCollection:(NSMutableArray *)itemCollection;

/*!
 @brief method to set items in queue form media query
 */
- (void)setQueueWithQuery:(MPMediaQuery *)query;

/*!
 @brief method for skip to next queue item
 */
- (void)skipToNextItem;

/*!
 @brief method for seek to beginning of current item
 */
- (void)skipToBeginning;

/*!
 @brief method for go to previous item in queue
 */
- (void)skipToPreviousItem;

/*!
 @brief method for play item an given index
 */
- (void)playItemAtIndex:(NSUInteger)index;

/*!
 @brief method for play aiven item
 */
- (void)playItem:(NSDictionary *)item;

/*!
 @brief method for pause player
 */
- (void)pause;

-(NSTimeInterval)getTrackDuration;

-(CGAffineTransform)rotateAndScane:(UIButton *)View;

-(void)updateNowPlayingForKey:(NSDictionary *)newObject;
@end
