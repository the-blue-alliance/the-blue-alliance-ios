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
    
    NSLog(@"Sections: %@", sections);
}

- (NSArray *)generateSectionsForMatches:(NSArray *)matches {
    return matches;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Match Cell"];
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.matches.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Match Cell" forIndexPath:indexPath];
//    
//    Match *match = self.matches[indexPath.row];
//    cell.textLabel.text = match.key;
//    
//    return cell;
//}

@end
