//
//  TBASummaryTableViewCell.h
//  the-blue-alliance
//
//  Created by Zach Orr on 4/25/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "TBATableViewCell.h"

static NSString *const SummaryCellReuseIdentifier = @"SummaryCell";

@interface TBASummaryTableViewCell : TBATableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;

@end
