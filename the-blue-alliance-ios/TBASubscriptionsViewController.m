//
//  TBASubscriptionsViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/5/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBASubscriptionsViewController.h"
#import "Subscription.h"

static NSString *const SubscriptionsCellIdentifier  = @"SubscriptionsCell";

@interface TBASubscriptionsViewController ()

@end

@implementation TBASubscriptionsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Properities

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    if (!self.persistenceController) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Subscription"];
    
    NSSortDescriptor *typeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"modelType" ascending:YES];
    [fetchRequest setSortDescriptors:@[typeSortDescriptor]];
    
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

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tbaDelegate = self;
    self.cellIdentifier = SubscriptionsCellIdentifier;
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf refreshSubscriptions];
    };
}


#pragma mark - Data Methods

- (BOOL)shouldNoDataRefresh {
    return self.fetchedResultsController.fetchedObjects.count == 0;
}

- (void)refreshSubscriptions {
    if (![TBAKit sharedKit].myTBAAuthentication) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    __block GTMSessionFetcher *fetcher = [[TBAKit sharedKit] fetchSubscriptionsWithCompletionBlock:^(NSArray<TBASubscription *> *subscriptions, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showErrorAlertWithMessage:@"Unable to load favorites"];
            NSLog(@"Error: %@", error);
        }
        
        [strongSelf.persistenceController performChanges:^{
            [Subscription insertSubscriptionsWithModelSubscriptions:subscriptions inManagedObjectContext:strongSelf.persistenceController.backgroundManagedObjectContext];
        } withCompletion:^{
            [strongSelf removeSessionFetcher:fetcher];
        }];
    }];
    [self addSessionFetcher:fetcher];
}

#pragma mark - TBA Table View Data Source

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Subscription *subscription = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = subscription.modelKey;
}

- (void)showNoDataView {
    [self showNoDataViewWithText:@"No subscriptions found"];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Do something in here with selected favorite - probably look at type and push out
}

@end
