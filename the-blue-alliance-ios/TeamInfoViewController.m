//
//  TeamInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamInfoViewController.h"
#import "TBASocialButtonContainer.h"

@interface TeamInfoViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
//@property (nonatomic, strong) UITableView *infoTableView;
//@property (nonatomic, strong) UIView *socialButtonRow;

@property (nonatomic, strong) NSArray *infoObjects; // Array of `TBAInfoTableViewDataRow`s

@end


@implementation TeamInfoViewController

- (NSArray *)infoObjects
{
    if(!_infoObjects) {
        TBAInfoTableViewDataRow *websiteInfo = [[TBAInfoTableViewDataRow alloc] init];
        websiteInfo.text = self.team.website.length ? self.team.website : @"No website";
        websiteInfo.icon = [UIImage imageNamed:@"website"];
        
        TBAInfoTableViewDataRow *rookieYearInfo = [[TBAInfoTableViewDataRow alloc] init];
        rookieYearInfo.text = [NSString stringWithFormat:@"Rookie year: %@", self.team.rookieYear];
        rookieYearInfo.icon = [UIImage imageNamed:@"calendar"];
        
        TBAInfoTableViewDataRow *locationInfo = [[TBAInfoTableViewDataRow alloc] init];
        locationInfo.text = self.team.location;
        locationInfo.icon = [UIImage imageNamed:@"location"];
        
        _infoObjects = @[websiteInfo, rookieYearInfo, locationInfo];
    }
    return _infoObjects;
}



- (void)setupUI
{
    // Create views
    UITableView *infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    infoTableView.translatesAutoresizingMaskIntoConstraints = NO;
    infoTableView.dataSource = self;
    infoTableView.delegate = self;
    infoTableView.scrollEnabled = NO;
    [self.view addSubview:infoTableView];
    
    TBASocialButtonContainer *socialButtonContainer = [[TBASocialButtonContainer alloc] initForAutoLayout];
    [self.view addSubview:socialButtonContainer];
    socialButtonContainer.backgroundColor = [UIColor greenColor];
    
    UICollectionView *mediaCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    mediaCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    mediaCollectionView.dataSource = self;
    mediaCollectionView.delegate = self;
    [self.view addSubview:mediaCollectionView];
    mediaCollectionView.backgroundColor = [UIColor blueColor];
    
    
    // Setup constraints
    // Position table view near top
    CGFloat infoTableViewHeight = self.infoObjects.count * infoTableView.rowHeight;
    [infoTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [infoTableView autoSetDimension:ALDimensionHeight toSize:infoTableViewHeight];
    
    // Position social button container below table view
    [socialButtonContainer autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [socialButtonContainer autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    [socialButtonContainer autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:infoTableView];
    
    // Position media collection view to fill the remaining space
    [mediaCollectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [mediaCollectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:socialButtonContainer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.infoObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    return cell;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // TODO: Implement team media here
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    return cell;
}

@end
