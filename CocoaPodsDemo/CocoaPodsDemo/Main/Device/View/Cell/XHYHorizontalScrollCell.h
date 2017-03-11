//
//  XHYHorizontalScrollCell.h
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HorizontalScrollCellDeleagte <NSObject>

@optional

/**
 Set the number of items in each horizontally scrolled row.
 
 @param horizontalCellContentsView The Collection View of all Content Cells in each horizontally scrolled row.
 @param tableViewIndexPath The index path of HorizontalCell object related to its position in the tableView.
 
 @return Returns the number of item in the specified tableViewIndexPath.
 
 */
- (NSInteger)horizontalCellContentsView:(UICollectionView *)horizontalCellContentsView numberOfItemsInTableViewIndexPath:(NSIndexPath *)tableViewIndexPath;

/**
 Configure each item in the content-cell.
 
 @param horizontalCellContentsView The Collection View of all Content Cells in each horizontally scrolled row.
 @param contentIndexPath The index path of content-cell object related to its position in the horizontalCellContentsView.
 @param tableViewIndexPath The index path of HorizontalCell object related to its position in the tableView.
 
 @return Content-cell object
 */

- (UICollectionViewCell *)horizontalCellContentsView:(UICollectionView *)horizontalCellContentsView cellForItemAtContentIndexPath:(NSIndexPath *)contentIndexPath inTableViewIndexPath:(NSIndexPath *)tableViewIndexPath;


- (CGSize)horizontalCellContentsView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Manage the item selection.
 
 @param horizontalCellContentsView The Collection View of all Content Cells in each horizontally scrolled row.
 @param contentIndexPath The index path of content-cell object related to its position in the horizontalCellContentsView.
 @param tableViewIndexPath The index path of HorizontalCell object related to its position in the tableView.
 */

- (void)horizontalCellContentsView:(UICollectionView *)horizontalCellContentsView didSelectItemAtContentIndexPath:(NSIndexPath *)contentIndexPath inTableViewIndexPath:(NSIndexPath *)tableViewIndexPath;


- (CGFloat)tableViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface XHYHorizontalScrollCell : UITableViewCell<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) UICollectionView *horizontalCollectionView;
@property(nonatomic,weak) id <HorizontalScrollCellDeleagte> delegate;
@property (strong, nonatomic) NSIndexPath *tableViewIndexPath;

- (void)reloadData;

@end
