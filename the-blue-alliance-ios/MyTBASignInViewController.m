//
//  MyTBASignInViewController.m
//  the-blue-alliance
//
//  Created by Zach Orr on 5/5/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "MyTBASignInViewController.h"

@interface MyTBASignInViewController ()

@end

@implementation MyTBASignInViewController

- (IBAction)signInTapped:(id)sender {
    if (self.signIn) {
        self.signIn();
    }
}

@end
