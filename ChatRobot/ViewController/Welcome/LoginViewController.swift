//
//  LoginViewController.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/22.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation

class LoginViewController: BookletBaseController {
    @IBOutlet var nameEditText: UITextField!
    @IBAction func loginBtnClick(_ sender: Any) {
        
        if (nameEditText.text!.count > 0) {
            //save
            //let hasLocalUserName = UserDefaults.standard.object(forKey: "localUserName")
            UserDefaults.standard.set(nameEditText.text, forKey: "localUserName")
            //跳转到主界面
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainTabBarController
            //传值
            //mainVC.Username = nameEditText.text!
            self.present(mainVC, animated: true, completion: nil)
        }else{
            let ac = UIAlertController(title: "昵称为空", message: "请输入昵称", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            return
        }
        
    }
    
    override func viewDidLoad() {
        //
    }
}
