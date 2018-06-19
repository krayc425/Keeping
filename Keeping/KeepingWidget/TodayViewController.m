//
//  TodayViewController.m
//  KeepingWidget
//
//  Created by 宋 奎熹 on 2017/1/29.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "Task.h"
#import "DateUtil.h"
#import "KPWidgetTableViewCell.h"
#import "TaskManager.h"
#import "DateTools.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDB];
    
    self.taskTableView.delegate = self;
    self.taskTableView.dataSource = self;
    self.taskTableView.backgroundColor = [UIColor clearColor];
    
    UINib *nib = [UINib nibWithNibName:@"KPWidgetTableViewCell" bundle:nil];
    [self.taskTableView registerNib:nib forCellReuseIdentifier:@"KPWidgetTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    
    [self loadTasks];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 110);
    } else {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.taskArr.count * 55);
    }
}

- (void)loadDB{
    NSString *doc = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GROUP_ID] path];
    NSString *fileName = [doc stringByAppendingPathComponent:@"task.sqlite"];
    
    self.db = [FMDatabase databaseWithPath:fileName];
    
    if ([self.db open]){
        NSLog(@"db open");
    }else{
        NSLog(@"db close");
    }
}

- (void)loadTasks{
    self.taskArr = [[NSMutableArray alloc] init];
    FMResultSet *resultSet = [self.db executeQuery:@"select * from t_task;"];
    while ([resultSet next]){
        
        //TODO: TASK UPDATE HERE
        
        Task *t = [Task new];
        t.id = [resultSet intForColumn:@"id"];
        t.name = [resultSet stringForColumn:@"name"];
        
        NSString *schemeJsonStr = [resultSet stringForColumn:@"appScheme"];
        if(schemeJsonStr != NULL){
            NSData *schemeData = [schemeJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *schemeDict = [NSJSONSerialization JSONObjectWithData:schemeData
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:nil];
            t.appScheme = schemeDict;
        }
        
        NSString *daysJsonStr = [resultSet stringForColumn:@"reminderDays"];
        if(daysJsonStr != NULL){
            NSData *daysData = [daysJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *daysArr = [NSJSONSerialization JSONObjectWithData:daysData
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
            t.reminderDays = daysArr;
        }
        
        NSString *punchJsonStr = [resultSet stringForColumn:@"punchDateArr"];
        if(punchJsonStr != NULL){
            NSData *punchData = [punchJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *punchArr = [NSJSONSerialization JSONObjectWithData:punchData
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
            t.punchDateArr = punchArr;
        }
        
        t.addDate = [resultSet dateForColumn:@"addDate"];
        t.reminderTime = [resultSet dateForColumn:@"reminderTime"];
        t.image = [resultSet dataForColumn:@"image"];
        t.link = [resultSet stringForColumn:@"link"];
        t.endDate = [resultSet dateForColumn:@"endDate"];
        
        if([t.reminderDays containsObject:[NSNumber numberWithInteger:[[NSDate date] weekday]]]){
            if([[NSDate date] isLaterThanOrEqualTo:t.addDate] && (t.endDate == NULL || [t.endDate isLaterThanOrEqualTo:[NSDate date]])){
                [self.taskArr addObject:t];
            }
        }
        
    }
    
    [self.taskTableView reloadData];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}

#pragma mark - Check Delegate

- (void)checkTask:(UITableViewCell *)cell{
    NSIndexPath *path = [self.taskTableView indexPathForCell:cell];
    
    Task *task = self.taskArr[path.row];
    if ([task.punchDateArr containsObject:[DateUtil transformDate:[NSDate date]]]) {
        [[TaskManager shareInstance] unpunchForTaskWithID:@(task.id) onDate:[NSDate date]];
    } else {
        [[TaskManager shareInstance] punchForTaskWithID:@(task.id) onDate:[NSDate date]];
    }

    [self loadTasks];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KPWidgetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KPWidgetTableViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    Task *t = self.taskArr[indexPath.row];
    
    [cell.nameLabel setText:t.name];
    
    NSString *reminderTimeStr = @"";
    if(t.reminderTime != NULL){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        reminderTimeStr = [dateFormatter stringFromDate:t.reminderTime];
        [cell.timeLabel setText:reminderTimeStr];
        [cell.timeLabel setHidden:NO];
    }else{
        [cell.timeLabel setText:@""];
        [cell.timeLabel setHidden:YES];
    }
    
    [cell.checkBox setOn:[t.punchDateArr containsObject:[DateUtil transformDate:[NSDate date]]]];
    
    return cell;
}

@end
