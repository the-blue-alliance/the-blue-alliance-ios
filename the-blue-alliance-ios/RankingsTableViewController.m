//
//  RankingsTableViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/25/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "RankingsTableViewController.h"
#import "TBAImporter.h"

@interface RankingsTableViewController ()
@property (nonatomic, strong) NSArray *rankings;
@end

@implementation RankingsTableViewController

- (void)setEvent:(Event *)event {
    _event = event;
    
    if(event.rankings.length) {
        self.rankings = [self parseRankings:event.rankings];
    } else {
        [TBAImporter importRankingsForEvent:_event usingManagedObjectContext:self.context callback:^(NSString *rankingsString) {
            self.rankings = [self parseRankings:rankingsString];
        }];
    }
   
}

- (NSArray *)parseRankings:(NSString *)rankingsString {
    NSMutableArray *array = [[NSJSONSerialization JSONObjectWithData:[rankingsString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil] mutableCopy];
    NSArray *keys = [array firstObject];
    if(keys) {
        [array removeObjectAtIndex:0];
    }
    
    NSMutableArray *rankings = [[NSMutableArray alloc] init];
    for (NSArray *team in array) {
        NSDictionary *teamDict = [NSDictionary dictionaryWithObjects:team forKeys:keys];
        [rankings addObject:teamDict];
    }
    
    return rankings;
}
- (void)setRankings:(NSArray *)rankings {
    _rankings = rankings;
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Rankings Cell"];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rankings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Rankings Cell" forIndexPath:indexPath];
    
    NSDictionary *rankedTeam = self.rankings[indexPath.row];
    cell.textLabel.text = rankedTeam[@"Team"];
    
    return cell;
}


@end
