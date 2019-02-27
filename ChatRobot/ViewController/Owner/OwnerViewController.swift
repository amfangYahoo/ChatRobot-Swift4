//
//  OwnerViewController.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/19.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation

class OwnerViewController: UIViewController {
    
    @IBOutlet var wxImageView: UIImageView!
    @IBOutlet var zfbImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wxImageView.isUserInteractionEnabled = true
        zfbImageView.isUserInteractionEnabled = true
        
        //长按下载二维码图片到相册
        let longPressWX = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressClickWX))
        let longPressZFB = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressClickZFB))
        //长按识别二维码
        //let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(QRLongPress(gesture:)))
        longPressWX.minimumPressDuration = 1
        longPressZFB.minimumPressDuration = 1
        wxImageView.addGestureRecognizer(longPressWX)
        zfbImageView.addGestureRecognizer(longPressZFB)
    }
    
    //长按保存图片
    @objc func longPressClickWX() {

        let alert = UIAlertController(title: "请选择", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "保存到相册", style: .default) { [weak self](_) in
            //保存到相册方法UIImageWriteToSavedPhotosAlbum
            UIImageWriteToSavedPhotosAlbum(self!.wxImageView.image!, self, #selector(self?.image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        //UIImageWriteToSavedPhotosAlbum(self!.wxImageView.image!, self, #selector(), nil)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func longPressClickZFB() {
        
        let alert = UIAlertController(title: "请选择", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "保存到相册", style: .default) { [weak self](_) in
            //保存到相册方法UIImageWriteToSavedPhotosAlbum
            UIImageWriteToSavedPhotosAlbum(self!.zfbImageView.image!, self, #selector(self?.image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        //UIImageWriteToSavedPhotosAlbum(self!.wxImageView.image!, self, #selector(), nil)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    //保存二维码图片
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "保存成功", message: "请打开微信/支付宝识别二维码打赏", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "保存失败", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    //长按二维码识别，但识别后无法打开微信/支付宝，所以改为下载
    @objc func QRLongPress(gesture: UILongPressGestureRecognizer) {
        
        if (gesture.state == UIGestureRecognizer.State.began) {
            
            print("QRLongPress - begin")
            //1.初始化扫描仪，设置设别类型和识别质量
            let options = ["IDetectorAccuracy" : CIDetectorAccuracyHigh]
            let detector: CIDetector = CIDetector.init(ofType: "CIDetectorTypeQRCode", context: nil, options: options)!
            //2.扫描获取的特征组
            let features = detector.features(in: CIImage.init(cgImage: (self.wxImageView.image?.cgImage)!))
            //3.获取扫描结果
            let feature = features[0] as! CIQRCodeFeature
            let scannedResult = feature.messageString
            //4.获取之后的操作
            print(scannedResult!)
            openUrl(urlString: scannedResult!)
            
        } else if (gesture.state == UIGestureRecognizer.State.ended) {
            
        }
    }
    
    func openUrl(urlString: String) {
        guard let productLink: String = urlString else {
            return
        }
        
        print("productLink: \(productLink)")
        
        let url = NSURL(string: productLink)
        
        // Swift
        let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly : false]
        UIApplication.shared.open(url as! URL, options: options, completionHandler: nil)
    }
}
