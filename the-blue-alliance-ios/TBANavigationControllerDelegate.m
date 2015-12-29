//
//  TBANavigationControllerDelegate.m
//  the-blue-alliance
//
//  Created by Zach Orr on 12/28/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "TBANavigationControllerDelegate.h"

@implementation TBANavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
