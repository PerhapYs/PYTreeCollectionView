//
//  treeCollectionViewCell.m
//  PYTreeCollectionView
//
//  Created by PerhapYs on 2019/6/5.
//  Copyright © 2019 PerhapYs. All rights reserved.
//

#import "treeCollectionViewCell.h"

@implementation treeCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [UILabel new];
        _textLabel.layer.cornerRadius = 4;
        _textLabel.layer.borderWidth = 1;
        _textLabel.layer.borderColor = UIColor.blueColor.CGColor;
        _textLabel.textColor = UIColor.blackColor;
        _textLabel.font = [UIFont systemFontOfSize:13];
        _textLabel.textAlignment = 1;
        _textLabel.frame = self.contentView.bounds;
        [self.contentView addSubview:_textLabel];
    }
    return self;
}
@end
