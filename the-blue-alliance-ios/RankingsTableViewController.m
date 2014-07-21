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
#import "Team+Fetch.h"

@interface RankingsTableViewController ()
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, strong) NSDictionary *teamNumbersToTeams;
@end

@implementation RankingsTableViewController

- (void)setEvent:(Event *)event {
    _event = event;
    
    if(event.rankings.length) {
        // This would be a good place for Swift's tuples
        NSArray *teams;
        NSArray *headers;
        NSDictionary *teamNumbersToTeams;
        [self parseRankings:event.rankings intoTeamsArray:&teams andHeadersArray:&headers andTeamNumbersToTeams:&teamNumbersToTeams];
        self.teams = teams;
        self.headers = headers;
        self.teamNumbersToTeams = teamNumbersToTeams;
        
        [self.tableView reloadData];
    } else {
        [TBAImporter importRankingsForEvent:_event usingManagedObjectContext:self.context callback:^(NSString *rankingsString) {
            NSArray *teams;
            NSArray *headers;
            NSDictionary *teamNumbersToTeams;
            [self parseRankings:rankingsString intoTeamsArray:&teams andHeadersArray:&headers andTeamNumbersToTeams:&teamNumbersToTeams];
            self.teams = teams;
            self.headers = headers;
            self.teamNumbersToTeams = teamNumbersToTeams;
            
            [self.tableView reloadData];
        }];
    }
   
}

- (void)parseRankings:(NSString *)rankingsString intoTeamsArray:(NSArray **)teams andHeadersArray:(NSArray **)headers andTeamNumbersToTeams:(NSDictionary **)numbersToTeams {
    NSMutableArray *array = [[NSJSONSerialization JSONObjectWithData:[rankingsString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil] mutableCopy];
    NSArray *keys = [array firstObject];
    if(keys) {
        [array removeObjectAtIndex:0];
    }
    *headers = [keys copy];
    
    NSMutableArray *rankings = [[NSMutableArray alloc] init];
    NSMutableSet *teamKeys = [[NSMutableSet alloc] initWithCapacity:array.count];
    for (NSArray *team in array) {
        NSDictionary *teamDict = [NSDictionary dictionaryWithObjects:team forKeys:keys];
        [rankings addObject:teamDict];
        [teamKeys addObject:[NSString stringWithFormat:@"frc%@", teamDict[@"Team"]]];
    }
    *teams = [rankings copy];
    
    NSMutableDictionary *tempNumbersToTeam = [[NSMutableDictionary alloc] initWithCapacity:array.count];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"key IN %@", teamKeys];
    
    NSError *error = nil;
    NSArray *fetchedTeams = [self.event.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedTeams == nil) {
        NSLog(@"Core Data error: %@", error);
    } else {
        for (Team *team in fetchedTeams) {
            tempNumbersToTeam[[team.team_number description]] = team;
        }
    }
    
    NSLog(@"FETCHED TEAMS FOR RANKINGS!");
    
    *numbersToTeams = [tempNumbersToTeam copy];
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
    [cell setRankedTeamData:rankedTeamData forHeaderKeys:self.headers withTeam:self.teamNumbersToTeams[rankedTeamData[@"Team"]]];
    
    return cell;
}


@end
