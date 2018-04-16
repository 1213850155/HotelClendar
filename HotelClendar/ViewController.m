//
//  ViewController.m
//  HotelClendar
//
//  Created by 赵海明 on 2018/4/16.
//  Copyright © 2018年 cnmobi. All rights reserved.
//

#import "ViewController.h"
#import "HmSearchCalendar.h"
#import "UIView+Extension.h"

// 屏幕的width
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕的height
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define Weak(name) __weak __typeof(name) w##name = name

@interface ViewController ()

@property (nonatomic, strong) HmSearchCalendar *calendarV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"日历";
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.calendarV = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HmSearchCalendar class]) owner:self options:nil].lastObject;
    _calendarV.frame = CGRectMake(20, 100, kScreenWidth - 40, 300);
    Weak(self);
    _calendarV.setNormalValue = ^(NSString *startDate, NSString *endDate, int nightCount) {
//        wself.startDate = startDate;
//        wself.endDate = endDate;
//        wself.nightCount = nightCount;
//        wself.lblTitle.text = [NSString stringWithFormat:@"共%d晚", nightCount];
        NSLog(@"默认的入住日期是：%@，退房日期是：%@，共%d晚", startDate, endDate, nightCount);
    };
    _calendarV.selectDateSuccess = ^(NSString *startDate, NSString *endDate, int nightCount) {
//        wself.startDate = startDate;
//        wself.endDate = endDate;
//        wself.nightCount = nightCount;
//        wself.lblTitle.text = [NSString stringWithFormat:@"共%d晚", nightCount];
        NSLog(@"选中的入住日期是：%@，退房日期是：%@，共%d晚", startDate, endDate, nightCount);
    };
    _calendarV.collectionViewHeightChanged = ^(CGFloat height) {
        NSLog(@"我收到通知回调了，高度是:%f", height);
        wself.calendarV.hm_height = height;
    };
    [self.view addSubview:_calendarV];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
