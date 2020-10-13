//
//  SceneDelegate.h
//  U球直播
//
//  Created by Jobs on 2020/10/9.
//

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property(nonatomic,strong)UIWindow *window;
@property(nonatomic,strong)UIWindowScene *windowScene;

+(SceneDelegate *)sharedInstance;

@end

