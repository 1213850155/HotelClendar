//
//  HmSearchCalendar.m
//  AiaiWang
//
//  Created by 赵海明 on 2018/1/24.
//  Copyright © 2018年 cnmobi. All rights reserved.
//

#import "HmSearchCalendar.h"
#import "UIView+Extension.h"
#import "HmSearchCalendarBodyCollectionCell.h"
#import "HmSearchCalendarHeaderCollectionCell.h"

/*** RGB颜色 */
#define HmColorRGB(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:1.0]
/* 主题颜色 */
#define HmThemeColor HmColorRGB(243, 9, 108)

@interface HmSearchCalendar ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionVHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@property (nonatomic, assign) int totalDayThisMonth;    // 本月总天数
@property (nonatomic, assign) int firstWeekDay;         // 本月第一天周几
@property (nonatomic, assign) int lastSum;      // = firstWeekDay  显示上个月格子数
@property (nonatomic, assign) int sumDays;      // = totalDayThisMonth + lastSum + nextSum  显示总格子数

@property (nonatomic, assign) int currentShowYear;  // 当前选择的年份
@property (nonatomic, assign) int currentShowMonth; // 当前选择的月份

@property (nonatomic, assign) int nowYears; // 今天所属年份
@property (nonatomic, assign) int nowMonth; // 今天所属月份
@property (nonatomic, assign) int nowDay;   // 今天

@property (nonatomic, assign) int selectCheckInYear;    // 选择入住年份
@property (nonatomic, assign) int selectCheckInMonth;   // 选择入住月份
@property (nonatomic, assign) int selectCheckInDay;     // 选择入住天    默认当天

@property (nonatomic, assign) int selectCheckOutYear;   // 选择退房年份
@property (nonatomic, assign) int selectCheckOutMonth;  // 选择退房月份
@property (nonatomic, assign) int selectCheckOutDay;    // 选择退房天    默认当天的下一天

@property (nonatomic, assign) int selectCheckInOrOut;   // 选择入住或退房 0:选择结束(再点击选择为入住)  1:入住选择结束(再点击选择为退房)   默认0

@property (nonatomic, strong) NSDateComponents *comps;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, strong) HmSearchCalendarHeaderCollectionCell *cellHeader;
@property (nonatomic, strong) HmSearchCalendarBodyCollectionCell *cellBody;

@end

@implementation HmSearchCalendar
static int collectionViewCellHeight = 54;   // 日期的高度

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSLog(@"awakeFromNib");
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
    
    [self setupView];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"initwithCoder");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedHeightAction:) name:@"calendarHeightChanged" object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarHeightChanged" object:nil userInfo:@{@"new" : [NSNumber numberWithDouble:_collectionVHeight.constant + 53]}];
    NSLog(@"layoutSubviews");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"calendarHeightChanged" object:nil];
}

#pragma mark -- init
- (void)setupView {
    self.calendar = [NSCalendar currentCalendar];
    [self.calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    self.formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"yyyy-MM-dd";
    _formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
//    NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区
//    NSTimeInterval time = [zone secondsFromGMTForDate:[NSDate date]];// 以秒为单位返回当前时间与系统格林尼治时间的差
//    NSDate *dateNow = [[NSDate date] dateByAddingTimeInterval:time];// 然后把差的时间加上,就是当前系统准确的时间
    NSDate *dateNow = [_formatter dateFromString:[_formatter stringFromDate:[NSDate date]]];

    
    self.comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:dateNow];
    NSInteger thisMonth = [self.comps month];
    NSInteger thisYear = [self.comps year];
    NSInteger thisDay = [self.comps day];
    
    // 初始化赋值
    _currentShowYear = (int)thisYear;
    _currentShowMonth = (int)thisMonth;
    
    _nowYears = (int)thisYear;
    _nowMonth = (int)thisMonth;
    _nowDay = (int)thisDay;
    
    _selectCheckInYear = (int)thisYear;
    _selectCheckInMonth = (int)thisMonth;
    _selectCheckInDay = (int)thisDay;
    
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:0];
    [adcomps setDay:1];     // 默认 1
    NSArray *dateArr = [[_formatter stringFromDate:[self.calendar dateByAddingComponents:adcomps toDate:dateNow options:0]] componentsSeparatedByString:@"-"];
    _selectCheckOutYear = [[NSString stringWithFormat:@"%@", dateArr.firstObject] intValue];
    _selectCheckOutMonth = [[NSString stringWithFormat:@"%@", dateArr[1]] intValue];
    _selectCheckOutDay = [[NSString stringWithFormat:@"%@", dateArr.lastObject] intValue];
    
    _selectCheckInOrOut = 0;
    
    [self setDateWithYear:_currentShowYear month:_currentShowMonth animation:(UIViewAnimationOptionTransitionNone)];
    
    self.lblTime.text = [NSString stringWithFormat:@"%d年%d月", _currentShowYear, _currentShowMonth];
}

