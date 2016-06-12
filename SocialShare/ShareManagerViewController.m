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
    
    //必须注册不然无法分享
    _tencentOAuth =  [[TencentOAuth alloc] initWithAppId:@"222222"
                                             andDelegate:self];
    
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
/**
 *  微信，微信收藏，微信朋友圈分享
 *
 *  @param sender
 */
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
        
        [self sendNewsMessageWithNetworkImageForQQ];
    }
    
}

/**
 *  QQ 分享图片和 文字 以及 网页
 *
 *  @param sender qq分享按钮
 */
-(IBAction)QQButtonAction:(UIButton *)sender{
    
    if (_shareType == ShareTypeText) {
        
        [self sendTextMessageForQQ];
        
    }else if (_shareType == ShareTypeImage){
        
        [self sendImageMessageForQQ];
        
    }else if (_shareType == ShareTypeURL){
        
        [self sendNewsMessageWithNetworkImageForQQ];
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

#pragma mark /******************QQ和QQ空间相关分享操作******************/

- (void)onReq:(QQBaseReq *)req
{
    switch (req.type)
    {
        case EGETMESSAGEFROMQQREQTYPE:
        {
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)onResp:(QQBaseResp *)resp
{
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:sendResp.result message:sendResp.errorDescription delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        default:
        {
            break;
        }
    }
}


/**
 *  QQ 分享文字
 */
- (void) sendTextMessageForQQ
{
    
    QQApiTextObject* txtObj = [QQApiTextObject objectWithText:kTextMessage];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    
}

/**
 *  QQ分享图片
 */
- (void) sendImageMessageForQQ
{
    
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"res1.jpg"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    
    QQApiImageObject* img = [QQApiImageObject objectWithData:data previewImageData:data title:@"默认图片分享" description:kMessageExt];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    
    
}

/**
 *  QQ分享网页-使用网络图片
 */
- (void) sendNewsMessageWithNetworkImageForQQ
{
    
    NSString *titleStr = @"天公作美伦敦奥运圣火点燃成功 火炬传递开启";
    NSString *ContentStr = @"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。";
    NSString *urlStr = @"http://sports.qq.com/a/20120510/000650.htm";
    
    NSURL *previewURL = [NSURL URLWithString:@"http://img1.gtimg.com/sports/pics/hv1/87/16/1037/67435092.jpg"];
    NSURL* url = [NSURL URLWithString:urlStr];
    
    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:titleStr description:ContentStr previewImageURL:previewURL];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    
}

/**
 *  分享网络 - 本地图片
 */
- (void) sendNewsMessageWithLocalImage
{
    NSString *titleStr = @"天公作美伦敦奥运圣火点燃成功 火炬传递开启";
    NSString *ContentStr = @"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。";
    NSString *urlStr = @"http://sports.qq.com/a/20120510/000650.htm";
    
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"res1.jpg"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSURL* url = [NSURL URLWithString:urlStr];
    
    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:titleStr description:ContentStr previewImageData:data];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    
}


/**
 *  QQ分享后的回调通知
 *
 *  @param sendResult
 */
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"当前QQ版本太低，需要更新" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}



@end
