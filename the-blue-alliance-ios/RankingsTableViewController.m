//
//  RankingsTableViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/25/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "RankingsTableViewController.h"
#import "TBAImporter.h"
#import "RankingsTableViewCell.h"

@interface RankingsTableViewController ()
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) NSArray *headers;
@end

@implementation RankingsTableViewController

- (void)setEvent:(Event *)event {
    _event = event;
    
    if(event.rankings.length) {
        // This would be a good place for Swift's tuples
        NSArray *teams;
        NSArray *headers;
        [self parseRankings:event.rankings intoTeamsArray:&teams andHeadersArray:&headers];
        self.teams = teams;
        self.headers = headers;
        [self.tableView reloadData];
    } else {
        [TBAImporter importRankingsForEvent:_event usingManagedObjectContext:self.context callback:^(NSString *rankingsString) {
            NSArray *teams;
            NSArray *headers;
            [self parseRankings:rankingsString intoTeamsArray:&teams andHeadersArray:&headers];
            self.teams = teams;
            self.headers = headers;
            [self.tableView reloadData];
        }];
    }
   
}

- (void)parseRankings:(NSString *)rankingsString intoTeamsArray:(NSArray **)teams andHeadersArray:(NSArray **)headers {
    NSMutableArray *array = [[NSJSONSerialization JSONObjectWithData:[rankingsString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil] mutableCopy];
    NSArray *keys = [array firstObject];
    if(keys) {
        [array removeObjectAtIndex:0];
    }
    *headers = [keys copy];
    
    NSMutableArray *rankings = [[NSMutableArray alloc] init];
    for (NSArray *team in array) {
        NSDictionary *teamDict = [NSDictionary dictionaryWithObjects:team forKeys:keys];
        [rankings addObject:teamDict];
    }
    *teams = [rankings copy];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"RankingsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Rankings Cell"];
    self.tableView.rowHeight = 80;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Rankings Cell" forIndexPath:indexPath];
    
    NSDictionary *rankedTeamData = self.teams[indexPath.row];
    [cell setRankedTeamData:rankedTeamData forHeaderKeys:self.headers];
    
    return cell;
}


@end
