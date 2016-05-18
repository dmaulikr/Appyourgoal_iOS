//
//  Settings.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/14/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit
import Foundation

class Settings {
    
    // Keys
    static let kLoginDictionaryKey: String = "LoginDictionaryKey"
    static let kLoginWithFBDictionaryKey: String = "LoginWithFBDictionaryKey"
    static let kEmailDictionaryKey: String = "EmailDictionaryKey"
    static let kPasswordDictionaryKey: String = "PasswordDictionaryKey"
    static let kAccessTokenDictionaryKey: String = "AccessTokenDictionaryKey"
    
    static let kUserProfileKey: String = "UserProfileKey"
    static let kBackgroundColorKey: String = "BackgroundColorKey"
    static let kStripeColorKey: String = "StripeColorKey"
    
    // MARK: - Login
    
    static func setUserLoggedIn(loggedIn: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(loggedIn, forKey: kLoginDictionaryKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func setUserLoggedInWithFacebook(loggedIn: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(loggedIn, forKey: kLoginWithFBDictionaryKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func userLoggedIn() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(kLoginDictionaryKey)
    }
    
    static func userLoggedInWithFacebook() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(kLoginWithFBDictionaryKey)
    }
    
    // MARK: - Auth
    
    static func setEmail(email: String) {
        NSUserDefaults.standardUserDefaults().setObject(email, forKey: kEmailDictionaryKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func setPassword(password: String) {
        NSUserDefaults.standardUserDefaults().setObject(password, forKey: kPasswordDictionaryKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func email() -> String {
        if let email: String = NSUserDefaults.standardUserDefaults().stringForKey(kEmailDictionaryKey) {
            return email
        }
        
        return ""
    }
    
    static func password() -> String {
        if let password: String = NSUserDefaults.standardUserDefaults().stringForKey(kPasswordDictionaryKey) {
            return password
        }
        
        return ""
    }
    
    static func removeEmail() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kEmailDictionaryKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func removePassword() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kPasswordDictionaryKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func setAccessTokenDictionary(accessTokenDictionary: Dictionary<String, AnyObject>) {
        NSUserDefaults.standardUserDefaults().setObject(accessTokenDictionary, forKey: kAccessTokenDictionaryKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func accessTokenDictionary() -> Dictionary<String, AnyObject>? {
        if let accessTokenDictionary: Dictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(kAccessTokenDictionaryKey) {
            return accessTokenDictionary
        }
        
        return nil
    }
    
    static func accessToken() -> String {
        if let accessTokenDictionary: Dictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(kAccessTokenDictionaryKey) {
            if let accessToken: String = accessTokenDictionary["access_token"] as? String {
                return accessToken
            }
        }
        
        return ""
    }
    
    static func refreshToken() -> String {
        if let accessTokenDictionary: Dictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(kAccessTokenDictionaryKey) {
            if let refreshToken: String = accessTokenDictionary["refresh_token"] as? String {
                return refreshToken
            }
        }
        
        return ""
    }
    
    static func removeAccessTokenDictionary() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kAccessTokenDictionaryKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: - Profile
    
    static func setUserProfile(profileDictionary: Dictionary<String, AnyObject>) {
        let userProfileData: NSData = NSKeyedArchiver.archivedDataWithRootObject(profileDictionary)
        NSUserDefaults.standardUserDefaults().setObject(userProfileData, forKey: kUserProfileKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func userProfile() -> Dictionary<String, AnyObject>? {
        let userProfileData: NSData? = NSUserDefaults.standardUserDefaults().objectForKey(kUserProfileKey) as? NSData
        if (userProfileData != nil) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(userProfileData!) as? Dictionary<String, AnyObject>
        }
        return nil
    }
    
    static func deleteUserProfile() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserProfileKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func setBacgroundColor(color: UIColor) {
        let colorData: NSData = NSKeyedArchiver.archivedDataWithRootObject(color)
        NSUserDefaults.standardUserDefaults().setObject(colorData, forKey: kBackgroundColorKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func backgroundColor() -> UIColor {
        let colorData: NSData? = NSUserDefaults.standardUserDefaults().objectForKey(kBackgroundColorKey) as? NSData
        if (colorData != nil) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(colorData!) as! UIColor
        }
        return UIColor.blueColor()
    }
    
    static func setStripeColor(color: UIColor) {
        let colorData: NSData = NSKeyedArchiver.archivedDataWithRootObject(color)
        NSUserDefaults.standardUserDefaults().setObject(colorData, forKey: kStripeColorKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func stripeColor() -> UIColor {
        let colorData: NSData? = NSUserDefaults.standardUserDefaults().objectForKey(kStripeColorKey) as? NSData
        if (colorData != nil) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(colorData!) as! UIColor
        }
        return UIColor.yellowColor()
    }
}