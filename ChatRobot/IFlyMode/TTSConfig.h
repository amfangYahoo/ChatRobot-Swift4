//
//  TTSConfig.h
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/17.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iflyMSC/iflyMSC.h"

@interface TTSConfig : NSObject

+(TTSConfig *)sharedInstance;

/**
 以下参数，需要通过
 iFlySpeechSynthesizer
 进行设置
 ****/

@property (nonatomic) NSString *speed;//语速
@property (nonatomic) NSString *volume;//音量
@property (nonatomic) NSString *pitch;//音调
@property (nonatomic) NSString *sampleRate;//采样率
@property (nonatomic) NSString *vcnName;//发音人
@property (nonatomic) NSString *engineType;//引擎类型,"auto","local","cloud"


/**
 设置用
 用户暂不用关心
 ****/
@property (nonatomic,strong) NSArray *vcnNickNameArray;
@property (nonatomic,strong) NSArray *vcnIdentiferArray;

@end
