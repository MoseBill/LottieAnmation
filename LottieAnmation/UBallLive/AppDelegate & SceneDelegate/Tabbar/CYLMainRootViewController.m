//
//  CYLMainRootViewController.m
//  CYLTabBarController
//
//  Created by chenyilong on 7/3/2019.
//  Copyright © 2019 微博@iOS程序犭袁. All rights reserved.
//

#import "CYLMainRootViewController.h"
#import "MainTabBarController.h"
#import "CYLPlusButtonSubclass.h"

SuspendBtn *CYLMainRootViewController_suspendBtn;//extern 外界可以对其进行开始和停止操作

@interface CYLMainRootViewController ()

@property(nonatomic,strong)SuspendBtn *suspendBtn;//这个悬浮按钮是最顶层的，当在旋转的时候不能被拖动

@end

@implementation CYLMainRootViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createNewTabBar];
    self.suspendBtn.alpha = 1;
    [self setNavigationBarHidden:YES animated:YES];
}

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//
//}

-(CYLTabBarController *)createNewTabBar{
    [CYLPlusButtonSubclass registerPlusButton];
    return [self createNewTabBarWithContext:nil];
}

-(CYLTabBarController *)createNewTabBarWithContext:(NSString *__nullable)context {
    MainTabBarController *tabBarController = [[MainTabBarController alloc] initWithContext:context];
    self.viewControllers = @[tabBarController];
    return tabBarController;
}

#pragma mark —— lazyLoad
-(SuspendBtn *)suspendBtn{
    if (!_suspendBtn) {
        _suspendBtn = SuspendBtn.new;
        CYLMainRootViewController_suspendBtn = _suspendBtn;
        [_suspendBtn setImage:KBuddleIMG(@"⚽️PicResource",
                                         @"Others",
                                         nil,
                                         @"美美")
                     forState:UIControlStateNormal];
        _suspendBtn.isAllowDrag = YES;//悬浮效果必须要的参数
        @weakify(self)
        self.view.vc = weak_self;
        [self.view addSubview:_suspendBtn];
        _suspendBtn.frame = CGRectMake(180, 200, 50, 50);
        [UIView cornerCutToCircleWithView:_suspendBtn AndCornerRadius:25];
        [[_suspendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self->_suspendBtn startRotateAnimation];
            
        }];
    }return _suspendBtn;
}


@end
