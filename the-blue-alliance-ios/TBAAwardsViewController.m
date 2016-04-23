//
//  TBAAwardsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAAwardsViewController.h"
#import "TBAAwardTableViewCell.h"
#import "Award.h"
#import "AwardRecipient.h"
#import "Event.h"
#import "Team.h"

static NSString *const AwardCellReuseIdentifier = @"AwardCell";

@implementation TBAAwardsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Award"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"event == %@", self.event]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"awardType" ascending:YES]]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tbaDelegate = self;
    self.cellIdentifier = AwardCellReuseIdentifier;
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf hideNoDataView];
        [strongSelf refreshAwards];
    };
}

#pragma mark - Data Methods

- (void)refreshAwards {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchAwardsForEventKey:self.event.key withCompletionBlock:^(NSArray *awards, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload event matches"];
        } else {
            [strongSelf.persistenceController performChanges:^{
                [Award insertAwardsWithModelAwards:awards forEvent:strongSelf.event inManagedObjectContext:strongSelf.persistenceController.backgroundObjectContext];
            }];
        }
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBAAwardTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Award *award = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.award = award;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No awards for this event"];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
}

@end
