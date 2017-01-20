//
//  KPNavigationViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPNavigationViewController.h"
#import "Utilities.h"

@interface KPNavigationViewController ()

@end

@implementation KPNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dicNav = @{
                             NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:22.0],
                             NSForegroundColorAttributeName: [UIColor whiteColor]
                             };
    self.navigationBar.titleTextAttributes = dicNav;
    
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setBarTintColor:[Utilities getColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count != 0) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_BACK"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)back{
    [self popViewControllerAnimated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
