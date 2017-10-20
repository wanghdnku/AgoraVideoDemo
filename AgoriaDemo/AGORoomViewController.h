//
//  AGORoomViewController.h
//  AgoriaDemo
//
//  Created by Hayden on 2017/9/1.
//  Copyright © 2017 Wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGORoomViewController : UIViewController

@property (nonatomic, strong) NSString *roomId;

@property (nonatomic, assign) NSInteger dimension;
@property (nonatomic, assign) int frame;
@property (nonatomic, assign) int fps;

@end
