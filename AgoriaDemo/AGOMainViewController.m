//
//  AGOMainViewController.m
//  AgoriaDemo
//
//  Created by Hayden on 2017/9/1.
//  Copyright © 2017 Wilddog. All rights reserved.
//

#import "AGOMainViewController.h"
#import "AGORoomViewController.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>


@interface AGOMainViewController ()

@property (nonatomic, weak) IBOutlet UITextField *roomIdTextField;
@property (nonatomic, weak) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *resolutionControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *frameControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fpsControl;

@end

@implementation AGOMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Maybe login here.
}

- (IBAction)joinButtonDidTapped:(id)sender {
    
    // 页面传值
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"roomNavigationController"];
    AGORoomViewController *roomViewController = navigationController.viewControllers.firstObject;
    // 传递获得的 roomId，如果不输入，默认为 'roomid'
    NSString *roomId = @"roomid";
    if (![self.roomIdTextField.text isEqualToString:@""]) {
        roomId = self.roomIdTextField.text;
    }
    roomViewController.roomId = roomId;
    switch (self.frameControl.selectedSegmentIndex) {
        case 0:
            roomViewController.frame = 6;
            break;
        case 1:
            roomViewController.frame = 4;
            break;
        default:
            roomViewController.frame = 1;
            break;
    }
    switch (self.resolutionControl.selectedSegmentIndex) {
        case 0:
            if (self.fpsControl.selectedSegmentIndex == 0) {
                roomViewController.dimension = AgoraRtc_VideoProfile_360P;
            } else {
                roomViewController.dimension = AgoraRtc_VideoProfile_360P_4;
            }
            break;
        case 1:
            if (self.fpsControl.selectedSegmentIndex == 0) {
                roomViewController.dimension = AgoraRtc_VideoProfile_480P;
            } else {
                roomViewController.dimension = AgoraRtc_VideoProfile_480P_4;
            }
            break;
        case 2:
            if (self.fpsControl.selectedSegmentIndex == 0) {
                roomViewController.dimension = AgoraRtc_VideoProfile_720P;
            } else {
                roomViewController.dimension = AgoraRtc_VideoProfile_720P_3;
            }
            break;
        default:
            roomViewController.dimension = AgoraRtc_VideoProfile_360P;
            break;
    }
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
