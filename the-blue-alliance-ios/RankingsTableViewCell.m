//
//  RankingsTableViewCell.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/19/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "RankingsTableViewCell.h"
#import "ColumnView.h"

@interface NSMutableArray (RemoveMatching)
- (void)removeAllObjectsPassingTest:(BOOL (^)(id obj))predicate;
@end

@implementation NSMutableArray (RemoveMatching)
- (void)removeAllObjectsPassingTest:(BOOL (^)(id obj))predicate {
    NSIndexSet *set = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return predicate(obj);
    }];
    [self removeObjectsAtIndexes:set];
}
@end

@interface RankingsTableViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *teamNumberLabel;
@property (nonatomic, weak) IBOutlet UILabel *rankLabel;
@property (nonatomic, weak) IBOutlet UILabel *recordLabel;

@property (nonatomic, weak) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet ColumnView *testColumnView;
@end

@implementation RankingsTableViewCell

- (void)setRankedTeamData:(NSDictionary *)team forHeaderKeys:(NSArray *)headersImmutable withTeam:(Team *)teamObj
{
    NSMutableArray *headers = [headersImmutable mutableCopy];
    [headers removeAllObjectsPassingTest:^BOOL(NSString *obj) {
        return [obj.lowercaseString rangeOfString:@"played"].location != NSNotFound;
    }];
    [headers removeAllObjectsPassingTest:^BOOL(NSString *obj) {
        return [obj.lowercaseString rangeOfString:@"rank"].location != NSNotFound;
    }];
    [headers removeAllObjectsPassingTest:^BOOL(NSString *obj) {
        return [obj.lowercaseString rangeOfString:@"record"].location != NSNotFound;
    }];
    [headers removeAllObjectsPassingTest:^BOOL(NSString *obj) {
        return [obj.lowercaseString rangeOfString:@"win"].location != NSNotFound;
    }];
    [headers removeAllObjectsPassingTest:^BOOL(NSString *obj) {
        return [obj.lowercaseString rangeOfString:@"loss"].location != NSNotFound;
    }];
    [headers removeAllObjectsPassingTest:^BOOL(NSString *obj) {
        return [obj.lowercaseString rangeOfString:@"tie"].location != NSNotFound;
    }];
    [headers removeAllObjectsPassingTest:^BOOL(NSString *obj) {
        return [obj.lowercaseString rangeOfString:@"team"].location != NSNotFound;
    }];
    [headers removeAllObjectsPassingTest:^BOOL(NSString *obj) {
        return [obj.lowercaseString rangeOfString:@"qs"].location != NSNotFound;
    }];
    
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:headers.count];
    for(NSString *header in headers) {
        
        [values addObject:[[team[header] description] stringByReplacingOccurrencesOfString:@".00" withString:@""]];
    }
    
    self.testColumnView.topRow = headers;
    self.testColumnView.bottomRow = values;
    
    
    self.teamNumberLabel.text = [NSString stringWithFormat:@"%@", team[@"Team"]];
    self.rankLabel.text = [NSString stringWithFormat:@"Rank %@", team[@"Rank"]];
    if(team[@"Wins"]) {
        self.recordLabel.text = [NSString stringWithFormat:@"(%@-%@-%@)", team[@"Wins"], team[@"Losses"], team[@"Ties"]];
    } else {
        self.recordLabel.text = [NSString stringWithFormat:@"(%@)", team[@"Record (W-L-T)"]];
    }
    
    self.teamNameLabel.text = teamObj.nickname;
}

@end
