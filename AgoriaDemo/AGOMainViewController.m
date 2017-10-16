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
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *resolutionControl;

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
    switch (self.resolutionControl.selectedSegmentIndex) {
        case 0:
            roomViewController.dimension = AgoraRtc_VideoProfile_360P;
            break;
        case 1:
            roomViewController.dimension = AgoraRtc_VideoProfile_480P;
            break;
        case 2:
            roomViewController.dimension = AgoraRtc_VideoProfile_720P;
            break;
        default:
            roomViewController.dimension = AgoraRtc_VideoProfile_360P;
            break;
    }
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
