//
//  TBANavigationControllerDelegate.h
//  the-blue-alliance
//
//  Created by Zach Orr on 12/28/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** TBANavigationControllerDelegate exists only to remove the back button text from the left bar button items
 ** in navigation controllers, since the back button text is of widly varying sizes throughout the app
 */
@interface TBANavigationControllerDelegate : NSObject <UINavigationControllerDelegate>

@end
