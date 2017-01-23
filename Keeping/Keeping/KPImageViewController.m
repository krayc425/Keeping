//
//  KPImageViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/23.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPImageViewController.h"

@interface KPImageViewController ()

@end

@implementation KPImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:tapGesture];
    
    [self.imageView setImage:self.img];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)hide:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
