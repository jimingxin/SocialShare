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
    

    //分享设置参数 
    [self.view addSubview:[ShareManagerViewController defaultShareManager].view];

    [[ShareManagerViewController defaultShareManager] viewAnimation];
    
    NSDictionary *shareDictionary = @{@"Text":@"我要分享的文字部分",@"Image":@"res1",@"URL":@"http://sports.qq.com/a/20120510/000650.htm",@"URLContent":@"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。",@"URLIMG":@"http://img1.gtimg.com/sports/pics/hv1/87/16/1037/67435092.jpg"};
    
    [[ShareManagerViewController defaultShareManager] setShareData:shareDictionary actionType:_shareType];
    
    
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
