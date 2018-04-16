//
//  HmSearchCalendarBodyCollectionCell.h
//  AiaiWang
//
//  Created by 赵海明 on 2018/1/24.
//  Copyright © 2018年 cnmobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HmSearchCalendarBodyCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSatus;
@property (weak, nonatomic) IBOutlet UIView *leftV;
@property (weak, nonatomic) IBOutlet UIView *rightV;

+ (HmSearchCalendarBodyCollectionCell *)searchCalendarBodyCollectionCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
