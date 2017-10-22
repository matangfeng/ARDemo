//
//  ViewController.m
//  太陽系1
//
//  Created by XerangaWang on 2017/9/6.
//  Copyright © 2017年 XerangaWang. All rights reserved.
//

#import "ViewController.h"
#import "SCenViewViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickBtn:(id)sender {
    
    SCenViewViewController * vc = [[SCenViewViewController alloc]init];
    [self presentViewController:vc animated:true completion:nil];
}

@end
