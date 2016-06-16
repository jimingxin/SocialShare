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
#import "WeiboSDK.h"
#import "AppDelegate.h"
#define kRedirectURI    @"http://www.sina.com"
#define ImagePath(imageName,ImageType) [[NSBundle mainBundle] pathForResource:_shareDictionary[imageName] ofType:ImageType]


@interface ShareManagerViewController ()<WXApiManagerDelegate,WBHttpRequestDelegate>

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
    
    //必须注册不然无法分享 -qq和qq空间需要使用的
    
    
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

//分享传入数据
-(void)setShareData:(NSDictionary *)dictionary actionType:(ShareType)shareType{
    _shareDictionary = dictionary;
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
 *  QQ空间 分享图片和 文字
 *
 *  @param sender qq空间分享按钮
 */
-(IBAction)QQZoneButtonAction:(UIButton *)sender{
    
    if (_shareType == ShareTypeText) {
        
        [self sendTextMessageForQQZone];
        
    }else if (_shareType == ShareTypeImage){
        
        [self sendImageMessageForQQZone];
        
    }
}

/**
 *  Sina微博 分享图片和 文字 以及连接
 *
 *  @param sender qq空间分享按钮
 */
-(IBAction)SinaWeiBoButtonAction:(UIButton *)sender{
    
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
    
}

/**
 *  复制按钮点击
 */
-(IBAction)copyButtonAction:(UIButton *)sender{
    
     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (_shareType == ShareTypeText) {

        [pasteboard setString: _shareDictionary[@"Text"]];
        
    }else if (_shareType == ShareTypeImage){
        
         [pasteboard setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_shareDictionary[@"Image"] ofType:@"jpg"]]];
    }else if (_shareType == ShareTypeURL){
        
        [pasteboard setURL:[NSURL URLWithString:_shareDictionary[@"URL"]]];
    }
    
    [self showAlertView:@"复制成功"];
}

/**
 *  调用系统的分享
 *
 *  @param sender
 */
-(IBAction)otherShareAction:(id)sender{
    
    UIActivityViewController *activity = nil;
    
    if (_shareType == ShareTypeText) {
        
        activity = [[UIActivityViewController alloc] initWithActivityItems:@[_shareDictionary[@"Text"]] applicationActivities:@[]];
        
    }else if (_shareType == ShareTypeImage){
        UIImage *shareImage =[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_shareDictionary[@"Image"] ofType:@"jpg"]];
        
         activity = [[UIActivityViewController alloc] initWithActivityItems:@[shareImage] applicationActivities:@[]];
        
    }else if (_shareType == ShareTypeURL){
        
        activity = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:_shareDictionary[@"URL"]]] applicationActivities:@[]];
    }
    
    
    
    [self presentViewController:activity animated:YES completion:NULL];
}

/**
 *  弹出提醒
 */
-(void)showAlertView:(NSString *)alertText{
    
    UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-240)/2, (self.view.frame.size.height - 120)/2, 240, 60)];
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.font = [UIFont systemFontOfSize:16.f];
    alertLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    alertLabel.text = alertText;
    alertLabel.alpha = 0;
    alertLabel.layer.cornerRadius = 7;
    alertLabel.layer.masksToBounds = YES;
    [self.view addSubview:alertLabel];
    
    [UIView animateWithDuration:1.0 animations:^{
        //动画执行代码
        alertLabel.alpha = 0.8;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                alertLabel.alpha = 0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [alertLabel removeFromSuperview];
                    
                }
                
            }];
        }
        
    }];
}

#pragma mark /******************微信相关分享操作******************/

- (void)sendTextContent {
    [WXApiRequestHandler sendText:_shareDictionary[@"Text"]
                          InScene:_currentScene];
}

- (void)sendImageContent {
    NSData *imageData = [NSData dataWithContentsOfFile:ImagePath(_shareDictionary[@"Image"],@"jpg")];
    
    UIImage *thumbImage = [UIImage imageNamed:@"res1thumb.png"];
    [WXApiRequestHandler sendImageData:imageData
                               TagName:kImageTagName
                            MessageExt:kMessageExt
                                Action:kMessageAction
                            ThumbImage:thumbImage
                               InScene:_currentScene];
}

- (void)sendLinkContent {
    UIImage *thumbImage = [UIImage imageWithContentsOfFile:ImagePath(_shareDictionary[@"Image"],@"jpg")];
    [WXApiRequestHandler sendLinkURL:_shareDictionary[@"URL"]
                             TagName:kLinkTagName
                               Title:_shareDictionary[@"Text"]
                         Description:_shareDictionary[@"URLContent"]
                          ThumbImage:thumbImage
                             InScene:_currentScene];
}

#pragma mark /******************QQ相关分享操作******************/

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
    
    QQApiTextObject* txtObj = [QQApiTextObject objectWithText:_shareDictionary[@"Text"]];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    
}

/**
 *  QQ分享图片
 */
- (void) sendImageMessageForQQ
{
    
    
    NSData* data = [NSData dataWithContentsOfFile:ImagePath(_shareDictionary[@"Image"],@"jpg")];
    
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
    
    NSString *titleStr = _shareDictionary[@"Text"];
    NSString *ContentStr = _shareDictionary[@"URLContent"];
    NSString *urlStr = _shareDictionary[@"URL"];;
    
    NSURL *previewURL = [NSURL URLWithString:_shareDictionary[@"URLIMG"]];
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
    NSString *titleStr = _shareDictionary[@"Text"];
    NSString *ContentStr = _shareDictionary[@"URLContent"];
    NSString *urlStr = _shareDictionary[@"URL"];
    
    
       NSData* data = [NSData dataWithContentsOfFile:ImagePath(_shareDictionary[@"Image"],@"jpg")];
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


#pragma mark /******************QQ空间相关分享操作******************/
/**
 *  QQ空间 分享文字
 */
- (void) sendTextMessageForQQZone
{
    
    QQApiImageArrayForQZoneObject *obj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:nil title:_shareDictionary[@"Text"]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleSendResult:sent];
    
}

/**
 *  QQ空间分享图片
 */
- (void) sendImageMessageForQQZone
{
    NSData *imgData = [NSData dataWithContentsOfFile:ImagePath(_shareDictionary[@"Image"],@"jpg")];
    
    NSArray *imageAssetsForQZone =[[NSArray alloc] initWithObjects:imgData, nil];
    QQApiImageArrayForQZoneObject *img = [QQApiImageArrayForQZoneObject objectWithimageDataArray:imageAssetsForQZone title:_shareDictionary[@"Text"]];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleSendResult:sent];
    
    
}


#pragma mark /*********************新浪微博分享相关操作*******************/
- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    if (_shareType == ShareTypeText)
    {
        message.text = _shareDictionary[@"Text"];
    }
    
    if (_shareType == ShareTypeImage)
    {
        WBImageObject *image = [WBImageObject object];
        image.imageData = [NSData dataWithContentsOfFile:ImagePath(_shareDictionary[@"Image"],@"jpg")];
        message.imageObject = image;
    }
    
    if (_shareType == ShareTypeURL)
    {
        WBWebpageObject *webpage = [WBWebpageObject object];
        webpage.objectID = @"identifier1";
        webpage.title = _shareDictionary[@"Text"];
        webpage.description = _shareDictionary[@"URLContent"];
        webpage.thumbnailData = [NSData dataWithContentsOfFile:ImagePath(_shareDictionary[@"Image"],@"jpg")];
        webpage.webpageUrl = @"http://sina.cn?a=1";
        message.mediaObject = webpage;
    }
    
    return message;
}


@end
