//
//  MusicObjModel.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/15.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation
import HandyJSON
//SwiftyJSON 解析失败，使用HandyJSON解析
struct MusicObjModel: HandyJSON {
    
    var order: String?
    var song: [MusicObjModel_sub]!
    
}

struct MusicObjModel_sub: HandyJSON {
    
    var songname: String?
    var artistname: String?
    var songid: String?
}
/*
class MusicObjModel: ALSwiftyJSONAble {
    /*
     @SerializedName("songname")
     private String songname;
     @SerializedName("artistname")
     private String artistname;
     @SerializedName("songid")
    */
    var songname: String?
    var artistname: String?
    var songid: String?
    
    required init?(jsonData:JSON){
        self.songname = jsonData["songname"].string
        self.artistname = jsonData["artistname"].string
        self.songid = jsonData["songid"].string
    }
}
*/
