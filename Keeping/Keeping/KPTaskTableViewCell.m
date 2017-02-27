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
    
    //自定义"更多"view
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth,
                                                                  0,
                                                                  300,
                                                                  70)];
    
    deleteView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(0, 5, 90, 60)];
    cardView.cornerRadius = 10.0;
    [deleteView addSubview:cardView];
    
    deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(cardView.frame.size.width / 2 - 20,
                                                               cardView.frame.size.height / 2 - 25,
                                                               40,
                                                               50)];
    [deleteLabel setText:@"删除"];
    [deleteLabel setTextColor:[UIColor redColor]];
    [deleteLabel setNumberOfLines:2];
    [deleteLabel setTextAlignment:NSTextAlignmentCenter];
    [cardView addSubview:deleteLabel];
    
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
    NSNumber *fontSize = [Utilities getFontSizeArr][[[NSUserDefaults standardUserDefaults] integerForKey:@"fontSize"]];
    float f = [fontSize floatValue];
    
    [self.nameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
    [self.daysLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f / 1.2]];
    [deleteLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
    
    [self.progressView setFont];
    
    [self.weekdayView setFont];
    self.weekdayView.fontSize = 12.0;
}

@end
