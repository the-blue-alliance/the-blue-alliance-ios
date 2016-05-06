//
//  TBAAlliancesTableViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 1/10/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBAAlliancesViewController.h"
#import "EventTeamViewController.h"
#import "Event.h" 
#import "Team.h"
#import "EventAlliance.h"
#import "TBAAllianceCell.h"

static NSString *const AllianceCellReuseIdentifier  = @"AllianceCell";
static NSString *const EventTeamViewControllerSegue = @"EventTeamViewControllerSegue";

@interface TBAAlliancesViewController ()
@property (nonatomic, strong) Team *selectedTeam;
@end

@implementation TBAAlliancesViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if (!self.persistenceController) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EventAlliance"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@", self.event];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *allianceNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"allianceNumber" ascending:YES];
    [fetchRequest setSortDescriptors:@[allianceNumberSortDescriptor]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistenceController.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tbaDelegate = self;
    self.cellIdentifier = AllianceCellReuseIdentifier;
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshEvent];
    };
}

#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshEvent {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventForEventKey:self.event.key withCompletionBlock:^(TBAEvent *event, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to reload team info"];
        }
        
        [strongSelf.persistenceController performChanges:^{
            [Event insertEventWithModelEvent:event inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeRequestIdentifier:request];
        }];
    }];
    [self addRequestIdentifier:request];
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(TBAAllianceCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EventAlliance *alliance = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.eventAlliance = alliance;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No alliances for this event"];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

#pragma mark - Alliance Cell Delegate

- (void)teamNumberTapped:(NSString *)teamNumber {
    NSFetchRequest *teamFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"teamNumber == %@", [Team teamNumberFromNumberString:teamNumber]]];
    [teamFetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchResults = [self.persistenceController.managedObjectContext executeFetchRequest:teamFetchRequest error:&error];
    if (!error) {
        Team *team = (Team *)[fetchResults firstObject];
        self.selectedTeam = team;
        [self performSegueWithIdentifier:EventTeamViewControllerSegue sender:nil];
    } else {
        // Something has gone terribly wrong. Bail out!
        NSLog(@"Error while searching for team from Event Stats: %@", error);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([EventTeamViewControllerSegue isEqualToString:segue.identifier]) {
        EventTeamViewController *eventTeamController = [segue destinationViewController];
        eventTeamController.event = self.event;
        eventTeamController.team = self.selectedTeam;
    }
}

@end
