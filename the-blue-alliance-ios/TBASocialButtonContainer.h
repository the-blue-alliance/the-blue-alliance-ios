//
//  TBASocialButtonContainer.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 9/2/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TBASocialButtonContainerButtonType) {
    TBASocialButtonContainerButtonTypeNone = 0,
    TBASocialButtonContainerButtonTypeWebsite,
    TBASocialButtonContainerButtonTypeTwitter,
    TBASocialButtonContainerButtonTypeYoutube,
    TBASocialButtonContainerButtonTypeChiefDelphi
};
@interface TBASocialButtonContainer : UIControl

@property (nonatomic) TBASocialButtonContainerButtonType selectedButtonType;

@end
