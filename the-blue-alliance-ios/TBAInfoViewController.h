//
//  TBAInfoViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/9/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team, Event;

@interface TBAInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) Team *team;
@property (nonatomic, copy) NSArray *media;

@property (nonatomic, weak) Event *event;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
