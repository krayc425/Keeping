//
//  KPTypeColorTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/10.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTypeColorTableViewController.h"
#import "Utilities.h"

@interface KPTypeColorTableViewController ()

@end

@implementation KPTypeColorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"类别颜色"];
    self.selectedColorNum = -1;
    
    for (int i = 0; i < [[Utilities getTypeColorArr] count]; i++) {
        UIButton *btn = (UIButton *)self.colorStack.subviews[i];
        UIImage *img = [UIImage imageNamed:@"CIRCLE_FULL"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        [btn setTintColor:[Utilities getTypeColorArr][i]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
        [btn setTag:i];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)selectColorAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    if(self.selectedColorNum == (int)button.tag){
        self.selectedColorNum = -1;
    }else{
        self.selectedColorNum = (int)button.tag;
    }
    for(UIButton *btn in self.colorStack.subviews){
        if(btn.tag == self.selectedColorNum){
            [btn setTitle:@"●" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
