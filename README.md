# SocialShare
自定义分享，包括微信，QQ，新浪 等分享，微信的原始demo比较坑，需要添加包
Security.framework或者libc++
如果报错X86，或者arm64的错误，可确认是否添加了这两个包与否

//下面还会添加QQ分享和QQ空间以及新浪微博的分享 谢谢关注
1、2016年06月12日添加了QQ和QQ空间的分享
    >1.TencentApiSdk 如果报错，可能需要设置下【TARGETS】-> Build Phases -> Build Active Architecture Only - Debug 设置为YES

2、2016年06月13日添加了新浪微博的分享
    >1.-[NSConcreteMutableData wbsdk_base64EncodedString]: unrecognized selector sent to instance 0x7ff61b8 如果报这个错 需要在 【Build Settings】->【Other Linker Flags】中添加-ObjC
    >2.此外还需要添加 ImageIO.framework 这样才可以工作正常