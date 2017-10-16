//
//  KPTaskTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTaskTableViewCell.h"
#import "Utilities.h"
#import "CardsView.h"
#import "Task.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation KPTaskTableViewCell{
    UILabel *deleteLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self setFont];
    
    [self.progressView setBackgroundStrokeColor:[UIColor groupTableViewBackgroundColor]];
    [self.progressView setProgressStrokeColor:[Utilities getColor]];
    
    self.weekdayView.isAllButtonHidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureWithTask:(Task *)t {
    [self.nameLabel setText:t.name];
    
    if(t.type > 0){
        UIImage *img = [UIImage imageNamed:@"Round_S"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.typeImg.tintColor = [Utilities getTypeColorArr][t.type - 1];
        [self.typeImg setImage:img];
    }else{
        [self.typeImg setImage:[UIImage new]];
    }
    
    NSString *reminderTimeStr = @"";
    if(t.reminderTime != NULL){
        [self.daysLabel setHidden:NO];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        reminderTimeStr = [dateFormatter stringFromDate:t.reminderTime];
    }else{
        [self.daysLabel setHidden:YES];
    }
    [self.daysLabel setText:reminderTimeStr];
    
    if(t.image != NULL){
        [self.taskImgViewBtn setUserInteractionEnabled:YES];
        [self.taskImgViewBtn setBackgroundImage:[UIImage imageWithData:t.image] forState:UIControlStateNormal];
    }else{
        [self.taskImgViewBtn setUserInteractionEnabled:NO];
        [self.taskImgViewBtn setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    }
    
    //暂时 NO
    [self.progressView setProgress:t.progress animated:NO];
    
    [self.weekdayView selectWeekdaysInArray:[NSMutableArray arrayWithArray:t.reminderDays]];
    [self.weekdayView setIsAllSelected:NO];
    [self.weekdayView setUserInteractionEnabled:NO];
}

- (IBAction)imgAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [self.delegate passImg:btn.currentBackgroundImage];
}

- (void)setFont{
    NSNumber *fontSize = [Utilities getFontSizeArr][[[NSUserDefaults standardUserDefaults] integerForKey:@"fontSize"]];
    float f = [fontSize floatValue];
    
    [self.nameLabel setFont:[UIFont systemFontOfSize:f]];
    [self.daysLabel setFont:[UIFont systemFontOfSize:f / 1.2]];
    [deleteLabel setFont:[UIFont systemFontOfSize:f]];
    
    [self.progressView setFontWithSize:f / 1.2];
    
    [self.weekdayView setFont];
    self.weekdayView.fontSize = 10.0;
}

@end
