//
//  KPFontTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/23.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPFontTableViewController.h"
#import "Utilities.h"
#import "KPFontTableViewCell.h"
#import "KPNavigationViewController.h"
#import "KPTabBarViewController.h"

#define GROUP_ID @"group.com.krayc.keeping"

@interface KPFontTableViewController ()

@end

@implementation KPFontTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"字体"];
    
//    [self loadFontNames];
}

- (void)loadFontNames{
    NSArray *fontFamilies = [UIFont familyNames];
    for (int i = 0; i < [fontFamilies count]; i++){
        NSString *fontFamily = [fontFamilies objectAtIndex:i];
        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
        NSLog (@"%@: %@", fontFamily, fontNames);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Utilities getFontArr] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KPFontTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPFontTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPFontTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *fontDict = [Utilities getFontArr][indexPath.row];
    
    [cell.fontLabel setText:[fontDict allKeys][0]];
    [cell.fontLabel setFont:[UIFont fontWithName:[fontDict allValues][0] size:20.0f]];

    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"font"] isEqualToString:[fontDict allValues][0]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *fontDict = [Utilities getFontArr][indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setValue:[fontDict allValues][0] forKey:@"font"];
    
    NSUserDefaults *shared = [[NSUserDefaults alloc]initWithSuiteName:GROUP_ID];
    [shared setValue:[fontDict allValues][0] forKey:@"fontwidget"];
    [shared synchronize];
    
    KPNavigationViewController *nav = (KPNavigationViewController *)self.navigationController;
    [nav setFont];
    
    KPTabBarViewController *tab = (KPTabBarViewController *)nav.viewControllers[0];
    [tab setFont];
    
    [tableView reloadData];
}

@end
