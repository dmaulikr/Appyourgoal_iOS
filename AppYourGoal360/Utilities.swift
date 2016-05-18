//
//  Utilities.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/14/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD

class Utilities {

    // Evalutation
    class func isStringValidEmailAddress(email: String) -> Bool {
        let regex: String = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        let predicate: NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluateWithObject(email)
    }

    // Alerts
    class func showUIAlertViewWithMessage(message: String) {
        let applicationName: String = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        let alertView: UIAlertView = UIAlertView(title: applicationName, message: "\(message)", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    // PKHUD
    class func showPKHUDProgressView() {
        SVProgressHUD.setFont(UIFont(name: "DIN", size: 15.0))
        SVProgressHUD.show()
    }
    
    class func hidePKHUDView() {
        SVProgressHUD.dismiss()
    }
    
    class func hidePKHUDViewWithError(error: String?) {
        if (error != nil) {
            SVProgressHUD.showErrorWithStatus(error!)
        }
        else {
            SVProgressHUD.showErrorWithStatus("")
        }
    }
    
    class func hidePKHUDViewWithSuccess(status: String) {
        SVProgressHUD.showSuccessWithStatus(status)
    }
    
    class func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags = NSCalendarUnit.Minute.union(NSCalendarUnit.Hour).union(NSCalendarUnit.Day).union(NSCalendarUnit.WeekOfYear).union(NSCalendarUnit.Month).union(NSCalendarUnit.Year).union(NSCalendarUnit.Second)
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options: [])
        if (components.year >= 2) {
            return "\(components.year) years ago"
        } else if (components.year >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month >= 2) {
            return "\(components.month) months ago"
        } else if (components.month >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear >= 2) {
            return "\(components.weekOfYear) weeks ago"
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day >= 2) {
            return "\(components.day) days ago"
        } else if (components.day >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour >= 2) {
            return "\(components.hour) hours ago"
        } else if (components.hour >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute >= 2) {
            return "\(components.minute) minutes ago"
        } else if (components.minute >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second >= 3) {
            return "\(components.second) seconds ago"
        } else {
            return "Just now"
        }
    }
    
    class func imageResize(imageObj: UIImage, sizeChange: CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}