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
    self.timePicker = [[KPTimePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.timePicker.delegate = self;
    [self.view addSubview:self.timePicker];
}

#pragma mark - Date Delegate

- (void)timePicker:(KPTimePicker*)timePicker selectedDate:(NSDate *)date{
    [self.delegate passTime:date];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
