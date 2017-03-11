//
//  XHYDeviceScrollView.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/9/6.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYDeviceScrollView.h"
#import "XHYSmartDeviceCell.h"
#import "MJRefresh.h"
#import "XHYFontTool.h"

@interface XHYDeviceScrollView()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{

    UIScrollView *_scrollView;
    NSInteger currentPage;
}

@end

static NSUInteger const TableViewCount = 3;

@implementation XHYDeviceScrollView

- (void)setRoomArray:(NSArray *)roomArray{

    _roomArray = roomArray;
    
    if ([_roomArray count]){
        
         [self updateContentAnimated:NO];
    }
}

- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super initWithCoder:aDecoder]) {
        
        [self setupSubViews];
    }
    
    return self;
}

- (void)setupSubViews{
    
    currentPage = 0;
    
    self.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    
    [self addSubview:scrollView];
    
    _scrollView = scrollView;
    
    for (int i = 0; i < TableViewCount; i++){
        
        UITableView *_deviceTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _deviceTableView.dataSource = self;
        _deviceTableView.delegate = self;
        _deviceTableView.backgroundColor = [UIColor clearColor];
        _deviceTableView.rowHeight = 82.0f;
        _deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _deviceTableView.tableFooterView = [[UIView alloc] init];
        /*
        if (i == 1){
            
            MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                
                [_deviceTableView reloadData];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [_deviceTableView.mj_header endRefreshing];
                });
            }];
            // 设置文字
            [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
            [header setTitle:@"释放以刷新" forState:MJRefreshStatePulling];
            [header setTitle:@"正在刷新 ..." forState:MJRefreshStateRefreshing];
            
            // 设置字体
            header.stateLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:15.0f];
            header.lastUpdatedTimeLabel.font = [XHYFontTool getDeaultFontBaseLanguageWithSize:14.0f];
            
            // 设置颜色
            header.stateLabel.textColor = [UIColor blackColor];
            header.lastUpdatedTimeLabel.textColor = [UIColor grayColor];
            
            // 马上进入刷新状态
            // [header beginRefreshing];
            
            // 设置刷新控件
            _deviceTableView.mj_header = header;

        }
        */
        [_scrollView addSubview:_deviceTableView];
    }
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    // 设置3个UITableView的frame
    CGFloat tableWidth = _scrollView.frame.size.width;
    CGFloat tableheight = _scrollView.frame.size.height;
    
    for (NSUInteger i = 0; i < TableViewCount; i++) {
        
        UITableView *tableView = _scrollView.subviews[i];
        CGFloat tableX = i * tableWidth;
        CGFloat tableY = 0;
        tableView.frame = CGRectMake(tableX, tableY, tableWidth, tableheight);
    }
    
    _scrollView.contentSize = CGSizeMake(TableViewCount * tableWidth, 0);
    
    [self updateContentAnimated:NO];
}

#pragma mark - 其他方法

- (void)updateContentAnimated:(BOOL)animated{
    
    // 1.从左到右重新设置每一个UIImageView的图片
    for (NSUInteger i = 0; i < TableViewCount; i++){
        
        UITableView *tableView = _scrollView.subviews[i];
        // 求出i位置imageView对应的图片索引
        NSInteger tableIndex = 0; // 这里的imageIndex不能用NSUInteger
        
        if (i == 0) {
            // 当前页码 - 1
            tableIndex = currentPage - 1;
            
        } else if (i == 2) { // 当前页码 + 1
            
            tableIndex = currentPage + 1;
            
        } else { // // 当前页码
            
            tableIndex = currentPage;
        }
        
        // 判断越界
        if (tableIndex == -1) {
            
            // 最后一张图片
            tableIndex = self.roomArray.count - 1;
            
        } else if (tableIndex == self.roomArray.count) {
            
            // 最前面那张
            tableIndex = 0;
        }
        
        // 绑定数据索引到UITableView的tag
        tableView.tag = tableIndex;
        
        [tableView reloadData];
    }
    
    // 2.重置UIScrollView的 contentOffset.width == 1倍宽度 永远显示中间一个tableview
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:animated];
}

