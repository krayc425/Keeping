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
    
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setBarTintColor:[Utilities getColor]];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setFont];
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

- (void)setFont{
    NSDictionary *dicNav = @{
                             NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:22.0],
                             NSForegroundColorAttributeName: [UIColor whiteColor]
                             };
    self.navigationBar.titleTextAttributes = dicNav;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
