//
//  WelcomeViewController.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/2/21.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//

import Foundation

class WelcomeViewController: UIViewController, UIPageViewControllerDataSource {
    
    // 定义PageViewController
    private var pageViewController: UIPageViewController?
    // 准备2页模版
    private var pageCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useDefaultPages()
    }
    
    private func useDefaultPages() {
        createPageViewController()
        setupPageControl()
    }
    
    private func createPageViewController() {
        guard let pageController = self.storyboard?.instantiateViewController(withIdentifier: "welcome") as? UIPageViewController else {
            print("createPageViewController - pageController is nil")
            return
        }
        print("createPageViewController")
        pageController.dataSource = self
        if self.pageCount > 0 {
            //创建第一个page
            guard let firstController = getItemController(itemIndex: 0) else {
                return
            }
            let startingViewControllers = [firstController]
            // UIPageViewControllerNavigationDirectionReverse
            
            //设定默认第一个page
            pageController.setViewControllers(startingViewControllers, direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        guard let pageViewController = pageViewController else {
            return
        }
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height)
        // pageViewController.view.backgroundColor = UIColor.green
        addChild(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    private func setupPageControl() {
        guard let subviews = pageViewController?.view.subviews else {
            return
        }
        print("setupPageControl")
        let pageControls = subviews.filter { $0 is UIPageControl }
        guard let pageControl = pageControls.first as? UIPageControl else {
            return
        }
        // pageControl.backgroundColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor(red: 0.97, green: 0.84, blue: 0.88, alpha: 1.0)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.87, green: 0.21, blue: 0.44, alpha: 1.0)
        self.view.addSubview(pageControl)
    }
    
    //根据不同模版创建不同page
    private func getItemController(itemIndex: Int) -> BookletBaseController? {
        
        print("getItemController: " + String(itemIndex))
        if itemIndex < pageCount {
            switch itemIndex {
            case 0:
                print("CoverController")
                guard let pageItemController = self.storyboard?.instantiateViewController(withIdentifier: "CoverController") as? CoverViewController else {
                    return nil
                }
                pageItemController.itemIndex = itemIndex
                
                return pageItemController
                
            case 1:
                print("guide")
                guard let pageItemController = self.storyboard?.instantiateViewController(withIdentifier: "GuideController") as? GuideViewController else {
                    return nil
                }
                pageItemController.itemIndex = itemIndex
//                pageItemController.titleString = pages[itemIndex].title
//                pageItemController.statementString = pages[itemIndex].description
//                pageItemController.linkString = pages[itemIndex].link
//                pageItemController.image = getBookletImage(PageTest: pages[itemIndex])
                
                return pageItemController
                
            default:
                guard let pageItemController = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as? LoginViewController else {
                    return nil
                }
                pageItemController.itemIndex = itemIndex
//                pageItemController.titleString = pages[itemIndex].title
//                pageItemController.subTitleString = pages[itemIndex].subtitle
//                pageItemController.image = getBookletImage(PageTest: pages[itemIndex])
                
                return pageItemController
            }
        }
        
        return nil
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    // PageViewController默认方法
    //获取前一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let itemController = viewController as? BookletBaseController else {
            return nil
        }
        print("pageViewController - viewControllerBefore: " + String(itemController.itemIndex))
        if itemController.itemIndex > 0 {
            return getItemController(itemIndex: itemController.itemIndex-1)
        }
        return nil
    }
    
    //获取后一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let itemController = viewController as? BookletBaseController else {
            return nil
        }
        print("pageViewController - viewControllerAfter: " + String(itemController.itemIndex))
        if itemController.itemIndex + 1 < pageCount {
            return getItemController(itemIndex: itemController.itemIndex+1)
        }
        return nil
    }
    
    // MARK: - Page Indicator
    // PageViewController默认方法
    //返回页面个数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageCount
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
