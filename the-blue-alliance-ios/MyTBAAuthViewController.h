//
//  MyTBAAuthViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/6/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTBAAuthViewController : UIViewController

@property (nonatomic, copy) void (^authSucceeded)();
@property (nonatomic, copy) void (^authFailed)(NSError *error);


@end
