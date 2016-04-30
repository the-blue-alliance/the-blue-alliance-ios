//
//  TBAContainerViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/4/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TBAContainerViewController.h"
#import "TBANoDataViewController.h"
#import "TBARefreshViewController.h"

@interface TBAContainerViewController ()

@property (nonatomic, strong) TBANoDataViewController *noDataViewController;
@property (nonatomic, strong) id changeObserver;

@end

@implementation TBAContainerViewController

#pragma mark - View Lifecycle

- (void)dealloc {
    [self removeChangeObserver];
}

#pragma mark - Private Methods

- (void)removeChangeObserver {
    if (self.changeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.changeObserver];
    }
}

#pragma mark - Public Methods

- (void)registerForChangeNotifications:(void (^_Nonnull)(id _Nonnull changedObject))changeBlock {
    [self removeChangeObserver];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:self.persistenceController.managedObjectContext queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSSet *updatedObjects = note.userInfo[NSUpdatedObjectsKey];
        for (NSManagedObject *obj in updatedObjects) {
            changeBlock(obj);
        }
    }];
}

- (void)showErrorAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)showNoDataViewWithText:(NSString *)text {
    if (!self.noDataViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.noDataViewController = [storyboard instantiateViewControllerWithIdentifier:@"NoDataViewController"];
    }
    
    self.noDataViewController.view.alpha = 0.0f;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.noDataViewController.view];
    });
    
    if (text) {
        self.noDataViewController.textLabel.text = text;
    } else {
        self.noDataViewController.textLabel.text = @"No data to display";
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.noDataViewController.view.alpha = 1.0f;
    }];
}

- (void)hideNoDataView {
    if (self.noDataViewController) {
        [self.noDataViewController.view removeFromSuperview];
    }
}

@end
