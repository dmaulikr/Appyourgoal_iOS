//
//  TabBarController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/21/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    let tabBarFont: UIFont! = UIFont(name: "DINBold", size: 14.0)
    var lastViewControllerIndex: NSInteger?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NetworkController.sharedInstance.getPrizePreviewWithResponseBlock { (success, response) -> Void in
            if success {
                let responseDictionary: Dictionary<String, AnyObject> = response as! Dictionary<String, AnyObject>
                
                let prizePreviewViewController: PrizePreviewViewController = (self.storyboard?.instantiateViewControllerWithIdentifier(Constants.kPrizePreviewViewController)) as! PrizePreviewViewController
                prizePreviewViewController.prizeDictionary = responseDictionary
                prizePreviewViewController.providesPresentationContextTransitionStyle = true
                prizePreviewViewController.definesPresentationContext = true
                prizePreviewViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(prizePreviewViewController, animated: true, completion: nil)
                })
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Private

    func initialSetup() {
        self.delegate = self
        self.selectedViewController = self.viewControllers?[1]
        lastViewControllerIndex = 1
        
        let defaultAttributes: [String: AnyObject]? = [NSFontAttributeName: self.tabBarFont, NSForegroundColorAttributeName: Constants.kDefaultButtonTextColor]
        let selectedAttributes: [String: AnyObject]? = [NSFontAttributeName: self.tabBarFont, NSForegroundColorAttributeName: Constants.kSelectedButtonTextColor]
        
        UITabBarItem.appearance().setTitleTextAttributes(defaultAttributes, forState: UIControlState.Normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, forState: UIControlState.Selected)
        for (_, element) in (self.tabBar.items?.enumerate())! {
            element.titlePositionAdjustment = UIOffsetMake(0, -15)
        }
        
        UITabBar.appearance().barTintColor = Constants.kLoginButtonDefaultColor
        UITabBar.appearance().selectionIndicatorImage = self.makeImageWithColorAndSize(Constants.kLoginButtonHighlightedColor, size: CGSizeMake(tabBar.frame.width/CGFloat(tabBar.items!.count), tabBar.frame.height))
        
        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithRenderingMode(.AlwaysOriginal)
            }
        }
    }
    
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        lastViewControllerIndex = self.selectedIndex
        if (viewController.restorationIdentifier == Constants.kUploadNavigationController) {
            let uploadNavigationController: NavigationController = self.storyboard?.instantiateViewControllerWithIdentifier(Constants.kUploadNavigationController2) as! NavigationController
            self.selectedViewController?.presentViewController(uploadNavigationController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        //let item: UITabBarItem = tabBarController.tabBar.items![tabBarController.selectedIndex]
        
        let tabWidth:CGFloat = UIScreen.mainScreen().bounds.width / CGFloat(tabBar.items!.count)
        let tabIndex:CGFloat = CGFloat(tabBarController.selectedIndex)
        let bgColor:UIColor = Constants.kLoginButtonHighlightedColor
        let bgView = UIView(frame: CGRectMake(tabWidth * tabIndex, 0, tabWidth, 49))
        bgView.backgroundColor = bgColor
        tabBar.insertSubview(bgView, atIndex: 0)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    
    func goBackToPreviousTab() {
        self.selectedViewController = self.viewControllers?[lastViewControllerIndex!]
    }

}
