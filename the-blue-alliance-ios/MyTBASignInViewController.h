//
//  MyTBASignInViewController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/5/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAViewController.h"

@interface MyTBASignInViewController : TBAViewController

@property (nonatomic, copy) void (^signIn)();

@end
