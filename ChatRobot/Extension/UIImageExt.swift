//
//  UIImageExt.swift
//  qqchat
//
//  Created by zhouxiaobo on 15/1/27.
//  Copyright (c) 2015年 zhouxiaobo. All rights reserved.
//

import UIKit

extension UIImage {
    
    //根据图片名称设定拉升图片
    class func resizableImage(image:UIImage) -> UIImage {        
        let top:CGFloat = image.size.height * 0.6
        let bottom:CGFloat = image.size.height * 0.5
        let left:CGFloat = image.size.height * 0.5
        let right:CGFloat = image.size.height * 0.5
        
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right), resizingMode: UIImage.ResizingMode.stretch)
    }
}
