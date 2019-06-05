//
//  testView.m
//  test
//
//  Created by PerhapYs on 2019/5/30.
//  Copyright © 2019 cosjiApp. All rights reserved.
//

#import "PYTreeCollectionView.h"
#import "PYTreeLayout.h"
#define MAX_CONTENTSIZE_HEIGHT 10000000
static NSString *const PyCollectionDefaultIdentifier = @"identifierForDefaultCell";

@interface PYTreeCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSInteger _maxCollectionViewContentHeight;
}

@property (nonatomic , strong) UICollectionView *collectionView;

@property (nonatomic , strong) PYTreeIndexPath *selectedIndexPathDataSource;

@property (nonatomic , weak)id<PYLayoutProtocol> layoutDeleagate;
@end
@implementation PYTreeCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self placeSubView];
    }
    return self;
}
-(void)placeSubView{
    
    _maxCollectionViewContentHeight = MAX_CONTENTSIZE_HEIGHT;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    
    [self.collectionView addObserver:self
                          forKeyPath:@"contentSize"
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                             context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGSize oldSize = [change[@"old"] CGSizeValue];
        CGSize newSize = [change[@"new"] CGSizeValue];
        if (oldSize.height != newSize.height) {
            
            self.collectionView.frame = CGRectMake(0, 0, self.bounds.size.width, newSize.height);
            self.contentSize = newSize;
            
            if (self.treeDelegate && [self.treeDelegate respondsToSelector:@selector(PYTreeCollectionView:contentSize:)]) {
                [self.treeDelegate PYTreeCollectionView:self contentSize:newSize];
            }
        }
    }
}
-(void)dealloc{
    
    [self removeObserver:self forKeyPath:@"contentSize"];
}
-(void)didMoveToWindow{
    [super didMoveToWindow];
    
    [self reloadData];
}
-(void)reloadData{
    
    [self initializeSize];
    [self.collectionView reloadData];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.contentSize = CGSizeMake(self.bounds.size.width, self.contentSize.height);
    self.collectionView.frame = CGRectMake(0, 0, self.bounds.size.width,self.contentSize.height);
}
-(void)initializeSize{
    NSInteger width = self.bounds.size.width;
    if (width <= 0) {
        width = 100;
    }
    self.contentSize = CGSizeMake(width, _maxCollectionViewContentHeight);
    self.collectionView.frame = CGRectMake(0, 0, width,_maxCollectionViewContentHeight);
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.treeDataSource && [self.treeDataSource respondsToSelector:@selector(PYTreeCollectionView:numberOfItemsAtIndexPath:)]) {
        self.selectedIndexPathDataSource.originalIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        
        return [self.treeDataSource PYTreeCollectionView:self numberOfItemsAtIndexPath:self.selectedIndexPathDataSource];
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.treeDataSource && [self.treeDataSource respondsToSelector:@selector(registerCellForPYTreeCollectionView:atIndexPath:)]) {
        self.selectedIndexPathDataSource.originalIndexPath = indexPath;
        Class className = [self.treeDataSource registerCellForPYTreeCollectionView:self atIndexPath:self.selectedIndexPathDataSource];
        
        [collectionView registerClass:className forCellWithReuseIdentifier:PyCollectionDefaultIdentifier];
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PyCollectionDefaultIdentifier forIndexPath:indexPath];
        if ([self.treeDataSource respondsToSelector:@selector(PYTreeCollectionView:customCell:AtIndexPathIndexPath:)]) {
            
            [self.treeDataSource PYTreeCollectionView:self customCell:cell AtIndexPathIndexPath:self.selectedIndexPathDataSource];
        }
        return cell;
    }
    return nil;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.collectionView.numberOfSections > indexPath.section + 1) {
        self.contentSize = CGSizeMake(self.bounds.size.width, _maxCollectionViewContentHeight);
        self.collectionView.frame = CGRectMake(0, 0, self.bounds.size.width, _maxCollectionViewContentHeight);
    }
    
    NSDictionary *selectedDataSource = [self.layoutDeleagate clickCellAtiIndexPath:indexPath];
    self.selectedIndexPathDataSource = [self PYTreeIndexPathForDictionary:selectedDataSource];
    self.selectedIndexPathDataSource.originalIndexPath = indexPath;
    if (self.treeDelegate && [self.treeDelegate respondsToSelector:@selector(PYTreeCollectionView:didSelectItemAtIndexPath:)]) {
        
        [self.treeDelegate PYTreeCollectionView:self didSelectItemAtIndexPath:self.selectedIndexPathDataSource];
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.treeDataSource && [self.treeDataSource respondsToSelector:@selector(numberOfSectionsInPYTreeCollectionView:)]) {
        
        return [self.treeDataSource numberOfSectionsInPYTreeCollectionView:self];
    }
    return 0;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (self.treeDelegate && [self.treeDelegate respondsToSelector:@selector(PYTreeCollectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        return [self.treeDelegate PYTreeCollectionView:self layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
    }
    return self.minimumLineSpacing;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.treeDelegate && [self.treeDelegate respondsToSelector:@selector(PYTreeCollectionView:layout:sizeForItemAtIndexPath:)]) {
        return [self.treeDelegate PYTreeCollectionView:self layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    
    return self.itemSize;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (self.treeDelegate && [self.treeDelegate respondsToSelector:@selector(PYTreeCollectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        return [self.treeDelegate PYTreeCollectionView:self layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
    }
    return self.minimumInteritemSpacing;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (self.treeDelegate && [self.treeDelegate respondsToSelector:@selector(PYTreeCollectionView:layout:insetForSectionAtIndex:)]) {
        return [self.treeDelegate PYTreeCollectionView:self layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    return self.sectionInset;
}
#pragma mark  getter
-(PYTreeIndexPath *)PYTreeIndexPathForDictionary:(NSDictionary *)dic{
    
    if (dic.allKeys.count > 0) { // 表示有值
        
       NSArray *arr = [dic.allValues sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSIndexPath *indexPath1 = (NSIndexPath *)obj1;
            NSIndexPath *indexpath2 = (NSIndexPath *)obj2;
            return indexPath1.section > indexpath2.section;
        }];
        PYTreeIndexPath *returenIndexPath;
        for (NSIndexPath *indexPath in arr) {
            PYTreeIndexPath *treeIndexPath = [PYTreeIndexPath PYTreeIndexpathForIndexPath:indexPath];
            if (returenIndexPath) {
                treeIndexPath.last = returenIndexPath;
                returenIndexPath = treeIndexPath;
            }
            else{
                returenIndexPath = treeIndexPath;
            }
        }
        return returenIndexPath;
    }
    return nil;
}

-(PYTreeIndexPath *)selectedIndexPathDataSource{
    if (!_selectedIndexPathDataSource) {
        _selectedIndexPathDataSource = ({
            PYTreeIndexPath *indexPath = [[PYTreeIndexPath alloc] init];
            indexPath;
        });
    }
    return _selectedIndexPathDataSource;
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = ({
            PYTreeLayout *layout = [[PYTreeLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            self.layoutDeleagate = layout;
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
            collectionView.delegate = self;
            collectionView.backgroundColor = UIColor.clearColor;
            collectionView.dataSource = self;
            collectionView.scrollEnabled = NO;
            
            collectionView;
        });
    }
    return _collectionView;
}
-(void)setMaxContentHeight:(CGFloat)maxContentHeight{
    
    _maxCollectionViewContentHeight = maxContentHeight;
}
#pragma mark -------------------------------------------------------
@end

@interface PYTreeIndexPath ()

@property (nonatomic , strong) PYTreeIndexPath *first;

@end

@implementation PYTreeIndexPath

-(NSInteger)selectedRowAtSection:(NSInteger)section{
    
    if (self.selectedIndexPath.section == section) {  // 如果是相等表示，返回本身的row
        
        return self.selectedIndexPath.row;
    }
    if (section < 0) {  // 小于0，属于值错误，不存在低于0的section,返回0作为默认row
        
        return 0;
    }
    
    NSInteger lastSection = self.selectedIndexPath.section - 1;
    
    if (lastSection > section) {  // 如果上一级仍然大于需要的section,则进行递归 找寻上上级的row
        
        return [self.last selectedRowAtSection:section];
    }
    else{
        return self.last.selectedIndexPath.row;
    }
}

+(instancetype)PYTreeIndexpathForIndexPath:(NSIndexPath *)indexPath{
    PYTreeIndexPath *pyIndexPath = [[PYTreeIndexPath alloc] init];

    pyIndexPath.selectedIndexPath = indexPath;
    return pyIndexPath;
}
-(PYTreeIndexPath *)first{
    if (!_first) {
        _first = ({
            PYTreeIndexPath *indexPath = [self PYTreeIndexPathAtSection:0];
            indexPath.mainBranch = self;
            
            indexPath;
        });
    }
    return _first;
}
-(PYTreeIndexPath *)next{
    if (!_next) {
        _next = ({
            NSInteger nextSec = self.selectedIndexPath.section + 1;
            PYTreeIndexPath *indexPath = [self.mainBranch PYTreeIndexPathAtSection:nextSec];
            indexPath.mainBranch = self.mainBranch;
            
            indexPath;
        });
    }
    return _next;
}

// 返回某一个上级的PYTreeIndexPath
-(PYTreeIndexPath *)PYTreeIndexPathAtSection:(NSInteger)section{
    if (section < 0) {  // 传入section值异常，返回nil
        return nil;
    }

    if (section > self.selectedIndexPath.section) {  // 大于本级，返回nil
        return nil;
    }
    else if (self.selectedIndexPath.section == section) {  // 如果是相等表示，返回本级
        return self;
    }
    else{
        return [self.last PYTreeIndexPathAtSection:section];
    }
}
@end
