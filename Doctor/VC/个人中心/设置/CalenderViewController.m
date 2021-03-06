//
//  CalenderViewController.m
//  Doctor
//
//  Created by MrZhang on 15/7/3.
//  Copyright (c) 2015年 cuiw. All rights reserved.
//

#import "CalenderViewController.h"
#import "NSDate+Convenience.h"
#import "NSDateAdditions.h"
#import "WBCalendarView.h"
#import "NSDate+FSExtension.h"
@interface CalenderViewController ()<WBCalendarMonthViewDelegate>
{
   
}
@property (weak, nonatomic) IBOutlet WBCalendarView *calender;
@end

@implementation CalenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatNavgationBarWithTitle:self.titleString];
    [self addBackButt];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.calender.monthViewDelegate = self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.calender.selectedDate=[NSDate date];
}
- (void)calendarViewDidChangeToYear:(NSInteger)year month:(NSInteger)month{
    
}
-(void)calendarMonthView:(WBCalendarMonthView *)monthView didSelectedDate:(NSDate *)date
{
    NSString *today=[[NSDate date] fs_stringWithFormat:@"yyyy-MM-dd"];
    NSDate *todayDate=[NSDate fs_dateFromString:today format:@"yyyy-MM-dd"];
    if ([date compare:todayDate]==NSOrderedAscending) {
        [SVProgressHUD showErrorWithStatus:@"请选择不小于今天的时间"];
        return;
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(passRetureDate:)])
    {
        NSString *dateString=[date fs_stringWithFormat:@"yyyy-MM-dd"];
        NSLog(@"dateString==%@",dateString);
        [self.delegate passRetureDate:date];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (NSString *)calendarMonthView:(WBCalendarMonthView *)monthView titleForDate:(NSDate *)date{
    return nil;
}
- (void)selectedData:(NSDate *)date {
    
    
}
//- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
//  
//    [self selectedData:date];
//}
/*
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date{
    
    return @"";
}
- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
{
   
    return [UIImage imageNamed:@""];
}
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date{
   
    return YES;
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
