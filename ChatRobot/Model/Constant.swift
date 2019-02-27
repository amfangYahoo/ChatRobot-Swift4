//
//  Constant.swift
//  qqchat
//
//  Created by zhouxiaobo on 15/1/27.
//  Copyright (c) 2015年 zhouxiaobo. All rights reserved.
//

import UIKit

let screenWidth:CGFloat = UIScreen.main.bounds.width        //计算屏幕宽度
let screenHeight:CGFloat = UIScreen.main.bounds.height      //计算屏幕高度

let headerWidth:CGFloat = 50        //头像的宽
let headerHeight:CGFloat = 50       //头像的高

let headerGap2Border:CGFloat = 10   //头像距离边框的位置
let messgeGap:CGFloat = 10 //每个对话框之间的间距

let defaultMsgfnt:UIFont = UIFont(name:"Arial" , size: 14)!   //聊天的默认字体

var maxtalkWidth:CGFloat = screenWidth - headerGap2Border*2 - headerWidth*2 - 40 //最大的聊天框的宽度

//AWS服务器地址全局变量
class Constant {
    struct Variables {
        static var urlAWS = ""
    }
}






