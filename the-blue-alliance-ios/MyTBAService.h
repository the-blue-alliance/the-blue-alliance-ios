//
//  GTLServiceMyTBA.h
//  the-blue-alliance
//
//  Created by Zach Orr on 5/5/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBAFavorite, MyTBAAuthenticaion;

typedef void (^MyTBARequestCompletionBlock)(NSURLResponse *response, id parsedData, NSError *error);

@interface MyTBAService : NSObject

@property (nonatomic, strong) MyTBAAuthenticaion *authentication;

+ (instancetype)sharedService;

// Authentication
- (void)removeAuthentication;

// Favorites

- (NSUInteger)fetchFavorites:(void (^)(NSArray<TBAFavorite *> *favorites, NSError *error))completion;

@end
