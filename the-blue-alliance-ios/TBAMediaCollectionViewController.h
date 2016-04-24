//
//  TBAMediaCollectionViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/17/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBARefreshCollectionViewController.h"

@class Team;

@interface TBAMediaCollectionViewController : TBARefreshCollectionViewController <TBACollectionViewControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) NSNumber *year;

@end
