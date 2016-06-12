//
//  ShareManagerViewController.m
//  SocialShare
//
//  Created by 嵇明新 on 16/6/8.
//  Copyright © 2016年 lanhe. All rights reserved.
//

#import "ShareManagerViewController.h"
#import "WXApiManager.h"
#import "WXApiRequestHandler.h"
#import "Constant.h"

@interface ShareManagerViewController ()<WXApiManagerDelegate>

@property (nonatomic) enum WXScene currentScene;


@end

static ShareManagerViewController *defaultShareManager;

@implementation ShareManagerViewController

/**
 *  单例模式分享框架
 *
 *  @return 单例
 */
+(instancetype)defaultShareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        defaultShareManager = [[ShareManagerViewController alloc] init];
        
    });
    
    return defaultShareManager;
}

/**
 *  将要出现的时候
 *
 *  @param animated
 */
-(void)viewDidAppear:(BOOL)animated{
    
    [self.view sendSubviewToBack:_bgTouchButton];
    
    CGFloat widthFloat = defaultShareManager.view.frame.size.width;
    CGFloat kongWidth = widthFloat - 60 * 4;
    CGFloat jianJu = (kongWidth - 20 *2)/3;
    //设置第一个边距
    defaultShareManager.leadingOfOneLineConstraint.constant = 20;
    defaultShareManager.leadingOfTwoLineConstraint.constant = 20;
    defaultShareManager.jianJuOneOfOneLineConstraint.constant = jianJu;
    defaultShareManager.jianJuTwoOfOneLineConstraint.constant = jianJu;
    defaultShareManager.jianJuThreeOfOneLineConstraint.constant = jianJu;
    defaultShareManager.jianJuOneOfTwoLineConstraint.constant = jianJu;
    defaultShareManager.jianJuTwoOfTwoLineConstraint.constant = jianJu;
    defaultShareManager.jianJuThreeOfTwoLineConstraint.constant = jianJu;
    
    [super viewDidAppear:animated];
}


/**
 *  调用界面初始化
 */
- (void)viewDidLoad {
   
    [WXApiManager sharedManager].delegate = self;
    
    CGRect windowFrame = [[UIScreen mainScreen]bounds];
    
    [ShareManagerViewController defaultShareManager].view.frame = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
    
    [super viewDidLoad];
    
}

/**
 *  弹出界面 - 动画从底部滑入
 */
-(void)viewAnimation{
    _shareToolView.hidden = NO;
    _shareToolView.frame = CGRectMake(_shareToolView.frame.origin.x, self.view.frame.size.height, _shareToolView.frame.size.width, _shareToolView.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        _shareToolView.frame = CGRectMake(_shareToolView.frame.origin.x, self.view.frame.size.height - _shareToolView.frame.size.height, _shareToolView.frame.size.width, _shareToolView.frame.size.height);
    }];
}

/**
 *  界面消失 - 动画滑出
 *
 *  @param sender
 */
-(IBAction)dismissSelf:(id)sender{
    
    _shareToolView.frame = CGRectMake(_shareToolView.frame.origin.x, self.view.frame.size.height - _shareToolView.frame.size.height, _shareToolView.frame.size.width, _shareToolView.frame.size.height);
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _shareToolView.frame = CGRectMake(_shareToolView.frame.origin.x, self.view.frame.size.height, _shareToolView.frame.size.width, _shareToolView.frame.size.height);
        
    } completion:^(BOOL finished) {
        _shareToolView.hidden = YES;
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        
    }];
    
    
    
}

//分享
-(void)setShareData:(NSDictionary *)dictionary actionType:(ShareType)shareType{
    _shareType = shareType;
}

- (void)didReceiveMemoryWarning {
    
    _bgTouchButton = nil;
    _shareToolView = nil;
    
    [super didReceiveMemoryWarning];

}

#pragma mark /******************按钮点击事件******************/
-(IBAction)weChatButtonAction:(UIButton *)sender{
    if (sender.tag == 1001) {//微信会话
        _currentScene = WXSceneSession;
        
        
    }else if(sender.tag == 1002){//微信朋友圈
    
        _currentScene = WXSceneTimeline;
    }else if(sender.tag == 1003){//微信朋友圈
        
        _currentScene = WXSceneFavorite;
    }
    
    
    if (_shareType == ShareTypeText) {
        
        [self sendTextContent];
    
    }else if (_shareType == ShareTypeImage){
    
        [self sendImageContent];
        
    }else if (_shareType == ShareTypeURL){
        
        [self sendLinkContent];
    }
    
    
}

/**
 *  调用系统的风向
 *
 *  @param sender 
 */
-(IBAction)otherShareAction:(id)sender{

    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[[[NSBundle mainBundle] URLForResource:@"res1" withExtension:@"jpg"]] applicationActivities:@[]];
 
    
    [self presentViewController:activity animated:YES completion:NULL];
}


#pragma mark /******************微信相关分享操作******************/

- (void)sendTextContent {
    [WXApiRequestHandler sendText:kTextMessage
                          InScene:_currentScene];
}

- (void)sendImageContent {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res1" ofType:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    UIImage *thumbImage = [UIImage imageNamed:@"res1thumb.png"];
    [WXApiRequestHandler sendImageData:imageData
                               TagName:kImageTagName
                            MessageExt:kMessageExt
                                Action:kMessageAction
                            ThumbImage:thumbImage
                               InScene:_currentScene];
}

- (void)sendLinkContent {
    UIImage *thumbImage = [UIImage imageNamed:@"res2.png"];
    [WXApiRequestHandler sendLinkURL:kLinkURL
                             TagName:kLinkTagName
                               Title:kLinkTitle
                         Description:kLinkDescription
                          ThumbImage:thumbImage
                             InScene:_currentScene];
}

@end
