//
//  KPAboutTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPAboutTableViewController.h"
#import "Utilities.h"

@interface KPAboutTableViewController ()

@end

@implementation KPAboutTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"关于"];
    [self.nameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:30.0f]];
    
    //设置版本号
    self.versionLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setFont];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setFont{
    for(UILabel *lbl in self.labels) {
        [lbl setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    }
}

- (void)donate{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"alipayqr://platformapi/startapp?saId=10000007&qrcode=https://qr.alipay.com/FKX01076CQTSWFALUMNQ70"]
                                       options:@{}
                             completionHandler:nil];
}

- (void)score{
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [Utilities getAPPID]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]
                                       options:@{}
                             completionHandler:nil];
}

- (void)qANDa{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://songkuixi.github.io/2017/03/02/Keeping-Q-A/"]
                                       options:@{}
                             completionHandler:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 4;
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                [self qANDa];
                break;
            case 1:
                [self score];
                break;
            case 2:
                [self donate];
                break;
            default:
                break;
        }
    }
}

@end
