//
//  Constants.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/14/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit
import Foundation

struct Constants {
    
    // Colors
    static let kLoginButtonDefaultColor: UIColor = UIColor(red: 32.0/256.0, green: 36.0/256.0, blue: 38.0/256.0, alpha:1.0)
    static let kLoginButtonHighlightedColor: UIColor = UIColor(red: 26.0/256.0, green: 28.0/256.0, blue: 30.0/256.0, alpha:1.0)
    
    static let kActionBlueColor: UIColor = UIColor(red: 126.0/256.0, green: 151.0/256.0, blue: 202.0/256.0, alpha:1.0)
    static let kDefaultButtonTextColor: UIColor = UIColor(red: 201.0/256.0, green: 198.0/256.0, blue: 199.0/256.0, alpha:1.0)
    static let kGoldenButtonTextColor: UIColor = UIColor(red: 241.0/256.0, green: 234.0/256.0, blue: 101.0/256.0, alpha:1.0)
    static let kSelectedButtonTextColor: UIColor = UIColor.whiteColor()
    
    
    // Storyboards
    static let kMainStoryboard = "Main"
    
    
    // View Controllers
    static let kLoginNavController = "LoginNavigationController"
    static let kIntroViewController = "IntroViewController"
    static let kLoginViewController = "LoginViewController"
    static let kSignupViewController = "SignupViewController"
    
    static let kPageViewController = "PageViewController"
    static let kPageContentViewController = "PageContentViewController"
    
    static let kTabBarController = "TabBarController"
    static let kPrizePreviewViewController = "PrizePreviewViewController"
    static let kGoalsNavigationController = "GoalsNavigationController"
    static let kGoalsViewController = "GoalsViewController"
    static let kPodiumNavigationController = "PodiumNavigationController"
    static let kPodiumViewController = "PodiumViewController"
    static let kUploadNavigationController = "UploadNavigationController"
    static let kUploadNavigationController2 = "UploadNavigationController2"
    static let kUploadViewController = "UploadViewController"
    static let kProfileViewController = "ProfileViewController"
    static let kGoalViewController = "GoalViewController"
    static let kVideoViewController = "VideoViewController"
    
    
    // Segues
    static let kIntroViewControllerToLoginViewControllerSegue = "IntroViewControllerToLoginViewControllerSegue"
    static let kIntroViewControllerToSignupViewControllerSegue = "IntroViewControllerToSignupViewControllerSegue"
    static let kLoginViewControllerToSignupViewControllerSegue = "LoginViewControllerToSignupViewControllerSegue"
    
    static let kPodiumViewControllerToProfileViewControllerSegue = "PodiumViewControllerToProfileViewControllerSegue"
    static let kPodiumViewControllerToGoalViewControllerSegue = "PodiumViewControllerToGoalViewControllerSegue"
    static let kPodiumViewControllerToNotificationsViewControllerSegue = "PodiumViewControllerToNotificationsViewControllerSegue"
    
    static let kGoalsViewControllerToProfileViewControllerSegue = "GoalsViewControllerToProfileViewControllerSegue"
    static let kGoalsViewControllerToGoalViewControllerSegue = "GoalsViewControllerToGoalViewControllerSegue"
    static let kGoalsViewControllerToNotificationsViewControllerSegue = "GoalsViewControllerToNotificationsViewControllerSegue"
    
    static let kProfileViewControllerToProfileEditViewControllerSegue = "ProfileViewControllerToProfileEditViewControllerSegue"
    static let kProfileViewControllerToGoalViewControllerSegue = "ProfileViewControllerToGoalViewControllerSegue"
    
    static let kUploadViewControllerToVideoViewControllerSegue = "UploadViewControllerToVideoViewControllerSegue"
    
    
    // Table View Cells
    static let kGoalsTableViewCell = "GoalsTableViewCell"
    static let kProfileTableViewCell = "ProfileTableViewCell"
    static let kCommentTableViewCell = "CommentTableViewCell"
    static let kNotificationTableViewCell = "NotificationTableViewCell"
}