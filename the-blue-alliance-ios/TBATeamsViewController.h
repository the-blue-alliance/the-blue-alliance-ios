//
//  TBATeamsViewController.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/8/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBATableViewController.h"

@class Team;

@interface TBATeamsViewController : TBATableViewController <UISearchBarDelegate>

@property (nonatomic, copy) NSArray *teams;
@property (nonatomic, assign) BOOL showSearch;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, copy) void (^teamSelected)(Team *team);

@end
