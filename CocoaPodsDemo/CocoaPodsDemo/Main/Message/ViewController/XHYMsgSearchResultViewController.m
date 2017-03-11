//
//  XHYMsgSearchResultViewController.m
//  CocoaPodsDemo
//
//  Created by  XHY on 16/8/24.
//  Copyright © 2016年  XHY. All rights reserved.
//

#import "XHYMsgSearchResultViewController.h"
#import "XHYMsg.h"

@interface XHYMsgSearchResultViewController ()

@end

@implementation XHYMsgSearchResultViewController

- (void)setSearchResults:(NSMutableArray *)searchResults{
    
    _searchResults = searchResults;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"ProductCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // 设置选中样式
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        
    }
    
    XHYMsg *product = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [product getMsgDisplayContent];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    TestDetailViewController *detail = [[TestDetailViewController alloc] init];
//    [self.presentingViewController.navigationController pushViewController:detail animated:YES];
}

@end
