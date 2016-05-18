//
//  AppDelegate.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/14/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var tabBarController: UITabBarController!
    var loginNavigationController: UINavigationController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Setup Appearance
        let textAttributes: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "DINBold", size: 15.0)!, NSForegroundColorAttributeName: Constants.kActionBlueColor]
        UINavigationBar.appearance().tintColor = Constants.kActionBlueColor
        UIBarButtonItem.appearance().setTitleTextAttributes(textAttributes, forState: UIControlState.Normal)
        
        // Setup Parse
        Parse.setApplicationId("ujkACB1ufkvRRaSlxj1NW2H4g2Y1hPonMKFNmNLw", clientKey:"ZDF2Hi6YwS81tw9U8gagEeMdMFPwb6c39wZTUC24")
        
        // Setup Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Setup IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        // Setup Push Notitications 
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Setup ViewControllers
        let mainStoryboard: UIStoryboard = UIStoryboard(name:Constants.kMainStoryboard, bundle:nil)
        self.tabBarController = mainStoryboard.instantiateViewControllerWithIdentifier(Constants.kTabBarController) as! UITabBarController
        self.loginNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier(Constants.kLoginNavController) as! UINavigationController
        
        // Check Login Status
        if (Settings.userLoggedIn()) {
            self.window?.rootViewController = self.tabBarController
        }
        else {
            self.window?.rootViewController = self.loginNavigationController
        }
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        }
        else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }

    func userLoggedIn() {
        if (self.window?.rootViewController?.presentedViewController != nil) {
            self.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            let viewToInsert = self.tabBarController.view
            let viewBelow = self.window?.rootViewController?.view
            self.window?.insertSubview(viewToInsert, belowSubview: viewBelow!)
            UIView.transitionWithView(viewBelow!, duration: 0.25, options: UIViewAnimationOptions.CurveEaseIn,
                animations: { () -> Void in
                    viewBelow!.frame = CGRectMake(0, viewBelow!.frame.size.height, viewBelow!.frame.size.width, viewBelow!.frame.size.height)
                },
                completion: { (finshed: Bool) -> Void in
                    self.window?.rootViewController? = self.tabBarController;
                }
            )
        }
    }
    
    func userLoggedOut() {
        self.window?.rootViewController?.presentViewController(self.loginNavigationController, animated: true, completion:nil)
    }

}

