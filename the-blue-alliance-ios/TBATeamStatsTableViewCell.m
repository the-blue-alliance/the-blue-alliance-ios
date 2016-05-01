//
//  TBATeamStatsTableViewCell.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/30/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATeamStatsTableViewCell.h"
#import "EventTeamStat.h"
#import "Team.h"

@interface TBATeamStatsTableViewCell ()

@property (nonatomic, strong) NSArray *stats;

@property (nonatomic, strong) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *statsLabel;

@end

@implementation TBATeamStatsTableViewCell

- (void)setTeamStats:(NSArray<EventTeamStat *> *)teamStats {
    _teamStats = teamStats;
    
    [self configureCell];
}

- (void)configureCell {
    Team *team = self.teamStats.firstObject.team;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%@", team.teamNumber];
    self.nameLabel.text = team.nickname;
    
    NSMutableArray<NSString *> *statsStringArray = [[NSMutableArray alloc] init];
    for (EventTeamStat *stat in self.teamStats) {
        [statsStringArray addObject:[NSString stringWithFormat:@"%@: %.2f", [stat statTypeString], stat.score.doubleValue]];
    }
    self.statsLabel.text = [statsStringArray componentsJoinedByString:@", "];
}

@end
