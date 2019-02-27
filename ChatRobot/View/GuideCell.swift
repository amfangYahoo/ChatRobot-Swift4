//
//  GuideCell.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/21.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation
import UIKit

// 点击Guide页的button
public let GuideViewControllerDidFinish = "GuideViewControllerDidFinish"

class GuideCell: UICollectionViewCell {
    private let newImageView = UIImageView(frame: ScreenBounds)
    private let nextButton = UIButton(frame: CGRect(x: (ScreenWidth - 100) * 0.5, y: ScreenHeight - 110, width: 100, height: 33))
    
    var newImage: UIImage? {
        didSet {
            newImageView.image = newImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        newImageView.contentMode = .scaleAspectFill
        contentView.addSubview(newImageView)
        
        nextButton.setBackgroundImage(UIImage(named: "icon_next"), for: .normal)
        nextButton.addTarget(self, action: #selector(GuideCell.nextButtonClick), for: UIControl.Event.touchUpInside)
        nextButton.isHidden = true
        contentView.addSubview(nextButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNextButtonHidden(hidden: Bool) {
        nextButton.isHidden = hidden
    }
    
    // GuideViewControllerDidFinish 还有一处在app.delegate中 进入到主界面中使用的
    @objc func nextButtonClick() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GuideViewControllerDidFinish), object: nil)
    }
}
