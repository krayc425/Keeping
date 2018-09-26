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
    
    self.texts = [[NSMutableArray alloc] init];
    
    [self.navigationItem setTitle:NSLocalizedString(@"TypeMemo", nil)];
    
    colorArr = [NSMutableArray arrayWithArray:[Utilities getTypeColorArr]];
    NSMutableArray *tmpColorTextArr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"typeTextArr"] mutableCopy];

    if(tmpColorTextArr == NULL || tmpColorTextArr.count == 0){
        colorTextArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < colorArr.count; i++) {
            [colorTextArr addObject:@""];
        }
    }else{
        colorTextArr = [NSMutableArray arrayWithArray:tmpColorTextArr];
    }
    
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
    
    [cell.colorImg setTintColor:colorArr[indexPath.row]];
    UIImage *img = [UIImage imageNamed:@"CIRCLE_FULL"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.colorImg setImage:img];
    
    cell.colorText.tag = indexPath.row;
    cell.colorText.delegate = self;
    [self.texts addObject:cell.colorText];
    
    if(colorTextArr[indexPath.row] == NULL){
        [cell.colorText setText:@""];
    }else{
        [cell.colorText setText:colorTextArr[indexPath.row]];
    }
    
    return cell;
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag < colorArr.count - 1){
        [self.texts[textField.tag+1] becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

@end
