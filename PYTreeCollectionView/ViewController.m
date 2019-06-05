//
//  ViewController.m
//  PYTreeCollectionView
//
//  Created by PerhapYs on 2019/6/5.
//  Copyright © 2019 PerhapYs. All rights reserved.
//

#import "ViewController.h"
#import "PYTreeCollectionView/PYTreeCollectionView.h"
#import "treeCollectionViewCell.h"

@interface ViewController ()<PYTreeDelegate,PYTreeDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PYTreeCollectionView *collectionView = [[PYTreeCollectionView alloc] init];
    collectionView.treeDelegate = self;
    collectionView.treeDataSource = self;
    collectionView.frame = self.view.bounds;
    [self.view addSubview:collectionView];
}
-(NSInteger)PYTreeCollectionView:(PYTreeCollectionView *)collectionView numberOfItemsAtIndexPath:(PYTreeIndexPath *)indexPath{
    return 8;
}

-(Class)registerCellForPYTreeCollectionView:(PYTreeCollectionView *)collectionView atIndexPath:(PYTreeIndexPath *)indexPath{
    return [treeCollectionViewCell class];
}

-(NSInteger)numberOfSectionsInPYTreeCollectionView:(PYTreeCollectionView *)collectionView{
    return 20;
}
-(void)PYTreeCollectionView:(PYTreeCollectionView *)collectionView customCell:(UICollectionViewCell *)cell AtIndexPathIndexPath:(PYTreeIndexPath *)indexPath{
    treeCollectionViewCell *newCell = (treeCollectionViewCell *)cell;
    
    newCell.textLabel.text = [NSString stringWithFormat:@"%ld - %ld",indexPath.originalIndexPath.section,indexPath.originalIndexPath.row];
}
-(CGSize)PYTreeCollectionView:(PYTreeCollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(70, 30);
}
-(void)PYTreeCollectionView:(PYTreeCollectionView *)collectionView didSelectItemAtIndexPath:(PYTreeIndexPath *)indexPath{
    NSLog(@"%ld",[indexPath selectedRowAtSection:indexPath.originalIndexPath.section]);
}
@end
