//
//  SyncController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 10/19/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit

class SyncController: NSObject {
    static let sharedInstance = SyncController()
    
    internal typealias successBlock = (success: Bool) -> Void
    internal typealias responseBlock = (success: Bool, response: AnyObject) -> Void
    
    // MARK: - Syncing
    
    internal func syncEverythingWithSuccessBlock(block: successBlock) {
        var overalSuccess: Bool = true
        let syncGroup: dispatch_group_t = dispatch_group_create()
        
        // Delete everything before getting the new stuff in.
        self.deleteEverything()
        
        dispatch_group_enter(syncGroup)
        NetworkController.sharedInstance.getUserDetailsWithResponseBlock(nil) { (success, response) -> Void in
            if success {
                // Successful
                print("Success fetching User Profile")
                
                // Save to Settings
                Settings.setUserProfile(response as! Dictionary<String, AnyObject>)
                
                // Leave
                dispatch_group_leave(syncGroup)
            }
            else {
                print("Error fetching User Profile!")
                print("Error (if readable): \(response)")
                overalSuccess = false
                dispatch_group_leave(syncGroup)
            }
        }
        
        // ---- All Requests finished
        dispatch_group_notify(syncGroup, dispatch_get_main_queue()) { () -> Void in
            block(success: overalSuccess)
        }
    }
    
    internal func deleteEverything() {
        Settings.deleteUserProfile()
    }
}
