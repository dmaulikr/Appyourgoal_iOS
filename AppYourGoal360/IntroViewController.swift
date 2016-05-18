//
//  ViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/14/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController?
    var contentViewControllers: [PageContentViewController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func initialSetup() {
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.kPageViewController) as? UIPageViewController
        self.pageViewController?.dataSource = self
        
        let pageContentViewController1: PageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.kPageContentViewController) as! PageContentViewController
        pageContentViewController1.stringMessage = "YOU PLAY\nYOU SHARE\nYOU WIN"
        pageContentViewController1.pageIndex = 0
        let pageContentViewController2: PageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.kPageContentViewController) as! PageContentViewController
        pageContentViewController2.stringMessage = "Share the videos of the goals you scored (or by the youtube link) with a large community of people crazy about football like you. Every week the most voted goal will win a prize. Here there are no jury of experts, the best goal of the week will be determined exclusively by AppyourGoal’s users!"
        pageContentViewController2.pageIndex = 1
//        let pageContentViewController3: PageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.kPageContentViewController) as! PageContentViewController
//        pageContentViewController3.stringMessage = "MY BETTER\nIS BETTER\nTHAN YOUR\nBETTER. 3"
//        pageContentViewController3.pageIndex = 2
//        let pageContentViewController4: PageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.kPageContentViewController) as! PageContentViewController
//        pageContentViewController4.stringMessage = "MY BETTER\nIS BETTER\nTHAN YOUR\nBETTER. 4"
//        pageContentViewController4.pageIndex = 3
        
        self.contentViewControllers = [pageContentViewController1, pageContentViewController2]//, pageContentViewController3, pageContentViewController4]
        self.pageViewController!.setViewControllers([pageContentViewController1], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        self.pageViewController!.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-100)
        
        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = UIColor.whiteColor()
        pageControlAppearance.currentPageIndicatorTintColor = UIColor.redColor()
        pageControlAppearance.backgroundColor = UIColor.whiteColor()
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMoveToParentViewController(self)
    }
    
    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! PageContentViewController
        var index = viewController.pageIndex as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index--
        
        return self.contentViewControllers?[index]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! PageContentViewController
        var index = viewController.pageIndex as Int
        
        if ((index == NSNotFound)) {
            return nil
        }
        
        index++
        
        if (index == contentViewControllers?.count) {
            return nil
        }
        
        return self.contentViewControllers?[index]
    }

    // MARK: IBActions and Actions
    
    @IBAction func buttonLogIn(sender: UIButton) {
        let currentPageContentViewController: PageContentViewController = self.pageViewController!.viewControllers?.last as! PageContentViewController
        let currentIndex = self.contentViewControllers?.indexOf(currentPageContentViewController)
        if currentIndex == 0 {
            let pageContentViewController2 = self.contentViewControllers![1] as PageContentViewController
            self.pageViewController!.setViewControllers([pageContentViewController2], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            return
        }

        self.performSegueWithIdentifier(Constants.kIntroViewControllerToLoginViewControllerSegue, sender: nil)
    }
    
    @IBAction func buttonSignUp(sender: UIButton) {
        let currentPageContentViewController: PageContentViewController = self.pageViewController!.viewControllers?.last as! PageContentViewController
        let currentIndex = self.contentViewControllers?.indexOf(currentPageContentViewController)
        if currentIndex == 0 {
            let pageContentViewController2 = self.contentViewControllers![1] as PageContentViewController
            self.pageViewController!.setViewControllers([pageContentViewController2], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            return
        }
        
        self.performSegueWithIdentifier(Constants.kIntroViewControllerToSignupViewControllerSegue, sender: nil)
    }
    
}

