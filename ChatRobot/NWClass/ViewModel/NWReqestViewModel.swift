//
//  NWReqestViewModel.swift
//  ResumeARStarter
//
//  Created by Jacky Fang on 2018/11/13.
//  Copyright © 2018 Sanjeev Ghimire. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import RxCocoa

class NWRequestViewModel {
    
    private let provider = MoyaProvider<APIManager>()
    let disposeBag = DisposeBag()
    //由于 Variable 在之后版本中将被废弃，建议使用 Varible 的地方都改用下面介绍的 BehaviorRelay 作为替代
    //Variables 本身没有 subscribe() 方法，但是所有 Subjects 都有一个 asObservable() 方法。我们可以使用这个方法返回这个 Variable 的 Observable 类型，拿到这个 Observable 类型我们就能订阅它了。
    //使用下面的方法可以保存获取解析结果供后面使用
    var dataSourceAsString = BehaviorRelay<String>(value: "")
    /*
    var dataSourceMapObject = BehaviorRelay<[ResumearModelMapHandyJSON_sub]>(value:[])
    */
    var musicDataSourceMapHandy = BehaviorRelay<[MusicObjModel_sub]>(value: [])
    var musicResultList: [MusicObjModel_sub] = []
 
    var networkError = BehaviorRelay(value: Error.self)
}

//MARK: -- 网络
extension  NWRequestViewModel {
    /*
    //网络请求-- Cloudant["classificationId":"SteveMartinelli_2096165720"]
    func findDocumentsBySelectorFromCloudant(url: String, database: String, parameter: Dictionary<String, Any>){
        //MoyaProvider针对APIService的mainClassList提交网络请求
        //返回结果使用MainClassModelMapObject进行封装
        //网络获取Cloudant按照selector(_find)查询结果
        print("NWRequestViewModel.findDocumentsBySelectorFromCloudant -- start")
        provider.rx.request(.findDocumentsBySelectorFromCloudant(url: url, database: database, parameter: parameter))
            .asObservable()
            .mapHandyJsonModel(ResumearModelMapHandyJSON.self)
            .subscribe({ [unowned self] (event) in
                
                switch event {
                case let  .next(classModel):
                    
                    print("HandyJSON -- 加载网络成功")
                    //网络请求结果使用classModel封装
                    print("classModel.rows: \(classModel.docs)")
//                    let timeDiff = self.getTimeDifferentWith(date: currentTime)
//                    print("\(timeDiff)")
                    self.dataSourceMapObject.accept(classModel.docs!)
                    print("NWRequestViewModel.findDocumentsBySelectorFromCloudant -- end")
                    
                case let .error( error):
                    print("error:", error)
                    self.networkError.accept(error as! Error.Protocol)
                case .completed: break
                }
            }).disposed(by: self.disposeBag)
    }
    */
    /*
    //网络请求-- SwiftyJSON
    func searchMusicFromBaidu(url: String, songName: String) {
        //MoyaProvider针对APIService的mainClassList提交网络请求
        //返回结果使用MainClassModelMapObject进行封装
        //网络获取Cloudant按照selector(_find)查询结果
        
        provider.request(.updateDocumentDataFromCloudant(url: url, database: database, docData: docData)) { (result) in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
 
        var musicInfo: [MusicObjModel_sub] = []
        provider.rx.request(.searchMusicFromBaidu(url: url, songName: songName))
            .asObservable()
            .mapHandyJsonModel(MusicObjModel.self)
            .subscribe({ [unowned self] (event) in
                print("event: \(event)")
                switch event {
                    case let .next(classModel):
                    
                        print("HandyJSON -- 加载网络成功")
                        //网络请求结果使用classModel封装
                        print("classModel.data: \(classModel.order)")
                        //self.musicDataSourceMapHandy.accept(classModel.song)
                        self.musicResultList = classModel.song
                        //musicInfo = classModel.song
                    
                    case let .error( error):
                        print("error:", error)
                        self.networkError.accept(error as! Error.Protocol)
                    case .completed: break
                }
            }).disposed(by: self.disposeBag)
 
    }
    */
    //网络请求 -- 返回字符串
    func getAWSServerIPAddress(url: String) -> String {
        var retStr:String = ""
        provider.rx.request(.getAWSServerIPAddress(url: url))
            .asObservable()
            .subscribe({ [unowned self] (event) in
                print(event)
                switch event {
                    case let .next(response):
                        
                        print("HandyJSON -- 加载网络成功")
                        //网络请求结果使用classModel封装
                        //print("response的类型：\(type(of: response))")
                        print("classModel.rows: \(response.data)")
                        if(response.statusCode == 200){
                            print("数据增加成功！")
                            retStr = response.statusCode.description
                            print("retStr: \(retStr)")
                            self.dataSourceAsString.accept(retStr)
                        }
                    
                    case let .error( error):
                        print("error:", error)
                        self.networkError.accept(error as! Error.Protocol)
                    case .completed: break
                }
                
            }).disposed(by: self.disposeBag)
        print("retStr:-1 \(retStr)")
        return retStr
    }
}