#pragma mark -- UICollectionView Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else {
        return _sumDays;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        _cellHeader = [HmSearchCalendarHeaderCollectionCell searchCalendarHeaderCollectionCell:collectionView indexPath:indexPath];
        return _cellHeader;
    }else {
        _cellBody = [HmSearchCalendarBodyCollectionCell searchCalendarBodyCollectionCell:collectionView indexPath:indexPath];
        _cellBody.leftV.hidden = YES;
        _cellBody.rightV.hidden = YES;
        _cellBody.lblDate.backgroundColor = [UIColor clearColor];
        if (indexPath.row < _lastSum) {
            _cellBody.lblDate.text = @"";
            _cellBody.lblSatus.text = @"";
        }else {
            if (_currentShowYear == _nowYears && _currentShowMonth == _nowMonth && _nowDay == indexPath.row - _lastSum + 1) {
                _cellBody.lblDate.text = @"今";
                _cellBody.lblSatus.text = @"";
            }else {
                _cellBody.lblDate.text = [NSString stringWithFormat:@"%d", (int)indexPath.row - _lastSum + 1];
                _cellBody.lblSatus.text = @"";
            }
            // 颜色设置
            if ([[self compareOneDay:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _currentShowYear, _currentShowMonth,(int)indexPath.row - _lastSum + 1]] withAnotherDay:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _nowYears, _nowMonth, _nowDay]]] isEqualToString:@"-1"]) {
                // 过去时间
                _cellBody.lblDate.textColor = HmColorRGB(202, 202, 202);
            }else {
                // 未来时间
                _cellBody.lblDate.textColor = HmColorRGB(102, 102, 102);
                NSString *cDate = [NSString stringWithFormat:@"%d/%d/%d", _currentShowYear, _currentShowMonth, (int)indexPath.row - _lastSum + 1];
                NSString *startD = [NSString stringWithFormat:@"%d/%d/%d", _selectCheckInYear, _selectCheckInMonth, _selectCheckInDay];
                if (_selectCheckInOrOut == 0) {
                    // 选择过了
                    NSString *endD = [NSString stringWithFormat:@"%d/%d/%d", _selectCheckOutYear, _selectCheckOutMonth, _selectCheckOutDay];
                    if ([self date:[_formatter dateFromString:cDate] isBetweenDate:[_formatter dateFromString:startD] endDate:[_formatter dateFromString:endD]]) {
                        // 区间内
                        // 选中
                        _cellBody.lblSatus.text = @"";
                        _cellBody.leftV.hidden = NO;
                        _cellBody.rightV.hidden = NO;
                    }else {
                        // 非区间内
                        if ([cDate isEqualToString:startD]) {
                            // 入住日
                            _cellBody.lblSatus.text = @"入住";
                            _cellBody.lblDate.backgroundColor = HmThemeColor;
                            _cellBody.lblDate.textColor = [UIColor whiteColor];
                            _cellBody.leftV.hidden = YES;
                            _cellBody.rightV.hidden = NO;
                        }else if ([cDate isEqualToString:endD]) {
                            // 退房日
                            _cellBody.lblSatus.text = @"退房";
                            _cellBody.lblDate.backgroundColor = HmThemeColor;
                            _cellBody.lblDate.textColor = [UIColor whiteColor];
                            _cellBody.leftV.hidden = NO;
                            _cellBody.rightV.hidden = YES;
                        }
                    }
                }else {
                    // 只选择了入住时间
                    if ([cDate isEqualToString:startD]) {
                        _cellBody.lblSatus.text = @"入住";
                        _cellBody.lblDate.textColor = [UIColor whiteColor];
                        _cellBody.lblDate.backgroundColor = HmThemeColor;
                    }
                }
            }
        }
        return _cellBody;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self compareOneDay:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _currentShowYear, _currentShowMonth, (int)indexPath.row - _lastSum + 1]] withAnotherDay:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _nowYears, _nowMonth, _nowDay]]]  isEqualToString:@"-1"]) {
        // 过去时间
    }else {
        // 未来时间
        if (_selectCheckInOrOut == 0) {
            // 第一次选择
            _selectCheckInYear = _currentShowYear;
            _selectCheckInMonth = _currentShowMonth;
            _selectCheckInDay = (int)indexPath.row - _lastSum + 1;
            _selectCheckInOrOut = 1;
        }else {
            // 第二次选择
            _selectCheckOutYear = _currentShowYear;
            _selectCheckOutMonth = _currentShowMonth;
            _selectCheckOutDay = (int)indexPath.row - _lastSum + 1;
            if ([[self compareOneDay:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _selectCheckInYear, _selectCheckInMonth, _selectCheckInDay]] withAnotherDay:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _selectCheckOutYear, _selectCheckOutMonth, _selectCheckOutDay]]] isEqualToString:@"-1"]) {
                // 退房日期 > 入住日期
                _selectCheckInOrOut = 0;
                if (self.selectDateSuccess) {
                    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay) fromDate:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _selectCheckInYear, _selectCheckInMonth, _selectCheckInDay]] toDate:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _selectCheckOutYear, _selectCheckOutMonth, _selectCheckOutDay]] options:0];
                    int count = (int)comp.day;
                    self.selectDateSuccess([NSString stringWithFormat:@"%d/%d/%d", _selectCheckInYear, _selectCheckInMonth, _selectCheckInDay], [NSString stringWithFormat:@"%d/%d/%d", _selectCheckOutYear, _selectCheckOutMonth, _selectCheckOutDay], count);
                }
            }else {
                // 退房日期 <= 入住日期 --> 重设将此次点击设为第一次点击
                _selectCheckInYear = _selectCheckOutYear;
                _selectCheckInMonth = _selectCheckOutMonth;
                _selectCheckInDay = _selectCheckOutDay;
                _selectCheckInOrOut = 1;
            }
        }
        [self.collectionV reloadData];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

