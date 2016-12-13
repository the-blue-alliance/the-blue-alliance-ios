//
//  TBANavigationController.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/20/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreData;

@interface TBANavigationController : UINavigationController

@property (nonatomic, strong) NSPersistentContainer *persistentContainer;

@end