- (void)setCurrentPage:(NSInteger)Page{

    if (currentPage == Page) {
        
        return;
    }
    
    if (currentPage < Page) {
        
        [_scrollView setContentOffset:CGPointMake(0, 0) ];
        
    }else if(currentPage > Page){
        
        [_scrollView setContentOffset:CGPointMake(2 * _scrollView.frame.size.width, 0)];
    }
    
    currentPage = Page;
    
    [self updateContentAnimated:YES];
}

#pragma mark ----- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (tableView.tag >= [self.roomArray count]){
        
        return 0;
    }
    
    NSDictionary *dic = [self.roomArray objectAtIndex:tableView.tag];
    NSArray *deviceArray = [[dic allValues] firstObject];
    return [deviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XHYSmartDeviceCell *cell = [XHYSmartDeviceCell dequeueSmartDeviceCellFromRootTableView:tableView];

    if (tableView.tag < [self.roomArray count]){
        
        NSDictionary *dic = [self.roomArray objectAtIndex:tableView.tag];
        if (dic){
            
            NSArray *deviceArray = [[dic allValues] firstObject];
            XHYSmartDevice *tempDevice = [deviceArray objectAtIndex:indexPath.row];
            [cell setDisplaySmartDevice:tempDevice];
        }
    }
    
    return cell;
}

#pragma mark ----- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [self.roomArray objectAtIndex:tableView.tag];
    NSArray *deviceArray = [[dic allValues] firstObject];
    
    XHYSmartDevice *tempDevice = [deviceArray objectAtIndex:indexPath.row];

    if (self.delegate && [self.delegate respondsToSelector:@selector(xhy_deviceScrollView:didSelectItem:)]){
        
        [self.delegate xhy_deviceScrollView:self didSelectItem:tempDevice];
    }
}

#pragma mark ----- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    // UITableView的 x 和 scrollView偏移量x 的最小差值
    CGFloat minDelta = MAXFLOAT;
    // 找出显示在最中间的图片索引
    NSInteger centerImageIndex = 0;
    
    for (NSUInteger i = 0; i < TableViewCount; i++) {
        
        UITableView *imageView = _scrollView.subviews[i];
        // ABS : 取得绝对值
        CGFloat delta = ABS(imageView.frame.origin.x - _scrollView.contentOffset.x);
        
        if (delta < minDelta) {
            
            minDelta = delta;
            centerImageIndex = imageView.tag;
        }
    }
    // 设置页码
    currentPage = centerImageIndex;
}

/**
 * 滚动完毕后调用（前提：手松开后继续滚动）
 */

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self updateContentAnimated:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(xhy_deviceScrollView:didScrollToItemAtIndex:)]){
        
        [self.delegate xhy_deviceScrollView:self didScrollToItemAtIndex:currentPage];
    }
}

#pragma mark ----- 刷新单元格中设备的信息

- (void)reloadDeviceDetailInfo:(XHYSmartDevice *)msgDevice needStick:(BOOL)stick{
    
    if (!msgDevice){
        return;
    }
    
    UITableView *currentTableView = _scrollView.subviews[1];
    NSMutableDictionary *dic = [self.roomArray objectAtIndex:currentTableView.tag];
    NSArray *deviceArray = [[dic allValues] firstObject];
    NSString *keyString = [[dic allKeys] firstObject];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:deviceArray];
    [deviceArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XHYSmartDevice *obj, NSUInteger idx, BOOL * _Nonnull stop){
        
        if([msgDevice isEqual:obj]){
            
            obj = msgDevice;
            if(stick){
                
                [tempArray exchangeObjectAtIndex:idx withObjectAtIndex:0];
            }
            /*
            [currentTableView beginUpdates];
            [currentTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [currentTableView endUpdates];
            */
            *stop = YES;
        }
    }];
    
    [dic setValue:tempArray forKey:keyString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [currentTableView reloadData];
        if (stick){
            
            [currentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    });
}

@end
