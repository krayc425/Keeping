//
//  KPReminderViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPReminderViewController.h"
#import "KPTimePicker.h"
#import "DateTools.h"

@interface KPReminderViewController () <KPTimePickerDelegate>

@end

@implementation KPReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    KPTimePicker *timePicker = [[KPTimePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    timePicker.delegate = self;
    [self.view addSubview:timePicker];
}

#pragma mark - Date Delegate

- (void)timePicker:(KPTimePicker*)timePicker selectedDate:(NSDate *)date{
    NSInteger hour = date.hour;
    NSInteger minute = date.minute;
    NSLog(@"%@", [NSString stringWithFormat:@"%ld:%ld", (long)hour, (long)minute]);
//    [self.reminderLabel setText:[NSString stringWithFormat:@"%ld:%ld", (long)hour, (long)minute]];
    [self.delegate passTime:date];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

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
