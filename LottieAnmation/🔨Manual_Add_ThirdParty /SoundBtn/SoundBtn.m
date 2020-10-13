//
//  SoundBtn.m
//  JinXian Finance
//
//  Created by 刘赓 on 2017/6/6.
//  Copyright © 2017年 刘赓. All rights reserved.
//

#import "SoundBtn.h"
#import "PlaySound.h"//播放自定义声音关键代码
#import "UIControl+XY.h"

@interface SoundBtn (){

}

@end

@implementation SoundBtn

-(instancetype)init{

    if (self = [super init]) {
        
//        self.backgroundColor = RandomColor;
        
        self.uxy_acceptEventInterval = 0.5f;
    }

    return self;
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent*)event{
    
    [PlaySound playSoundEffect:@"Sound"
                          type:@"wav"];
    
    [super touchesBegan:touches
              withEvent:event];
    
}













@end
