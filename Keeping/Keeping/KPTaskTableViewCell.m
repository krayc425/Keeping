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

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation KPTaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self setFont];
    
    [self.progressView setBackgroundStrokeColor:[UIColor groupTableViewBackgroundColor]];
    [self.progressView setProgressStrokeColor:[Utilities getColor]];
    
    self.weekdayView.isAllButtonHidden = YES;
    
    //自定义"更多"view
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth,
                                                                  0,
                                                                  300,
                                                                  70)];
    
    deleteView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(0, 5, 90, 60)];
    cardView.cornerRadius = 10.0;
    [deleteView addSubview:cardView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cardView.frame.size.width / 2 - 20,
                                                               cardView.frame.size.height / 2 - 25,
                                                               40,
                                                               50)];
    [label setText:@"删除"];
    [label setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [label setTextColor:[UIColor redColor]];
    [label setNumberOfLines:2];
    [label setTextAlignment:NSTextAlignmentCenter];
    [cardView addSubview:label];
    
    [self.contentView addSubview:deleteView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)imgAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [self.delegate passImg:btn.currentBackgroundImage];
}

- (void)setFont{
    [self.nameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.daysLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    
    [self.progressView setFont];
    
    [self.weekdayView setFont];
    self.weekdayView.fontSize = 12.0;
}

@end
