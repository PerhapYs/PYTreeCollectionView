//
//  testLayout.m
//  test
//
//  Created by PerhapYs on 2019/5/29.
//  Copyright © 2019 cosjiApp. All rights reserved.
//

#import "PYTreeLayout.h"

#define KEY_INDEXPATH_(x) [NSString stringWithFormat:@"indexPath=%@%@",@(x.section),@(x.row)]
@interface PYTreeLayout()

@property (nonatomic , strong) NSMutableDictionary *selectedIndexPathDataSource;

@property (nonatomic , strong) NSMutableDictionary *cellSizeDataSource;

@property (nonatomic , strong) NSMutableDictionary *changedSizeDataSource;

@end
@implementation PYTreeLayout
/*
// 获取item size
-(CGSize)itemSizeAtIndexPath:(NSIndexPath *)indexPath{
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = [self layoutDelegate];

    if (layoutDelegate && [layoutDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        CGSize size = [layoutDelegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        return size;
    }

    return self.itemSize;
}


// 获取item minimumLineSpacing
-(CGFloat)minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = [self layoutDelegate];
    if (layoutDelegate && [layoutDelegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        return [layoutDelegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return self.minimumLineSpacing;
}

// 获取item minimumInteritemSpacing

-(CGFloat)minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = [self layoutDelegate];
    if (layoutDelegate && [layoutDelegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        return [layoutDelegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return self.minimumInteritemSpacing;
}
*/
-(UIEdgeInsets)insetForSectionAtIndex:(NSInteger)section{
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = [self layoutDelegate];
    if (layoutDelegate && [layoutDelegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        return [layoutDelegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    return self.sectionInset;
}
// 计算contentSize
-(CGSize)collectionViewContentSize{
    NSInteger numberOfSection = [self.collectionView numberOfSections];
    if (numberOfSection > 0) { // 有一级以上

        CGRect theLastCellRect = CGRectZero;
        for (int i = 0; i < numberOfSection; i ++) {
            //         获取对应级的cell数量
            NSInteger numberOfItemInFirstSection = [self.collectionView numberOfItemsInSection:i];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForRow:numberOfItemInFirstSection - 1 inSection:i];
            // 获取当前级的最后一个cell
            CGRect lastCellRect = [self rectForChangedItemInIndexPath:lastCellIndexPath];
            if (theLastCellRect.origin.y < lastCellRect.origin.y) {
                theLastCellRect = lastCellRect;
            }
        }
        NSInteger totalHeight = theLastCellRect.origin.y + theLastCellRect.size.height + self.sectionInset.bottom;
        
        return CGSizeMake(self.collectionView.bounds.size.width,totalHeight);
    }

    return CGSizeMake(self.collectionView.bounds.size.width,0);
}
-(CGRect)rectForItemInIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *att = (UICollectionViewLayoutAttributes *)[self.cellSizeDataSource objectForKey:KEY_INDEXPATH_(indexPath)];
    
    return att.frame;
}
-(CGRect)rectForChangedItemInIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *att = (UICollectionViewLayoutAttributes *)[self.changedSizeDataSource objectForKey:KEY_INDEXPATH_(indexPath)];
    
    return att.frame;
}
-(CGFloat)heightForSection:(NSInteger)section{
    
    NSInteger numberOfRow = [self.collectionView numberOfItemsInSection:section];
    if (numberOfRow > 0) {  // 表示section中有数据
        NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForRow:numberOfRow-1 inSection:section];
        
        CGRect firstCellRect = [self rectForItemInIndexPath:firstCellIndexPath];
        CGRect lastCellRect = [self rectForItemInIndexPath:lastCellIndexPath];
        
        UIEdgeInsets sectionInset = [self insetForSectionAtIndex:section];
        NSInteger sectionHeight = lastCellRect.origin.y + lastCellRect.size.height - firstCellRect.origin.y + sectionInset.top + sectionInset.bottom;
        return sectionHeight;
    }
    return 0;
}
/**
 获取layout delegate

 @return 遵循协议<UICollectionViewDelegateFlowLayout>的delegate
 */
