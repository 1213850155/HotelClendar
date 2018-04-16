//
//  HmSearchCalendarBodyCollectionCell.m
//  AiaiWang
//
//  Created by 赵海明 on 2018/1/24.
//  Copyright © 2018年 cnmobi. All rights reserved.
//

#import "HmSearchCalendarBodyCollectionCell.h"

@implementation HmSearchCalendarBodyCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (HmSearchCalendarBodyCollectionCell *)searchCalendarBodyCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HmSearchCalendarBodyCollectionCellidentifier";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([HmSearchCalendarBodyCollectionCell class]) bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
        nibsRegistered = YES;
    }
    HmSearchCalendarBodyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

@end
