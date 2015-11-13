//
//  TBAMediaCollectionViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/17/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBACollectionViewController.h"

@class Team;

@interface TBAMediaCollectionViewController : TBACollectionViewController <TBACollectionViewControllerDelegate>

@property (nonatomic, strong) Team *team;
@property (nonatomic, assign) NSUInteger year;

@end
