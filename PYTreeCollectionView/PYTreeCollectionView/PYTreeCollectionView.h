//
//  testView.h
//  test
//
//  Created by PerhapYs on 2019/5/30.
//  Copyright © 2019 cosjiApp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PYTreeCollectionView;
@class PYTreeIndexPath;
@protocol PYTreeDataSource <NSObject>

@required
-(NSInteger)PYTreeCollectionView:(PYTreeCollectionView *)collectionView numberOfItemsAtIndexPath:(PYTreeIndexPath *)indexPath;

-(Class)registerCellForPYTreeCollectionView:(PYTreeCollectionView *)collectionView atIndexPath:(PYTreeIndexPath *)indexPath;

-(NSInteger)numberOfSectionsInPYTreeCollectionView:(PYTreeCollectionView *)collectionView;

@optional

-(void)PYTreeCollectionView:(PYTreeCollectionView *)collectionView customCell:(UICollectionViewCell *)cell AtIndexPathIndexPath:(PYTreeIndexPath *)indexPath;

@end

@protocol PYTreeDelegate <NSObject>

@optional

-(NSInteger)PYTreeCollectionView:(PYTreeCollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;

-(CGSize)PYTreeCollectionView:(PYTreeCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

-(NSInteger)PYTreeCollectionView:(PYTreeCollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

-(UIEdgeInsets)PYTreeCollectionView:(PYTreeCollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

-(void)PYTreeCollectionView:(PYTreeCollectionView *)collectionView didSelectItemAtIndexPath:(PYTreeIndexPath *)indexPath;

-(void)PYTreeCollectionView:(PYTreeCollectionView *)collectionView contentSize:(CGSize)contentSize;

@end
@interface PYTreeCollectionView : UIScrollView

@property (nonatomic , weak) id<PYTreeDelegate> treeDelegate;

@property (nonatomic , weak) id<PYTreeDataSource> treeDataSource;

@property (nonatomic , assign) CGSize itemSize;

@property (nonatomic) CGFloat minimumLineSpacing;

@property (nonatomic) CGFloat minimumInteritemSpacing;

@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic) CGFloat maxContentHeight;  // 默认为10000000,如果可能展示的高度超过这个高度，可以重新设置为更高的高度。但是不可低于需要完全展示所有级的最高高度。

-(void)reloadData;  // 刷新方法

@end

@interface PYTreeIndexPath : NSObject

@property (nonatomic , strong) NSIndexPath *selectedIndexPath;

@property (nonatomic , strong) NSIndexPath *originalIndexPath;

@property (nonatomic , strong) PYTreeIndexPath *last;

@property (nonatomic , readonly ,strong) PYTreeIndexPath *next;

@property (nonatomic , readonly , strong) PYTreeIndexPath *first;

@property (nonatomic , strong) PYTreeIndexPath *mainBranch;

+(instancetype)PYTreeIndexpathForIndexPath:(NSIndexPath *)indexPath;

-(PYTreeIndexPath *)PYTreeIndexPathAtSection:(NSInteger)section;

-(NSInteger)selectedRowAtSection:(NSInteger)section;

@end
NS_ASSUME_NONNULL_END
