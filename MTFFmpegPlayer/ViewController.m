//
//  ViewController.m
//  MTFFmpegPlayer
//
//  Created by Ternence on 2019/3/18.
//  Copyright © 2019 Ternence. All rights reserved.
//

#import "ViewController.h"
#import "MTViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mtTableView;

@property (nonatomic, strong) NSArray *sourceArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sourceArray = @[@"基于FFmpeg的视频播放器"];
    
    _mtTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
    _mtTableView.delegate = self;
    _mtTableView.dataSource = self;
    [self.view addSubview:_mtTableView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Cell"];
    }
    cell.detailTextLabel.text = _sourceArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        MTViewController *vc = [[MTViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
}


@end
