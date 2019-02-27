//
//  MessageBean.swift
//  qqchat
//
//  Created by zhouxiaobo on 15/1/27.
//  Copyright (c) 2015年 zhouxiaobo. All rights reserved.
//

import UIKit

class Message {
    
    var msgContent:String           //聊天内容
    var isSelftalk:Bool = false     //是否自己说话
    
    var msgBgImg:UIImage{
        get{
            if(!isSelftalk){
                return UIImage(named: "yoububble.png")!
            }else{
                return UIImage(named: "mebubble.png")!
            }
        }
    }
    
    var font:UIFont = defaultMsgfnt

    convenience init(msgContent:String,font:UIFont,isSelftalk:Bool){
        self.init(msgContent:msgContent,isSelftalk:isSelftalk)
        self.font = font
    }
    
    init(msgContent:String,isSelftalk:Bool){
        self.isSelftalk = isSelftalk
        self.msgContent = msgContent
    }
}
