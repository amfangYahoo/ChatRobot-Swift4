//
//  APIManager.swift
//  ResumeARStarter
//
//  Created by Jacky Fang on 2018/11/13.
//  Copyright © 2018 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

enum APIManager {
    
    case getMusicDownloadLinkFromBaidu(url: String, queryParameter: [String: String])
    case searchMusicFromBaidu(url: String, queryParameter: [String: String])
    case getAWSServerIPAddress(url: String)
    
}

//------------------------
//字典转Data
private func jsonToData(jsonDic:Dictionary<String, Any>) -> Data? {
    if (!JSONSerialization.isValidJSONObject(jsonDic)) {
        print("is not a valid json object")
        return nil
    }
    //利用自带的json库转换成Data
    //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
    let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [])
    //Data转换成String打印输出
    let str = String(data:data!, encoding: String.Encoding.utf8)
    //输出json字符串
    print("Json Str:\(str!)")
    return data
}

extension APIManager: TargetType {

    var baseURL: URL {
        switch self {

            case .getMusicDownloadLinkFromBaidu(url: let url, _):
                return URL(string: url)!
            case .searchMusicFromBaidu(url: let url, _):
                    return URL(string: url)!
 
            case .getAWSServerIPAddress(url: let url):
                return URL(string: url)!
        }
    }
    
    var path: String {
        switch self {

            case .getMusicDownloadLinkFromBaidu(_, _):
                return "/v1/restserver/ting"
            case .searchMusicFromBaidu(_, _):
                    return "/v1/restserver/ting"
 
            case .getAWSServerIPAddress(_):
                return ""
        }
    }
    
    var method: Moya.Method {
        switch self {

            case .getMusicDownloadLinkFromBaidu(_, _):
                return .get
            case .searchMusicFromBaidu(_, _):
                return .get
 
            case .getAWSServerIPAddress(_):
                return .get
        }
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {

            case .getMusicDownloadLinkFromBaidu(_, queryParameter: let queryParameter):
                return .requestParameters(parameters: queryParameter, encoding: URLEncoding.default)//参数放在请求的url中
            case .searchMusicFromBaidu(_, queryParameter: let queryParameter):
                return .requestParameters(parameters: queryParameter, encoding: URLEncoding.default)//参数放在请求的url中
            case .getAWSServerIPAddress(_):
                return .requestPlain

        }
    }
    
    var headers: [String : String]? {
        
        switch self {
            case .getMusicDownloadLinkFromBaidu(_, _):
                return ["User-Agent": "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:0.9.4)"]
            case .searchMusicFromBaidu(_, _):
                return ["Content-Type": "application/json"]
            case .getAWSServerIPAddress(_):
                return ["Content-Type": "application/json"]
        }
    }
    
}
