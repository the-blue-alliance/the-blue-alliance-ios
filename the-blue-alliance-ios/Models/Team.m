#import "Team.h"

@implementation Team


- (NSString *)groupingTextOfTeamNumber:(int)teamNumber
{
    if(teamNumber < 1000) {
        return @"1-990";
    } else {
        return [NSString stringWithFormat:@"%d's", teamNumber / 1000 * 1000];
    }
}

- (void)configureSelfForInfo:(NSDictionary *)info usingManagedObjectContext:(NSManagedObjectContext *)context {
    self.key = info[@"key"];
    self.name = info[@"name"];
    self.team_number = @([info[@"team_number"] intValue]);
    self.address = info[@"address"];
    self.nickname = info[@"nickname"];
    self.website = info[@"website"];
    self.location = info[@"location"];
    self.last_updated = @([[NSDate date] timeIntervalSince1970]);
    self.grouping_text = [self groupingTextOfTeamNumber:[info[@"team_number"] intValue]];
}

@end
