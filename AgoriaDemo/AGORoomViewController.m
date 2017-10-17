//
//  AGORoomViewController.m
//  AgoriaDemo
//
//  Created by Hayden on 2017/9/1.
//  Copyright © 2017 Wilddog. All rights reserved.
//

#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "AGORoomViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoCollectionViewCell.h"


@interface AGORoomViewController () <AgoraRtcEngineDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIView *localView;
@property (nonatomic, strong) NSMutableArray<AgoraRtcVideoCanvas *> *streams;
@property (nonatomic, strong) NSMutableDictionary *videoDic;

@property (nonatomic, weak) IBOutlet UICollectionView *grid;

@end


@implementation AGORoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    _streams = [[NSMutableArray alloc] init];
    _videoDic = [[NSMutableDictionary alloc] init];
    [self setupCollectionView];
    
    [self initializeAgoraEngine];
    [self setupVideo];
    [self setupLocalStream];
    [self joinRoom];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = self.roomId;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)initializeAgoraEngine {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"87ab7830d80c4a15ab127379115bf9b8" delegate:self];
}

- (void)setupVideo {
    [self.agoraKit enableVideo];
    [self.agoraKit setVideoProfile:self.dimension swapWidthAndHeight:false];
}

- (void)setupLocalStream {
    AgoraRtcVideoCanvas *localCanvas = [[AgoraRtcVideoCanvas alloc] init];
    localCanvas.uid = 0;
    localCanvas.view = self.localView;
    localCanvas.renderMode = AgoraRtc_Render_Hidden;
    [self.streams addObject:localCanvas];
    [self.grid reloadData];
    //[self.agoraKit setupLocalVideo:localCanvas];
    //[self.agoraKit startPreview];
}

- (void)joinRoom {
    [self.agoraKit joinChannelByKey:nil channelName:self.roomId info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        [self.agoraKit setEnableSpeakerphone:YES];
    }];
}

- (void)leaveRoom {
    [self.agoraKit leaveChannel:nil];
    self.agoraKit = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    AgoraRtcVideoCanvas *remoteCanvas = [[AgoraRtcVideoCanvas alloc] init];
    remoteCanvas.uid = uid;
    remoteCanvas.renderMode = AgoraRtc_Render_Hidden;
    self.videoDic[@(uid)] = remoteCanvas;
    [self.streams addObject:remoteCanvas];
    [self.grid reloadData];
    //[self.agoraKit setupRemoteVideo:remoteCanvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason {
    AgoraRtcVideoCanvas *remoteStream = self.videoDic[@(uid)];
    remoteStream.view = nil;
    [self.streams removeObject:remoteStream];
    [self.grid reloadData];
}


#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.streams.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"CELL";
    VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
    //cell.videoView.contentMode = UIViewContentModeScaleAspectFill;
    self.streams[indexPath.row].view = cell.videoView;
    if (indexPath.row == 0) {
        self.localView = cell.videoView;
        [self.agoraKit setupLocalVideo:self.streams[indexPath.row]];
    }
    [self.agoraKit setupRemoteVideo:self.streams[indexPath.row]];
    return cell;
}


#pragma mark - WDGRoomDelegate

//- (void)wilddogRoomDidConnect:(WDGRoom *)wilddogRoom {
//    NSLog(@"Room Connected!");
//    // 发布本地流
//    [self publishLocalStream];
//}
//
//- (void)wilddogRoomDidDisconnect:(WDGRoom *)wilddogRoom {
//    NSLog(@"Room Disconnected!");
//    //__weak __typeof__(self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //__strong __typeof__(self) strongSelf = weakSelf;
//        NSLog(@"Disconnected!");
//        [self dismissViewControllerAnimated:YES completion:NULL];
//    });
//}
//
//- (void)wilddogRoom:(WDGRoom *)wilddogRoom didStreamAdded:(WDGRoomStream *)roomStream {
//    NSLog(@"RoomStream Added!");
//    [self subscribeRoomStream:roomStream];
//}
//
//- (void)wilddogRoom:(WDGRoom *)wilddogRoom didStreamRemoved:(WDGRoomStream *)roomStream {
//    NSLog(@"RoomStream Removed!");
//    [self unsubscribeRoomStream:roomStream];
//    [self.streams removeObject:roomStream];
//    [self.grid reloadData];
//}
//
//- (void)wilddogRoom:(WDGRoom *)wilddogRoom didStreamReceived:(WDGRoomStream *)roomStream {
//    NSLog(@"RoomStream Received!");
//    [self.streams addObject:roomStream];
//    [self.grid reloadData];
//}
//
//- (void)wilddogRoom:(WDGRoom *)wilddogRoom didFailWithError:(NSError *)error {
//    NSLog(@"Room Failed: %@", error);
//    if (error) {
//        NSString *errorMessage = [NSString stringWithFormat:@"会议错误: %@", [error localizedDescription]];
//        [self showAlertWithTitle:@"提示" message:errorMessage];
//    }
//}

#pragma mark - Internal methods

- (void)setupCollectionView {
    self.grid.dataSource = self;
    self.grid.delegate = self;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = (self.view.bounds.size.width - 24) / 2;
    CGFloat height = (self.view.bounds.size.height - 162) / 3;
    flowLayout.itemSize = CGSizeMake(width, height);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumLineSpacing = 8;
    flowLayout.minimumInteritemSpacing = 0;
    self.grid.collectionViewLayout = flowLayout;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Action Buttons

//- (IBAction)switchCameraButtonTapped:(id)sender {
//    [self.localStream switchCamera];
//    self.localView.mirror = !self.localView.mirror;
//    //self.attachedViews[self.uid].mirror = !self.attachedViews[self.uid].mirror;
//}

- (void)didSessionRouteChange:(NSNotification *)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonCategoryChange: {
            // Set speaker as default route
            NSError* error;
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        }
            break;
        default:
            break;
    }
}

- (IBAction)disconnect:(id)sender {
    [self leaveRoom];
}

@end
