//
//  TBANavigationController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/20/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAPersistenceController.h"

@interface TBANavigationController : UINavigationController

@property (nonatomic, strong) TBAPersistenceController *persistenceController;

@end
