//
//  YearSelectView.h
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

/** `YearSelectView`'s delegate methods—defined by the YearSelectDelegate protocol
 *  calls didSelectNewYear: when a different year is selected
 */
@protocol YearSelectDelegate

/** Called when a different year than the currently selected year is selected
 *
 * @param year An integer representing the selected year
 */
- (void)didSelectNewYear:(NSInteger)year;
@end

/** `YearSelectView` is table view of years. A user can select a year to change
 *  the data for a view
 */
@interface YearSelectView : UITableViewController <UITableViewDataSource, UITableViewDelegate>

/** The object that is notified when a new year is selected
 */
@property (nonatomic, strong) id delegate;

/** Initilizes a YearSelectView for a particular year
 *
 * @param delegate The object that is notified when a new year is selected
 * @param year The current year the view is displaying data for
 * @return An initilized YearSelectView
 */
- (id)initWithDelegate:(id)delegate currentYear:(NSInteger)year;
@end
