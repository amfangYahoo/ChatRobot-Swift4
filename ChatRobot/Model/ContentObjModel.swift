//
//  ContentObjModel.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/1/12.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ContentObjModel {
    var username: String?
    var userid: String?
    var content: String?
    //musicGetRequest = 1;
    var musicGetRequest: Bool?
    
    init(jsonData: JSON) {
        username    = jsonData["username"].stringValue
        userid = jsonData["userid"].stringValue
        content  = jsonData["content"].stringValue
        musicGetRequest = jsonData["musicGetRequest"].intValue == 1 ? true : false
    }
}
