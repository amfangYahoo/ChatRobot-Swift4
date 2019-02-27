//
//  MusicInfoObjModel.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/16.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation
import HandyJSON
//SwiftyJSON 解析失败，使用HandyJSON解析
struct MusicInfoObjModel: HandyJSON {
    
    var bitrate: MusicInfoObjModel_sub!
    
}

struct MusicInfoObjModel_sub: HandyJSON {
    
    var file_link: String?
}