// item大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(self.hm_width, collectionViewCellHeight - 20);
    }else {
        if (indexPath.row % 7 == 0) {
            return CGSizeMake(self.hm_width - (int)(self.hm_width / 7) * 6, collectionViewCellHeight);
        }else {
            return CGSizeMake((int)(self.hm_width / 7), collectionViewCellHeight);
        }
    }
}

#pragma mark -- Functions
/// 初始化设值
- (void)setDateWithYear:(int)year month:(int)month animation:(UIViewAnimationOptions)animation {
    // 当前月份总天数
    _totalDayThisMonth = [self getTotalDaysWithMonth:month year:year];
    // 当前月份第一天周几
    _firstWeekDay = [self getWeekdayWithYear:year month:month day:1];
    // 上个月在本月显示的天数
    _lastSum = _firstWeekDay % 7;
    _sumDays = _totalDayThisMonth + _lastSum;
    
    [UIView transitionWithView:_collectionV duration:0.5 options:animation animations:^{
        [_collectionV reloadData];
    } completion:^(BOOL finished) {
    }];
    
    // 设置collectionV高度
    int a = _sumDays;
    if (a % 7 == 0) {
        _collectionVHeight.constant = (a / 7 + 1) * collectionViewCellHeight - 20;
    }else {
        _collectionVHeight.constant = (a / 7 + 2) * collectionViewCellHeight - 20;
    }
    
    
    
}

/// 获取给定月份当中的天数
- (int)getTotalDaysWithMonth:(int)month year:(int)year {
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setMonth:month];
    [comp setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:comp];
    NSRange days = [gregorian rangeOfUnit:(NSCalendarUnitDay) inUnit:(NSCalendarUnitMonth) forDate:date];
    return (int)days.length;
}

