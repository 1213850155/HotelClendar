//
//  HmSearchCalendar.h
//  AiaiWang
//
//  Created by 赵海明 on 2018/1/24.
//  Copyright © 2018年 cnmobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HmSearchCalendar : UIView

@property (nonatomic, copy) void (^selectDateSuccess)(NSString *startDate, NSString *endDate, int nightCount);
@property (nonatomic, copy) void (^setNormalValue)(NSString *startDate, NSString *endDate, int nightCount);
@property (nonatomic, copy) void (^collectionViewHeightChanged)(CGFloat height);

@property (nonatomic, strong) NSString *startDate;  // 默认入住日期
@property (nonatomic, strong) NSString *endDate;    // 默认离店日期

/// 整体背景颜色(默认reb:240,240,240)
@property (nonatomic, strong) UIColor *backColor;

@end
