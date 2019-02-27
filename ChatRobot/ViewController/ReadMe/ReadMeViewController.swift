//
//  ReadMeViewController.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/19.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation

class ReadMeViewController: UIViewController {
    
    @IBOutlet var linkBtn: UIButton!
    
    @IBAction func linkBtnClick(_ sender: Any) {
        
        guard let productLink: String = Constant.Variables.urlAWS else {
            return
        }
        
        let url = NSURL(string: productLink)
        
        // Swift
        let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly : false]
        UIApplication.shared.open(url as! URL, options: options, completionHandler: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let productLink: String = Constant.Variables.urlAWS else {
            return
        }
        
        linkBtn.setTitle("Firefox在线：" + productLink, for: .normal)
    }
}
