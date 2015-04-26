#import "Team.h"

@implementation Team
@synthesize nickname = _nickname;

- (NSString *)nickname {
    NSString *nickname = _nickname;
    NSString *trimmedNickname = [nickname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([trimmedNickname isEqualToString:@""]) {
        nickname = [NSString stringWithFormat:@"Team %@", [self.team_number stringValue]];
    }
    return nickname;
}

- (NSString *)groupingTextOfTeamNumber:(int)teamNumber {
    if (teamNumber < 1000) {
        return @"1-999";
    } else {
        int bottomNumber = teamNumber / 1000 * 1000;
        int topNumber = bottomNumber + 999;
        return [NSString stringWithFormat:@"%d-%d", bottomNumber, topNumber];
    }
}

- (void)configureSelfForInfo:(NSDictionary *)info
   usingManagedObjectContext:(NSManagedObjectContext *)context
                withUserInfo:(id)userInfo
{
    self.key = info[@"key"];
    self.name = info[@"name"];
    self.nickname = info[@"nickname"];
    self.team_number = @([info[@"team_number"] intValue]);
    self.location = info[@"location"];
    self.locality = info[@"locality"];
    self.region = info[@"region"];
    self.country = info[@"country"];
    self.website = info[@"website"];
    self.last_updated = @([[NSDate date] timeIntervalSince1970]);
    self.grouping_text = [self groupingTextOfTeamNumber:[info[@"team_number"] intValue]];
    self.rookie_year = info[@"rookie_year"];
}

@end