/// 获取指定日期当月第一天周几   1:周一  7:周日
- (int)getWeekdayWithYear:(int)year month:(int)month day:(int)day {
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setYear:year];
    [comp setMonth:month];
    [comp setDay:day];
    
    NSDate *date = [self.calendar dateFromComponents:comp];
    NSDateComponents *weekdayComp = [self.calendar components:(NSCalendarUnitWeekday) fromDate:date];
    NSInteger weekDayNum = [weekdayComp weekday] - 1;
    if (weekDayNum == 0) {
        weekDayNum = 7;
    }
    return (int)weekDayNum;
}

/// 增加月份
- (void)addMonthAction {
    if (_currentShowMonth == 12) {
        _currentShowMonth = 1;
        _currentShowYear ++;
    }else {
        _currentShowMonth ++;
    }
    self.lblTime.text = [NSString stringWithFormat:@"%d年%d月", _currentShowYear, _currentShowMonth];
    [self setDateWithYear:_currentShowYear month:_currentShowMonth animation:(UIViewAnimationOptionCurveEaseInOut)];
}

/// 减少月份
- (void)reduceMonthAction {
    if (_currentShowMonth == 1) {
        _currentShowMonth = 12;
        _currentShowYear --;
    }else {
        _currentShowMonth --;
    }
    self.lblTime.text = [NSString stringWithFormat:@"%d年%d月", _currentShowYear, _currentShowMonth];
    [self setDateWithYear:_currentShowYear month:_currentShowMonth animation:(UIViewAnimationOptionCurveEaseInOut)];
}

/// 左翻
- (IBAction)leftFlipAction:(UIButton *)sender {
    [self reduceMonthAction];
}

/// 右翻
- (IBAction)rightFlipAction:(UIButton *)sender {
    [self addMonthAction];
}

- (void)changedHeightAction:(NSNotification *)no {
    NSLog(@"我是通知内部的,高度:%@", no.userInfo[@"new"]);
    if (self.collectionViewHeightChanged) {
        self.collectionViewHeightChanged([no.userInfo[@"new"] floatValue]);
        self.hm_height = [no.userInfo[@"new"] floatValue];
    }
    if (self.setNormalValue) {
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay) fromDate:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _selectCheckInYear, _selectCheckInMonth, _selectCheckInDay]] toDate:[_formatter dateFromString:[NSString stringWithFormat:@"%d/%d/%d", _selectCheckOutYear, _selectCheckOutMonth, _selectCheckOutDay]] options:0];
        int count = (int)comp.day;
        self.setNormalValue([NSString stringWithFormat:@"%d/%d/%d", _selectCheckInYear, _selectCheckInMonth, _selectCheckInDay], [NSString stringWithFormat:@"%d/%d/%d", _selectCheckOutYear, _selectCheckOutMonth, _selectCheckOutDay], count);
    }
}

/// 入住日期
- (void)setStartDate:(NSString *)startDate {
    _startDate = startDate;
    NSArray *startD = [startDate componentsSeparatedByString:@"/"];
    _selectCheckInYear = [startD[0] intValue];
    _selectCheckInMonth = [startD[1] intValue];
    _selectCheckInDay = [startD[2] intValue];
}

/// 退房日期
- (void)setEndDate:(NSString *)endDate {
    _endDate = endDate;
    NSArray *endD = [endDate componentsSeparatedByString:@"/"];
    _selectCheckOutYear = [endD[0] intValue];
    _selectCheckOutMonth = [endD[1] intValue];
    _selectCheckOutDay = [endD[2] intValue];
}

/// 背景颜色
- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    
    _collectionV.backgroundColor = backColor;
    self.backgroundColor = backColor;
}

#pragma mark -- private functions
- (NSString*)compareOneDay:(NSDate *)Date1 withAnotherDay:(NSDate *)Date2
{
    NSDateFormatter *dateFM = [[NSDateFormatter alloc] init];
    [dateFM setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date11 = [dateFM stringFromDate:Date1];//date   To  string
    NSString *date22 = [dateFM stringFromDate:Date2];
    
    NSDate *dateA = [dateFM dateFromString:date11];  //string To  date
    NSDate *dateB = [dateFM dateFromString:date22];
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedAscending){
        return @"-1";   //dateA 是过去的时间
    }
    else if (result == NSOrderedDescending) {
        return @"+1";   //dateA 是未来的时间
    }
    return @"0";        // 两者时间相同
}

- (BOOL)date:(NSDate *)date isBetweenDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    if ([date compare:startDate] == NSOrderedDescending && [date compare:endDate] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

@end
