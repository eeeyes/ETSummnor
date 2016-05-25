//
//  ETTestCollectionViewController.m
//  XIBConverter
//
//  Created by chaoran on 16/5/23.
//  Copyright © 2016年 chaoran. All rights reserved.
//

#import "ETTestCollectionViewController.h"

@interface ETTestChannelCell : UICollectionViewCell
@property (nonatomic,strong) UILabel* textView;
@property (nonatomic,strong) UIView* rightBorder;
@property (nonatomic,strong) UIView* bottomBorder;
@end

@implementation ETTestChannelCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        
        _textView = [[UILabel alloc]init];
        
        _textView.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_textView];
        
        _rightBorder = [[UIView alloc]init];
        
        _rightBorder.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.2];
        
        [self addSubview:_rightBorder];
        
        _bottomBorder = [[UIView alloc]init];
        
        _bottomBorder.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.2];
        
        [self addSubview:_bottomBorder];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _textView.frame = self.bounds;
    
    _rightBorder.frame = CGRectMake(self.bounds.size.width - 1.f, 0.f, 1.f, self.bounds.size.height);
    
    _bottomBorder.frame = CGRectMake(0, self.bounds.size.height - 1.f, self.bounds.size.width, 1.f);
    
}

@end

@interface ETTestCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

@implementation ETTestCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blueColor];
    
    self.navigationItem.title = @"频道";
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    
    UICollectionView* collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    
    collectionView.backgroundColor = [UIColor whiteColor];
    
    [collectionView registerClass:[ETTestChannelCell class] forCellWithReuseIdentifier:@"cell"];
    
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    
    collectionView.delegate = self;
    
    collectionView.dataSource = self;
    
    [self.view addSubview:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 27;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ETTestChannelCell *cell = (ETTestChannelCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    //cell.botlabel.text = [NSString stringWithFormat:@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row];
    cell.textView.text = @"JUST TEST";
    
    //cell.backgroundColor = [UIColor yellowColor];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
    headerView.backgroundColor =[UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.text = @"这是collectionView的头部";
    label.font = [UIFont systemFontOfSize:20];
    [headerView addSubview:label];
    return headerView;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.view.bounds.size.width, 80);
}
//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width / 3.0, 80);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