-(id<UICollectionViewDelegateFlowLayout>)layoutDelegate{
    if (self.collectionView.delegate && [self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
        if (self.collectionView.delegate) {
            id<UICollectionViewDelegateFlowLayout> layoutDeleagate = self.collectionView.delegate;
            return layoutDeleagate;
        }
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
    return YES;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    
    return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
}
-(CGFloat)addHeightAtSection:(NSInteger)section{
    BOOL nextShowStatus = [self.selectedIndexPathDataSource.allKeys containsObject:KEY_SECTION_(section)];
    if (nextShowStatus) {
        NSInteger nextSection = section + 1;
        NSInteger totalSection = self.collectionView.numberOfSections;
        if (nextSection < totalSection) {  // 防止为最后一级时，仍然查询下级的错误判断
            CGFloat sectionHeight = [self heightForSection:nextSection];
            
            CGFloat nextSectionHeight = [self addHeightAtSection:nextSection];
            return sectionHeight + nextSectionHeight;
        }
    }
    return 0;
}
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{

    NSMutableArray *attMarr = [[NSMutableArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];

    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    _changedSizeDataSource = nil;
    for (int i = 0 ; i < attMarr.count; i ++) {
        
        UICollectionViewLayoutAttributes *att = attMarr[i];
       
        [self.cellSizeDataSource setObject:[att copy] forKey:KEY_INDEXPATH_(att.indexPath)];
        
        if (att.representedElementKind == UICollectionElementCategoryCell) {  // cell

            NSIndexPath *currentIndexPath = att.indexPath;

            // 判断下级是否显示,如果是显示状态，改变本级的布局
            BOOL nextShowStatus = [self.selectedIndexPathDataSource.allKeys containsObject:KEY_SECTION_(currentIndexPath.section)];
            if (nextShowStatus) { // 如果下级显示的话，改变本级的布局
                // 本级的点击indexPath
                NSIndexPath *selectedIndexPath = self.selectedIndexPathDataSource[KEY_SECTION_(currentIndexPath.section)];

                NSInteger selected_Y = [self rectForItemInIndexPath:selectedIndexPath].origin.y;

                NSInteger layout_Y = att.frame.origin.y;
                if (layout_Y > selected_Y) {  // 如果不等于则，默认添加上一个下一级section的整体高度

                    NSInteger addHeight = [self addHeightAtSection:currentIndexPath.section];
                    att.frame = CGRectMake(att.frame.origin.x, att.frame.origin.y + addHeight, att.frame.size.width, att.frame.size.height);
                }
            }

            // 默认1级始终显示  // 判断是否显示其他级，以上一级是否被点击作为判断
            NSInteger lastSection = currentIndexPath.section - 1;
            BOOL firstClassShow = currentIndexPath.section == 0;
            BOOL showStatus = [self.selectedIndexPathDataSource.allKeys containsObject:KEY_SECTION_(lastSection)];
            if (firstClassShow || showStatus) {
                if (showStatus) {  // 二级以上显示时。改变本级的位置为上一级点击位置下方
                    if (lastSection == 0) {

                        NSIndexPath *lastSelectedIndexPath = self.selectedIndexPathDataSource[KEY_SECTION_(lastSection)];
                        CGRect lastSelectedRect = [self rectForItemInIndexPath:lastSelectedIndexPath];
                        UIEdgeInsets currentInsets = [self insetForSectionAtIndex:currentIndexPath.section];
                        NSInteger lastSelected_Bottom = lastSelectedRect.origin.y + lastSelectedRect.size.height + currentInsets.top;

                        NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndexPath.section];
                        NSInteger firstCell_Y = [self rectForItemInIndexPath:firstCellIndexPath].origin.y;

                        NSInteger change_Y = firstCell_Y - lastSelected_Bottom;

                        att.frame = CGRectMake(att.frame.origin.x, att.frame.origin.y - change_Y, att.frame.size.width, att.frame.size.height);
                    }
                    else{
                        NSIndexPath *lastSelectedIndexPath = self.selectedIndexPathDataSource[KEY_SECTION_(lastSection)];
                        CGRect lastSelectedRect = [self rectForChangedItemInIndexPath:lastSelectedIndexPath];
                        UIEdgeInsets currentInsets = [self insetForSectionAtIndex:currentIndexPath.section];

                        NSInteger lastSelected_Bottom = lastSelectedRect.origin.y + lastSelectedRect.size.height + currentInsets.top;

                        NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:currentIndexPath.section];
                        NSInteger firstCell_Y = [self rectForItemInIndexPath:firstCellIndexPath].origin.y;

                        NSInteger change_Y = firstCell_Y - lastSelected_Bottom;
                        att.frame = CGRectMake(att.frame.origin.x, att.frame.origin.y - change_Y, att.frame.size.width, att.frame.size.height);
                    }
                }

                [mArr addObject:att];
                [self.changedSizeDataSource setObject:att forKey:KEY_INDEXPATH_(att.indexPath)];
            }
        }
    }
    return mArr;
}
- (NSDictionary *)clickCellAtiIndexPath:(NSIndexPath *)indexPath{
    
    // 如果已经包含，表示本级已经被点击过.
    if ([self.selectedIndexPathDataSource.allKeys containsObject:KEY_SECTION_(indexPath.section)]) {
        
        NSIndexPath *saveIndexPath = self.selectedIndexPathDataSource[KEY_SECTION_(indexPath.section)];
        
        // 删除本级及所有下级.
        NSInteger selectedSection = indexPath.section;
        NSArray *enumArr = [self.selectedIndexPathDataSource.allKeys copy];
        for (NSString *sectionStr in enumArr) {
            NSIndexPath *indexPath = self.selectedIndexPathDataSource[sectionStr];
            if (indexPath.section >= selectedSection) {
                [self.selectedIndexPathDataSource removeObjectForKey:sectionStr];
            }
        }
        // 判断是否是同一个cell的重复点击操作
        if (![saveIndexPath isEqual:indexPath]) { //不是同级，清空所有下级,添加新的本级
            [self.selectedIndexPathDataSource setObject:indexPath forKey:KEY_SECTION_(indexPath.section)];
        }
    }
    else{
        // 保存点击的cell.indexPath
        [self.selectedIndexPathDataSource setObject:indexPath forKey:KEY_SECTION_(indexPath.section)];
    }
    
    [self.collectionView reloadData];
    
    return self.selectedIndexPathDataSource;
}
-(NSMutableDictionary *)selectedIndexPathDataSource{
    if (!_selectedIndexPathDataSource) {
        _selectedIndexPathDataSource = ({
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            
            dic;
        });
    }
    return _selectedIndexPathDataSource;
}

-(NSMutableDictionary *)changedSizeDataSource{
    if (!_changedSizeDataSource) {
        _changedSizeDataSource = ({
            NSMutableDictionary *arr = [[NSMutableDictionary alloc] init];
            arr;
        });
    }
    return _changedSizeDataSource;
}
-(NSMutableDictionary *)cellSizeDataSource{
    if (!_cellSizeDataSource) {
        _cellSizeDataSource = ({
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic;
        });
    }
    return _cellSizeDataSource;
}
@end
