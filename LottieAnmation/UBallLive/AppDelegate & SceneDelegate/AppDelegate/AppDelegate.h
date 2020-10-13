//
//  AppDelegate.h
//  U球直播
//
//  Created by Jobs on 2020/10/9.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#ifdef DEBUG
#import <DoraemonKit/DoraemonManager.h>
#endif

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(readonly,strong)NSPersistentCloudKitContainer *persistentContainer;
@property(nonatomic,strong)UIWindow *window;//仅仅为了iOS 13 版本向下兼容而存在

-(void)saveContext;

/**
 *  设置navigationBar样式
 */
-(void)setUpNavigationBarAppearance;

+(AppDelegate *)sharedInstance;

@end

