//
//  ETTestViewController.m
//  XIBConverter
//
//  Created by chaoran on 16/5/20.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "ETTestViewController.h"
@interface ETTestViewController()<UITableViewDataSource,UITableViewDelegate>
@end

@implementation ETTestViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    
   // self.navigationController.title = @"HAHA";
    
    self.navigationItem.title = @"normal";
    
    
    UITableView* tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    
    tableView.dataSource = self;
    
    tableView.delegate = self;
    
    tableView.backgroundColor =[UIColor redColor];
    
    [self.view addSubview:tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    ETTestViewController* newViewController = [[ETTestViewController alloc]init];
    
    [self.navigationController pushViewController:newViewController animated:YES];
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"test"];
    
    if(!cell){
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
        
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",row];
    
    return cell;
}
@end
