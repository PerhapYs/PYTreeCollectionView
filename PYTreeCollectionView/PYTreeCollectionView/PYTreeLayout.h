//
//  testLayout.h
//  test
//
//  Created by PerhapYs on 2019/5/29.
//  Copyright © 2019 cosjiApp. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MAX_CONTENTSIZE_HEIGHT 10000000
NS_ASSUME_NONNULL_BEGIN
#define KEY_SECTION_(x) [NSString stringWithFormat:@"sectionOf%@",@(x)]

@protocol PYLayoutProtocol <NSObject>

-(NSDictionary *)clickCellAtiIndexPath:(NSIndexPath *)indexPath;

@end
@interface PYTreeLayout : UICollectionViewFlowLayout<PYLayoutProtocol>

@end

NS_ASSUME_NONNULL_END
