//
//  TeamInfoViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/20/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamInfoViewController.h"
#import "TBASocialButtonContainer.h"
#import "MediaCollectionViewCell.h"
#import <JTSImageViewController/JTSImageViewController.h>
#import "the_blue_alliance_ios-Swift.h"

@interface TeamInfoViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *infoObjects; // Array of `TBAInfoTableViewDataRow`s

@property (nonatomic, strong) NSArray *sortedTeamMedia;
@property (nonatomic, strong) UICollectionView *mediaCollectionView;

@end


@implementation TeamInfoViewController

- (NSArray *)infoObjects
{
    if(!_infoObjects) {
        TBAInfoTableViewDataRow *nicknameInfo = [[TBAInfoTableViewDataRow alloc] init];
        nicknameInfo.text = self.team.nickname.length ? self.team.nickname : @"No nickname";
        nicknameInfo.icon = [UIImage imageNamed:@"teams_tab_icon"];
        
        TBAInfoTableViewDataRow *websiteInfo = [[TBAInfoTableViewDataRow alloc] init];
        websiteInfo.text = self.team.website.length ? self.team.website : @"No website";
        websiteInfo.icon = [UIImage imageNamed:@"website"];
        
        TBAInfoTableViewDataRow *rookieYearInfo = [[TBAInfoTableViewDataRow alloc] init];
        rookieYearInfo.text = [NSString stringWithFormat:@"Rookie year: %@", self.team.rookieYear];
        rookieYearInfo.icon = [UIImage imageNamed:@"calendar"];
        
        TBAInfoTableViewDataRow *locationInfo = [[TBAInfoTableViewDataRow alloc] init];
        locationInfo.text = self.team.location;
        locationInfo.icon = [UIImage imageNamed:@"location"];
        
        _infoObjects = @[nicknameInfo, websiteInfo, rookieYearInfo, locationInfo];
    }
    return _infoObjects;
}

#pragma mark - UI Actions
- (void)socialButtonTapped:(TBASocialButtonContainer *)socialContainer
{
    TBASocialButtonContainerButtonType type = socialContainer.selectedButtonType;
    
    if (type == TBASocialButtonContainerButtonTypeWebsite) {
        [self.team navigateToWebsite];
    } else if(type == TBASocialButtonContainerButtonTypeTwitter) {
        [self.team navigateToTwitter];
    } else if(type == TBASocialButtonContainerButtonTypeYoutube) {
        [self.team navigateToYoutube];
    } else if(type ==  TBASocialButtonContainerButtonTypeChiefDelphi) {
        [self.team navigateToChief];
    }
}

#pragma mark - Setup UI
- (void)setupUI
{
    // Create views
    UITableView *infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    infoTableView.translatesAutoresizingMaskIntoConstraints = NO;
    infoTableView.dataSource = self;
    infoTableView.delegate = self;
    infoTableView.scrollEnabled = NO;
    infoTableView.rowHeight = 44;
    [self.view addSubview:infoTableView];
    
    TBASocialButtonContainer *socialButtonContainer = [[TBASocialButtonContainer alloc] initForAutoLayout];
    [socialButtonContainer addTarget:self action:@selector(socialButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:socialButtonContainer];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *mediaCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    mediaCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [mediaCollectionView registerClass:[MediaCollectionViewCell class] forCellWithReuseIdentifier:@"Team Media Cell"];
    mediaCollectionView.dataSource = self;
    mediaCollectionView.delegate = self;
    [self.view addSubview:mediaCollectionView];
    mediaCollectionView.backgroundColor = [UIColor whiteColor];
    self.mediaCollectionView = mediaCollectionView;
    
    
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
    
    self.sortedTeamMedia = [self sortedTeamMediaForTeam:self.team];
    [self setupUI];
    
    [self.team addObserver:self forKeyPath:@"media" options:0 context:NULL];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    @try {
        [self.team removeObserver:self forKeyPath:@"media" context:NULL];
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark - Database Updates

- (NSArray *)sortedTeamMediaForTeam:(Team *)team
{
    NSArray *typeOrder = @[@"cdphotothread", @"youtube"];
    NSArray *medias = [[team.media allObjects] sortedArrayUsingComparator:^NSComparisonResult(Media *obj1, Media *obj2) {
        NSInteger index1 = [typeOrder indexOfObject:obj1.type];
        NSInteger index2 = [typeOrder indexOfObject:obj2.type];
        if(index1 == index2) {
            return NSOrderedSame;
        } else if(index1 == NSNotFound) {
            return NSOrderedDescending;
        } else if(index2 == NSNotFound) {
            return NSOrderedAscending;
        } else if(index1 < index2) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    
    return medias;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"media"] && object == self.team) {
        self.sortedTeamMedia = [self sortedTeamMediaForTeam:self.team];
        [self.mediaCollectionView reloadData];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.infoObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Team Info Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Team Info Cell"];
    }
    
    TBAInfoTableViewDataRow *info = self.infoObjects[indexPath.row];
    cell.textLabel.text = info.text;
    cell.imageView.image = info.icon;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sortedTeamMedia.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Team Media Cell" forIndexPath:indexPath];
    
    cell.media = self.sortedTeamMedia[indexPath.row];
    
    return cell;
}

#define MEDIA_CELL_WIDTH 200
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(MEDIA_CELL_WIDTH, collectionView.bounds.size.height - collectionViewLayout.sectionInset.top - collectionViewLayout.sectionInset.bottom);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCollectionViewCell *cell = (MediaCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = cell.imageView.image;
    imageInfo.referenceRect = cell.frame;
    imageInfo.referenceView = cell.superview;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                       mode:JTSImageViewControllerMode_Image
                                                                            backgroundStyle:JTSImageViewControllerBackgroundStyle_ScaledDimmedBlurred];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
}


@end
