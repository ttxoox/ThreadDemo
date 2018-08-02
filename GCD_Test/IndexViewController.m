//
//  IndexViewController.m
//  GCD_Test
//
//  Created by zemel on 2018/8/2.
//  Copyright © 2018年 zemel. All rights reserved.
//

#import "IndexViewController.h"
#import "ViewController.h"
#import "OperationViewController.h"
#import "ThreadViewController.h"
@interface IndexViewController ()

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)gcdHandle:(id)sender {
    ViewController * vc = [[ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)operationHandle:(id)sender {
    OperationViewController * operation = [[OperationViewController alloc] init];
    [self.navigationController pushViewController:operation animated:YES];
}
- (IBAction)threadHandle:(id)sender {
    ThreadViewController * vc = [[ThreadViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
