//
//  MatchResultsTableViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/25/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "MatchResultsTableViewController.h"
#import "Match.h"
#import "TBAImporter.h"
#import "MatchResultsTableViewCell.h"

@interface MatchResultsTableViewController ()
@property (nonatomic, strong) NSArray *sections;
@end

@implementation MatchResultsTableViewController

- (void)setEvent:(Event *)event {
    _event = event;
    
    if(_event.matches.count) {
        self.sections = [self generateSectionsForMatches:[_event.matches allObjects]];
    } else {
        [TBAImporter importMatchesForEvent:self.event usingManagedObjectContext:self.context callback:^(NSSet *matches) {
            self.sections = [self generateSectionsForMatches:[matches allObjects]];
        }];
    }
}

- (void)setSections:(NSArray *)sections {
    _sections = sections;
    [self.tableView reloadData];
}

- (NSArray *)generateSectionsForMatches:(NSArray *)matches {
    // Get the types of matches
    NSArray *quals = [matches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"comp_level = %@", @"qm"]];
    NSArray *efs = [matches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"comp_level = %@", @"ef"]];
    NSArray *qfs = [matches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"comp_level = %@", @"qf"]];
    NSArray *sfs = [matches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"comp_level = %@", @"sf"]];
    NSArray *fs = [matches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"comp_level = %@", @"f"]];
    
    // Sort the matches by match number
    NSSortDescriptor *matchNumSort = [NSSortDescriptor sortDescriptorWithKey:@"match_number" ascending:NO];
    NSSortDescriptor *setNumSort = [NSSortDescriptor sortDescriptorWithKey:@"set_number" ascending:NO];
    NSArray *elimsSorter = @[setNumSort, matchNumSort];

    quals = [quals sortedArrayUsingDescriptors:@[matchNumSort]];
    efs = [efs sortedArrayUsingDescriptors:elimsSorter];
    qfs = [qfs sortedArrayUsingDescriptors:elimsSorter];
    sfs = [sfs sortedArrayUsingDescriptors:elimsSorter];
    fs = [fs sortedArrayUsingDescriptors:elimsSorter];

    // Create sections for the match types
    NSDictionary *qualsSection = @{@"title": @"Qualification Matches",
                                   @"objects": quals};
    NSDictionary *efsSection = @{@"title": @"Eighthfinal Matches",
                                   @"objects": efs};
    NSDictionary *qfsSection = @{@"title": @"Quarterfinal Matches",
                                   @"objects": qfs};
    NSDictionary *sfsSection = @{@"title": @"Semifinal Matches",
                                 @"objects": sfs};
    NSDictionary *fsSection = @{@"title": @"Final Matches",
                                 @"objects": fs};
    
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    if([fsSection[@"objects"] count]) {
        [sections addObject:fsSection];
    }
    if([sfsSection[@"objects"] count]) {
        [sections addObject:sfsSection];
    }
    if([qfsSection[@"objects"] count]) {
        [sections addObject:qfsSection];
    }
    if([efsSection[@"objects"] count]) {
        [sections addObject:efsSection];
    }
    if([qualsSection[@"objects"] count]) {
        [sections addObject:qualsSection];
    }
    
    return sections;
}


- (NSString *)title {
    return @"Results";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MatchResultsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Match Cell"];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Match Cell"];
    self.tableView.rowHeight = 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section][@"objects"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"title"];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MatchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Match Cell" forIndexPath:indexPath];
//
//    if(!cell) {
//        cell = [[MatchResultsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Match Cell"];
//    }

    
    Match *match = self.sections[indexPath.section][@"objects"][indexPath.row];
    cell.match = match;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor TBATableViewSeparatorColor];
}


@end
