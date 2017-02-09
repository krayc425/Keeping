//
//  KPSchemeTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSchemeTableViewController.h"
#import "KPSchemeManager.h"
#import "KPSchemeTableViewCell.h"
#import "Utilities.h"
#import <AVOSCloud/AVOSCloud.h>
#import "MBProgressHUD.h"

@interface KPSchemeTableViewController ()

@end

@implementation KPSchemeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"选择 APP"];
    
    [self.noneLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0]];
    [self.insLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0]];
    
    //隐藏返回键
    [self.navigationItem setHidesBackButton:YES];
    //导航栏左上角
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_CANCEL"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItems = @[cancelItem];
    //导航栏右上角
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_DONE"] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItems = @[okItem];
    
    self.allNames = [[NSMutableArray alloc] init];
    self.allSchemes = [[NSMutableArray alloc] init];
    self.searchResults = [[NSMutableArray alloc] init];
    self.appDictionaryArr = [[NSMutableArray alloc] init];
    
    [self loadApps];
    //搜索框
//    [self setSearchControllerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadApps{
    for(NSDictionary *dict in [[KPSchemeManager shareInstance] getSchemeArr]){
        [self.allNames addObject:dict.allKeys[0]];
        [self.allSchemes addObject:dict.allValues[0]];
        [self.appDictionaryArr addObject:dict];
    }
    NSLog(@"%lu nums", (unsigned long)[self.appDictionaryArr count]);
    NSLog(@"%lu nums", (unsigned long)[[[KPSchemeManager shareInstance] getSchemeArr] count]);
    [self.tableView reloadData];
}

- (void)setSearchControllerView{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.frame = CGRectMake(0, 0, 0, 44);
    self.searchController.searchBar.placeholder = @"APP 名称";
    self.searchController.dimsBackgroundDuringPresentation = false;
    //搜索栏表头视图
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    //背景颜色
    self.searchController.searchBar.backgroundColor = [Utilities getColor];
    self.searchController.searchResultsUpdater = self;
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction:(id)sender{
    if(self.selectedPath != NULL && self.selectedPath.section == 1){
        [self.delegate passScheme:self.appDictionaryArr[self.selectedPath.row]];
    }else{
        [self.delegate passScheme:@{@"":@""}];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSubmitAlert{
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"请输入您想打开的 APP 名称"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         UITextField *nameText = alertController.textFields.firstObject;
                                                         
                                                         
                                                         AVObject *appNameSubmitted = [AVObject objectWithClassName:@"appNameSubmitted"];
                                                         [appNameSubmitted setObject:[nameText text] forKey:@"appName"];
                                                         [appNameSubmitted save];
                                                         
                                                         
                                                         UIAlertController *alertController =
                                                         [UIAlertController alertControllerWithTitle:@"提交成功"
                                                                                             message:@"感谢您的反馈"
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                                         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                                                                            style:UIAlertActionStyleDefault
                                                                                                          handler:nil];
                                                         [alertController addAction:okAction];
                                                         [self presentViewController:alertController animated:YES completion:nil];
                                                         
                                                     }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1){
        return [self.appDictionaryArr count];
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section != 2){
        static NSString *cellIdentifier = @"KPSchemeTableViewCell";
        UINib *nib = [UINib nibWithNibName:@"KPSchemeTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        KPSchemeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if(indexPath.section == 1){
//            if([self.searchController isActive]){
//                [cell.appNameLabel setText:self.searchResults[indexPath.row]];
//            }else{
                [cell.appNameLabel setText:self.allNames[indexPath.row]];
//            }
        }else{
            cell.appNameLabel.text = @"无";
        }
        
        if(indexPath == self.selectedPath){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section != 1){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 10;
    }else{
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 2){
        [self showSubmitAlert];
    }else if(indexPath.section == 1){
        if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[[self.appDictionaryArr objectAtIndex:indexPath.row] allValues][0]]]){
            
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"您尚未安装 %@", [self.appDictionaryArr[indexPath.row] allKeys][0]]
                                                message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];

        }else{
            if(self.selectedPath == indexPath){
                self.selectedPath = NULL;
            }else{
                self.selectedPath = indexPath;
            }
        }
    }else{
        if(self.selectedPath == indexPath){
            self.selectedPath = NULL;
        }else{
            self.selectedPath = indexPath;
        }
    }
    [tableView reloadData];
}

#pragma mark - Search Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    [self.searchResults removeAllObjects];
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", searchController.searchBar.text];
    self.searchResults = [[self.allNames filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    //刷新表格
    [self.tableView reloadData];
}

@end
