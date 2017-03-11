//
//  XHYHorizontalScrollCell.m
//  CocoaPodsDemo
//
//  Created by  XHY on 2016/12/20.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYHorizontalScrollCell.h"
#import "Masonry.h"
#import "XHYCameraListCell.h"

 NSString *const XHYCameraCellIdentifier = @"XHYCameraListCell";

@implementation XHYHorizontalScrollCell

- (UICollectionView *)horizontalCollectionView{

    if (!_horizontalCollectionView){
        
        UICollectionViewFlowLayout *horizontalCellLayout = [[UICollectionViewFlowLayout alloc] init];
        horizontalCellLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _horizontalCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:horizontalCellLayout];
        //[_horizontalCollectionView registerClass:[XHYCameraListCell class] forCellWithReuseIdentifier:XHYCameraCellIdentifier];
        [_horizontalCollectionView registerClass:NSClassFromString(self.reuseIdentifier) forCellWithReuseIdentifier:self.reuseIdentifier];
        _horizontalCollectionView.backgroundColor = [UIColor clearColor];
        _horizontalCollectionView.showsHorizontalScrollIndicator = NO;
        _horizontalCollectionView.dataSource = self;
        _horizontalCollectionView.delegate = self;
    }
    
    return _horizontalCollectionView;
}

- (void)setupSubviews{

    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.horizontalCollectionView];
    @JZWeakObj(self);
    [self.horizontalCollectionView mas_makeConstraints:^(MASConstraintMaker *make){
        
        make.left.mas_equalTo(selfWeak.contentView.mas_left);
        make.right.mas_equalTo(selfWeak.contentView.mas_right);
        make.top.mas_equalTo(selfWeak.contentView.mas_top);
        make.bottom.mas_equalTo(selfWeak.contentView.mas_bottom);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setupSubviews];
        
    }
    return self;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self){
        
        [self setupSubviews];
    }
    
    return self;
}

- (void)awakeFromNib{
    
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)reloadData{

    [self.horizontalCollectionView reloadData];
}

#pragma mark -----
#pragma mark ----- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(ScreenWidth / 3, collectionView.frame.size.height - 10);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    return UIEdgeInsetsMake(0.0F, 0.0F, 0.0F, 0.0F);
}

/*
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{

    return CGFLOAT_MIN;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return CGFLOAT_MIN;
}
*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(10.0f, 10.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    return CGSizeMake(10.0f, 10.0f);
}


#pragma mark -----
#pragma mark ----- UICollectionViewDelegate

#pragma mark -----
#pragma mark ----- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if ([self.delegate respondsToSelector:@selector(horizontalCellContentsView:numberOfItemsInTableViewIndexPath:)]) {
        
        return [self.delegate horizontalCellContentsView:collectionView numberOfItemsInTableViewIndexPath:self.tableViewIndexPath];
    }
    
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    
    if ([self.delegate respondsToSelector:@selector(horizontalCellContentsView:cellForItemAtContentIndexPath:inTableViewIndexPath:)]) {
        
            return [self.delegate horizontalCellContentsView:collectionView cellForItemAtContentIndexPath:indexPath inTableViewIndexPath:self.tableViewIndexPath];
    }
    
    return nil;
    
    /*
    XHYCameraListCell *cameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:XHYCameraCellIdentifier forIndexPath:indexPath];
    
    return cameraCell;
    */
}
@end
