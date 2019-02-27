//
//  GuideViewControllerExample.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/22.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation
import UIKit

public let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
public let ScreenBounds: CGRect = UIScreen.main.bounds

class GuideViewControllerExample: UIViewController {
    
    private var collectView: UICollectionView?
    private var imageNames = ["guide_40_1", "guide_40_2", "guide_40_3", "guide_40_4"]
    private let cellIdentifier = "GuideCell"
    private var isHiddenNextButton = true
    private var pageController = UIPageControl(frame: CGRect(x: 0, y: ScreenHeight - 50, width: ScreenWidth, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildCollectionView()
        buildPageController()
    }
    
    // MARK: - Build UI
    private func buildCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = ScreenBounds.size
        layout.scrollDirection = .horizontal
        
        collectView = UICollectionView(frame: ScreenBounds, collectionViewLayout: layout)
        collectView?.delegate = self
        collectView?.dataSource = self
        collectView?.showsVerticalScrollIndicator = false
        collectView?.showsHorizontalScrollIndicator = false
        collectView?.isPagingEnabled = true
        collectView?.bounces = false
        collectView?.register(GuideCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.addSubview(collectView!)
    }
    
    func buildPageController() {
        pageController.numberOfPages = imageNames.count
        pageController.currentPage = 0
        view.addSubview(pageController)
    }
    
}

extension GuideViewControllerExample: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GuideCell
        cell.newImage = UIImage(named: imageNames[indexPath.row])
        if indexPath.row != imageNames.count - 1 { // 3
            cell.setNextButtonHidden(hidden: true) // 如果不是第三张就隐藏button
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == ScreenWidth * CGFloat(imageNames.count - 1) {
            let cell = collectView!.cellForItem(at: NSIndexPath(row: imageNames.count - 1, section: 0) as IndexPath) as! GuideCell
            cell.setNextButtonHidden(hidden: false)
            isHiddenNextButton = false
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x != ScreenWidth * CGFloat(imageNames.count - 1) && !isHiddenNextButton && scrollView.contentOffset.x > ScreenWidth * CGFloat(imageNames.count - 2) {
            let cell = collectView!.cellForItem(at: NSIndexPath(row: imageNames.count - 1, section: 0) as IndexPath) as! GuideCell
            cell.setNextButtonHidden(hidden: true)
            isHiddenNextButton = true
        }
        pageController.currentPage = Int(scrollView.contentOffset.x / ScreenWidth + 0.5)
    }
}
