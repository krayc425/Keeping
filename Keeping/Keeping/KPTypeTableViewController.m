//
//  KPTypeTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTypeTableViewController.h"
#import "Utilities.h"
#import "KPTypeColorTableViewCell.h"

@interface KPTypeTableViewController (){
    NSMutableArray *colorTextArr;
    NSMutableArray *colorArr;
}

@end

@implementation KPTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"类别颜色备注"];
    
    colorArr = [NSMutableArray arrayWithArray:[Utilities getTypeColorArr]];
    NSLog(@"%lu colors" , (unsigned long)colorArr.count);
    NSMutableArray *tmpColorTextArr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"typeTextArr"] mutableCopy];
    if(tmpColorTextArr == NULL || tmpColorTextArr.count == 0){
        colorTextArr = [NSMutableArray array];
        for (int i = 0; i < colorArr.count; i++) {
            [colorTextArr addObject:@""];
        }
    }else{
        colorTextArr = [NSMutableArray arrayWithArray:tmpColorTextArr];
    }
    
    //导航栏右上角
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_DONE"] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItems = @[okItem];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)doneAction:(id)sender{
    for(int i = 0; i < colorArr.count; i++){
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        KPTypeColorTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        colorTextArr[i] = cell.colorText.text;
    }
    [[NSUserDefaults standardUserDefaults] setObject:colorTextArr forKey:@"typeTextArr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [colorArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KPTypeColorTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPTypeColorTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPTypeColorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.imageView setTintColor:colorArr[indexPath.row]];
    UIImage *img = [UIImage imageNamed:@"round"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.imageView setImage:img];
    
    if(colorTextArr[indexPath.row] == NULL){
        [cell.colorText setText:@""];
    }else{
        [cell.colorText setText:colorTextArr[indexPath.row]];
    }
    
    return cell;
}

@end
