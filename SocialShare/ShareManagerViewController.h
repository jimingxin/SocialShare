//
//  ShareManagerViewController.h
//  SocialShare
//
//  Created by 嵇明新 on 16/6/8.
//  Copyright © 2016年 lanhe. All rights reserved.
//

#import <UIKit/UIKit.h>

/*! @brief 分享类型
 *
 */
typedef NS_ENUM(NSInteger,ShareType){
    ShareTypeText  = 0,        /**< 分享文字  */
    ShareTypeImage = 1,        /**< 分享图片    */
    ShareTypeURL = 2,        /**< 分享链接  */
};
@interface ShareManagerViewController : UIViewController




#pragma mark /***********成员变量和属性*****************/
//分享类型
@property (nonatomic, assign) ShareType shareType;


//分享视图
@property (nonatomic, weak) IBOutlet  UIView *shareToolView;

//背景点击按钮
@property (nonatomic, weak) IBOutlet  UIButton *bgTouchButton;

//第一行 约束 IBOutlet
//距离左边边距
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingOfOneLineConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *jianJuOneOfOneLineConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *jianJuTwoOfOneLineConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *jianJuThreeOfOneLineConstraint;

//第二行 约束 IBOutlet
//距离左边边距
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingOfTwoLineConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *jianJuOneOfTwoLineConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *jianJuTwoOfTwoLineConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *jianJuThreeOfTwoLineConstraint;



#pragma mark /***********成员方法*****************/
/**
 *  单例获取分享对象
 *
 *  @return
 */
+(instancetype)defaultShareManager;

/**
 *  弹出动画
 */
-(void)viewAnimation;


-(void)setShareData:(NSDictionary *) dictionary actionType:(ShareType)shareType;

@end
