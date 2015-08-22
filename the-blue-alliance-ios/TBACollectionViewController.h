//
//  TBACollectionViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 8/22/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBACollectionViewController : UICollectionViewController

- (void)showNoDataViewWithText:(NSString *)text;
- (void)hideNoDataView;

@end
