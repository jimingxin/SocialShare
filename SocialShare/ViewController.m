//
//  ViewController.m
//  SocialShare
//
//  Created by 嵇明新 on 16/6/8.
//  Copyright © 2016年 lanhe. All rights reserved.
//

#import "ViewController.h"
#import "ShareManagerViewController.h"

@interface ViewController ()
{
    ShareType _shareType;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)showShareView:(UIButton *)sender{
    

    [self.view addSubview:[ShareManagerViewController defaultShareManager].view];
    
    [[ShareManagerViewController defaultShareManager] viewAnimation];
    
    [[ShareManagerViewController defaultShareManager] setShareData:nil actionType:_shareType];
}


-(IBAction)chageAction:(UISegmentedControl *)sender{

    if (sender.selectedSegmentIndex == 0) {
        _shareType = ShareTypeText;
    }else if (sender.selectedSegmentIndex == 1){
    
        _shareType = ShareTypeImage;
    }else if (sender.selectedSegmentIndex == 2){
        
        _shareType = ShareTypeURL;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
