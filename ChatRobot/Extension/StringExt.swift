//
//  StringExt.swift
//  qqchat
//
//  Created by zhouxiaobo on 15/1/27.
//  Copyright (c) 2015年 zhouxiaobo. All rights reserved.
//

import UIKit

extension String{
    func getStringCGSize(fnt:UIFont) -> CGSize{
        
        //根据字体和字符串内容获取这段文字的大小
        return NSString(string: self).size(withAttributes: [NSAttributedString.Key.font: fnt])
    }
}
