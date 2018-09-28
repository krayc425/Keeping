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
#import "KPScheme.h"

@implementation KPSchemeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedString(@"Choose an app", nil)];
    
    //隐藏返回键
    [self.navigationItem setHidesBackButton:YES];
    //导航栏左上角
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_BACK"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItems = @[cancelItem];
    //导航栏右上角
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_DONE"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.rightBarButtonItems = @[okItem];
    
    self.searchResults = [[NSMutableArray alloc] init];
    
    [self loadApps];
    //搜索框
    [self setSearchControllerView];
}

- (void)loadApps{
    self.schemeArr = [NSMutableArray arrayWithArray:[[KPSchemeManager shareInstance] getSchemeArr]];
    
    [self.tableView reloadData];
}

- (void)setSearchControllerView{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.frame = CGRectMake(0, 100, self.view.frame.size.width, 44);
    self.searchController.searchBar.placeholder = NSLocalizedString(@"App name", nil);
    [self.searchController.searchBar setValue:NSLocalizedString(@"Done", nil) forKey:@"_cancelButtonText"];
    // 设置SearchBar的颜色主题为白色
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    self.searchController.searchBar.backgroundImage = [[UIImage alloc] init];
    //搜索栏表头视图
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    //背景颜色
    self.searchController.searchResultsUpdater = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.delegate passScheme:self.selectedApp];
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSubmitAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Submit a new app", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *nameText = nil;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"App name", nil);
        nameText = textField;
    }];
    __block UITextField *schemeText = nil;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"对应 URL Scheme（可选）";
        schemeText = textField;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Submit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        AVObject *appNameSubmitted = [AVObject objectWithClassName:@"appNameSubmitted"];
        [appNameSubmitted setObject:[nameText text] forKey:@"appName"];
        [appNameSubmitted setObject:[schemeText text] forKey:@"appScheme"];
        [appNameSubmitted save];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Submit success", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    [alert addAction:submitAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.searchController isActive]){
        return 1;
    }else{
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.searchController isActive]){
        return self.searchResults.count;
    }else{
        if(section == 1){
            return [self.schemeArr count];
        }else{
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.searchController.isActive){
        
        static NSString *cellIdentifier = @"KPSchemeTableViewCell";
        UINib *nib = [UINib nibWithNibName:@"KPSchemeTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        KPSchemeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        KPScheme *s = self.searchResults[indexPath.row];
        [cell.appNameLabel setText:s.name];
        
        AVFile *file = s.iconFile;
        [file getThumbnail:YES width:100 height:100 withBlock:^(UIImage *image, NSError *error) {
            [cell.appIconImg setImage:image];
        }];
        
        if(self.selectedApp == self.searchResults[indexPath.row]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
        
    }else{
        
        if(indexPath.section <= 1){
            static NSString *cellIdentifier = @"KPSchemeTableViewCell";
            UINib *nib = [UINib nibWithNibName:@"KPSchemeTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
            KPSchemeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            if(indexPath.section == 0){
                cell.appNameLabel.text = NSLocalizedString(@"None", nil);
                
                [cell.appIconImg setImage:[UIImage new]];
                
                if(self.selectedApp == NULL){
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }else{
                KPScheme *s = self.schemeArr[indexPath.row];
                [cell.appNameLabel setText:s.name];
                
                AVFile *file = s.iconFile;
                [file getThumbnail:YES width:100 height:100 withBlock:^(UIImage *image, NSError *error) {
                    [cell.appIconImg setImage:image];
                }];
                
                if(self.selectedApp == self.schemeArr[indexPath.row]){
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            
            return cell;
        }else{
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.searchController.isActive){
        return 44;
    }else{
        if(indexPath.section != 1){
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
        }else{
            return 44;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.searchController.isActive){
        return 10;
    }else{
        if (indexPath.section == 1) {
            return 10;
        }else{
            return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.searchController.isActive){
        if(self.selectedApp != self.searchResults[indexPath.row]){
            self.selectedApp = self.searchResults[indexPath.row];
        }else{
            self.selectedApp = NULL;
        }
    }else{
        if(indexPath.section == 3){
            [self showSubmitAlert];
        }else if(indexPath.section == 2){
            [[KPSchemeManager shareInstance] getSchemes];
            [self loadApps];
        }else{
            if(indexPath.section == 1){
                if(self.selectedApp != self.schemeArr[indexPath.row]){
                    self.selectedApp = self.schemeArr[indexPath.row];
                }else{
                    self.selectedApp = NULL;
                }
            }else{
                self.selectedApp = NULL;
            }
        }
    }
    [tableView reloadData];
}

#pragma mark - Search Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    if (self.searchResults.count > 0) {
        [self.searchResults removeAllObjects];
    }
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", searchController.searchBar.text];
    self.searchResults = [[self.schemeArr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    //刷新表格
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        //滚动到选择的地方
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[self.schemeArr indexOfObject:self.selectedApp] inSection:1] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    });
}

@end
