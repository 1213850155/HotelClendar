//
//  HmSearchCalendarHeaderCollectionCell.m
//  AiaiWang
//
//  Created by 赵海明 on 2018/1/24.
//  Copyright © 2018年 cnmobi. All rights reserved.
//

#import "HmSearchCalendarHeaderCollectionCell.h"

@implementation HmSearchCalendarHeaderCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (HmSearchCalendarHeaderCollectionCell *)searchCalendarHeaderCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HmSearchCalendarHeaderCollectionCellidentifier";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([HmSearchCalendarHeaderCollectionCell class]) bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
        nibsRegistered = YES;
    }
    HmSearchCalendarHeaderCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

@end
