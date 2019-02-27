//
//  MessageUIView.swift
//  qqchat
//
//  Created by zhouxiaobo on 15/1/27.
//  Copyright (c) 2015年 zhouxiaobo. All rights reserved.
//

import UIKit

class MessageUIView: UIView {
    
    private var contextSize:CGSize //聊天文字的CGSize
    
    //消息内容视图
    var customView:UIView!
    //消息背景
    var bubbleImage:UIImageView!
    //头像
    var avatarImage:UIImageView!
    //消息数据结构
    //var message:Message
    var msgItem:MessageItem!
    
//    //计算属性 内部聊天内容的长宽,气泡聊天框的长宽和聊天内容在气泡里的起始高度
//    var messageSize:(innerx:CGFloat,innery:CGFloat,outletx:CGFloat,outlety:CGFloat,labelStartYInMessge:CGFloat){
//        get{
//            if(message.msgContent != ""){
//                if(contextSize.width > maxtalkWidth){
//                    //CGSize(width: 100, height: 100)
//                    let size = CGSize(width: maxtalkWidth, height: 1000)
//                    //var size:CGSize = CGSizeMake(maxtalkWidth, 1000)    //预定义一块很大的地方来做变化
//                    let options = NSStringDrawingOptions.usesLineFragmentOrigin
//                    let attributes:Dictionary = [NSAttributedString.Key.font:message.font] //获得字体属性的字典
//
//                    //重新设定label的长宽
//                    let tmpRect:CGRect = NSString(string: message.msgContent).boundingRect(with: size, options: options, attributes: attributes, context: nil)
//
//                    //var width = maxtalkWidth
//
//                    return (maxtalkWidth,tmpRect.height,maxtalkWidth + 35, tmpRect.height + 20, 5)
//                }else{
//                    return (contextSize.width + 10,contextSize.height,contextSize.width + 40, 60, 17)
//                }
//            }else{
//                return (0, 0, 80, 60, 0)
//            }
//        }
//    }
    
    init(frame: CGRect, message:MessageItem){
        self.msgItem = message
        
        //获取消息内容的CGSize
        contextSize = self.msgItem.view.frame.size
        super.init(frame: frame)
        
        createItemUIView()
//        //定义一个聊天框的容器
//        let talkContentLabel = UILabel(frame: frame)
//        talkContentLabel.text = message.msgContent
//        talkContentLabel.font = message.font
//        talkContentLabel.numberOfLines = 0
//        talkContentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
//
//        //获取这段聊天文字的CGSize
//        contextSize = message.msgContent.getStringCGSize(fnt: message.font)
//        super.init(frame: frame)
//
//
//        var labelStartXInMessge:CGFloat = 0
//        let labelStartYInMessge = messageSize.labelStartYInMessge
//
//        let imgtalkview = UIImageView(image: UIImage.resizableImage(image: message.msgBgImg))
//
//
//        if(!message.isSelftalk){
//            labelStartXInMessge = 25
//            imgtalkview.frame = CGRect(x: headerGap2Border + headerWidth, y: 0, width: messageSize.outletx, height: messageSize.outlety)
//        }else{
//            labelStartXInMessge = 15
//            imgtalkview.frame = CGRect(x: screenWidth - messageSize.outletx - headerWidth - headerGap2Border, y: 0, width:  messageSize.outletx, height: messageSize.outlety)
//        }
//
//        talkContentLabel.frame = CGRect(x: labelStartXInMessge, y: labelStartYInMessge, width: messageSize.innerx, height: messageSize.innery)
//
//        imgtalkview.addSubview(talkContentLabel)
//        self.addSubview(imgtalkview)
    }
    
    func createItemUIView() {
        
        if (self.bubbleImage == nil)
        {
            self.bubbleImage = UIImageView()
            self.addSubview(self.bubbleImage)
        }
        
        let type =  self.msgItem.mtype
        let width =  self.msgItem.view.frame.size.width
        let height =  self.msgItem.view.frame.size.height
        
        var x =  (type == ChatType.someone) ? 0 : self.frame.size.width - width -
            self.msgItem.insets.left - self.msgItem.insets.right
        
        var y:CGFloat =  0
        //显示用户头像
        if (self.msgItem.user.username != "")
        {
            
            let thisUser =  self.msgItem.user
            //self.avatarImage.removeFromSuperview()
            
            let imageName = thisUser.avatar != "" ? thisUser.avatar : "noAvatar.png"
            self.avatarImage = UIImageView(image:UIImage(named:imageName))
            
            self.avatarImage.layer.cornerRadius = 9.0
            self.avatarImage.layer.masksToBounds = true
            self.avatarImage.layer.borderColor = UIColor(white:0.0 ,alpha:0.2).cgColor
            self.avatarImage.layer.borderWidth = 1.0
            
            //别人头像，在左边，我的头像在右边
            let avatarX =  (type == ChatType.someone) ? 2 : self.frame.size.width - 52
            
            //头像居于消息顶部
            let avatarY:CGFloat =  0
            //set the frame correctly
            self.avatarImage.frame = CGRect(x: avatarX, y: avatarY, width: 50, height: 50)
            self.addSubview(self.avatarImage)
            
            //如果只有一行消息（消息框高度不大于头像）则将消息框居中于头像位置
            let delta =  (50 - (self.msgItem.insets.top
                + self.msgItem.insets.bottom + self.msgItem.view.frame.size.height))/2
            if (delta > 0) {
                y = delta
            }
            if (type == ChatType.someone) {
                x += 54
            }
            if (type == ChatType.mine) {
                x -= 54
            }
        }
        
        self.customView = self.msgItem.view
        self.customView.frame = CGRect(x: x + self.msgItem.insets.left,
                                       y: y + self.msgItem.insets.top, width: width, height: height)
        
        self.addSubview(self.customView)
        
        //如果是别人的消息，在左边，如果是我输入的消息，在右边
        if (type == ChatType.someone)
        {
            self.bubbleImage.image = UIImage(named:("yoububble.png"))!
                .stretchableImage(withLeftCapWidth: 21,topCapHeight:25)
            
        }
        else {
            self.bubbleImage.image = UIImage(named:"mebubble.png")!
                .stretchableImage(withLeftCapWidth: 15, topCapHeight:25)
        }
        self.bubbleImage.frame = CGRect(x: x, y: y,
                                        width: width + self.msgItem.insets.left + self.msgItem.insets.right,
                                        height: height + self.msgItem.insets.top + self.msgItem.insets.bottom)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
