//
//  NetworkController.swift
//  RFID
//
//  Created by Jovan Jovanovic on 9/9/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit
import Alamofire
import ReachabilitySwift

private let host: String! = "http://45.55.55.215/appyourgoal/api/"
private let imagesHost: String! = "http://45.55.55.215/appyourgoal/"

private let kTokenErrorMessage: String! = "An authentication error occurred. Pls, try logging out and in again."

class NetworkController: NSObject {
    static let sharedInstance = NetworkController()
    
    private var reachabilityStatus: Reachability.NetworkStatus!
    private var authenticatedOperationManager: Alamofire.Manager?
    
    internal typealias successBlock = (success: Bool) -> Void
    internal typealias responseBlock = (success: Bool, response: AnyObject) -> Void
    internal typealias progressBlock = (current: AnyObject, total: AnyObject) -> Void
    internal typealias operationManagerBlock = (manager: Alamofire.Manager?, error: String?) -> Void
    
    override init() {
        super.init()
        // Setup Network Reachability
        let reachability: Reachability! = Reachability.reachabilityForInternetConnection()
        self.reachabilityStatus = reachability.currentReachabilityStatus
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        reachability.startNotifier()
    }
    
    internal func getImagesHost() -> String! {
        return imagesHost
    }
    
    // MARK: - Reachability
    
    func reachabilityChanged(notification: NSNotification) {
        let reachability = notification.object as! Reachability
        self.reachabilityStatus = reachability.currentReachabilityStatus
    }
    
    func alertUserThatInternetIsUnreachableWithBlck(block: responseBlock) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            block(success: false, response: "No internet connection.")
        }
    }
    
    // MARK: - Auth
    
    func alertUserThatLoginIsRequiredWithBlock(block: responseBlock) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            block(success: false, response: "Login to continue.")
        }
    }
    
    func authenticatedOperationManager(block: operationManagerBlock) -> Void {
        self.getAccessTokenWithResponseBlock { (success, response) -> Void in
            if success {
                let accessToken: String! = response as! String
                
                var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
                defaultHeaders["Authorization"] = "Bearer \(accessToken)"
                
                let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                configuration.HTTPAdditionalHeaders = defaultHeaders
                self.authenticatedOperationManager = Alamofire.Manager(configuration: configuration)
                
                block(manager: self.authenticatedOperationManager, error: nil)
            }
            else {
                block(manager: nil, error: "\(response)")
            }
        }
    }
    
    func getAccessTokenWithResponseBlock(block: responseBlock) {
        let accessTokenDictionary: Dictionary<String, AnyObject>? = Settings.accessTokenDictionary()
        if (accessTokenDictionary == nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(success: false, response: "")
            })
        }
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss'"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        let accessToken: String! = accessTokenDictionary!["access_token"] as! String
        let expiresInSeconds: NSNumber! = accessTokenDictionary!["expires_in"] as! NSNumber
        let issuedDateString: String! = accessTokenDictionary!["issued"] as! String
        let expirationDate: NSDate! = dateFormatter.dateFromString(issuedDateString)?.dateByAddingTimeInterval(expiresInSeconds.doubleValue)
        
//        print("Issued String \(issuedDateString)")
//        print("Issued \(dateFormatter.dateFromString(issuedDateString))")
//        print("Current \(NSDate())")
//        print("Expires \(expirationDate)")
//        print("Expiration Time \(expirationDate.timeIntervalSinceDate(NSDate()))")
        
        // Refresh and return the Old one
        if ((expirationDate.timeIntervalSinceDate(NSDate()) < 864) && (expirationDate.timeIntervalSinceDate(NSDate()) > 0)) {
            let refreshToken: String! = accessTokenDictionary!["refresh_token"] as! String
            self.refreshAccessTokenWithRefreshToken(refreshToken, block: { (success, response) -> Void in
                if success {
                    let newAccessTokenDictionary: Dictionary<String, AnyObject>? = Settings.accessTokenDictionary()
                    let newAccessToken: String! = newAccessTokenDictionary!["access_token"] as! String
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: true, response: newAccessToken)
                    })
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: false, response: response)
                    })
                }
            })
        }
        
        // Re-SignIn and return the new one
        else if (expirationDate.timeIntervalSinceDate(NSDate()) <= 0) {
            let email: String? = Settings.email()
            let password: String? = Settings.password()
            let facebook: Bool? = Settings.userLoggedInWithFacebook()
            self.loginWithEmailAndPassword(email!, password: password!, facebook: facebook!, block: { (success, response) -> Void in
                if success {
                    let newAccessTokenDictionary: Dictionary<String, AnyObject>? = Settings.accessTokenDictionary()
                    let newAccessToken: String! = newAccessTokenDictionary!["access_token"] as! String
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: true, response: newAccessToken)
                    })
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: false, response: response)
                    })
                }
            })
        }
        
        // Return the Old One
        else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(success: true, response: accessToken)
            })
        }
    }
    
    func refreshAccessTokenWithRefreshToken(refreshToken: String, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        let urlString = "\(host)oauth2/token"
        let parameters: Dictionary<String, String> = [
            "grant_type": "refresh_token",
            "client_id": "mobileapp",
            "refresh_token": refreshToken,
            "client_secret": "mobileappsecret"
        ]
        
        Alamofire.Manager.sharedInstance.request(.POST, urlString, parameters: parameters).responseJSON { (let response: Response) in
            var success: Bool = false
            var localResponse: AnyObject = ""
            if (response.result.isSuccess) {
                
                // Success
                let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                if (responseDictionary["access_token"] != nil) {
                    Settings.setAccessTokenDictionary(responseDictionary)
                    localResponse = responseDictionary
                    success = true
                }
                else if let errorDescription = responseDictionary["error_description"] {
                    localResponse = errorDescription
                }
            }
            else {
                
                // Error
                localResponse = "Oops, something went wrong."
                print("Error in refreshAccessTokenWithRefreshToken: \(response.result.error)")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(success: success, response: localResponse)
            })
        }
    }
    
    internal func loginWithEmailAndPassword(email: String, password: String, facebook: Bool, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        let urlString = "\(host)oauth2/token"
        var parameters: Dictionary<String, String> = [
            "grant_type": "password",
            "username": email,
            "password": password,
            "client_id": "mobileapp",
            "client_secret": "mobileappsecret"
        ]
        if facebook {
            parameters["first_name"] = password
            parameters["account_type"] = "facebook"
            parameters.removeValueForKey("password")
        }
        
        Alamofire.Manager.sharedInstance.request(.POST, urlString, parameters: parameters).responseJSON { (let response: Response) in
            var success: Bool = false
            var localResponse: AnyObject = ""
            if (response.result.isSuccess) {
                
                // Success
                let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                if (responseDictionary["access_token"] != nil) {
                    Settings.setAccessTokenDictionary(responseDictionary)
                    localResponse = responseDictionary
                    success = true
                }
                else if let errorDescription = responseDictionary["error_description"] {
                    localResponse = errorDescription
                }
            }
            else {
                
                // Error
                localResponse = "Oops, something went wrong."
                print("Error in loginWithEmailAndPassword: \(response.result.error)")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(success: success, response: localResponse)
            })
        }
    }
    
    internal func signUpWithParameters(email: String, password: String, firstName: String, lastName: String, nationality: String?, clubName: String?, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        let urlString = "\(host)user"
        var parameters: Dictionary<String, String> = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "password": password,
            "club_name": "",
            "nationality": ""
        ]
        if (clubName != nil) {
            parameters["club_name"] = clubName
        }
        if (nationality != nil) {
            parameters["nationality"] = nationality
        }
        
        Alamofire.Manager.sharedInstance.request(.POST, urlString, parameters: parameters, encoding: .JSON).validate().responseJSON { (let response: Response) in
            var success: Bool = false
            var localResponse: AnyObject = ""
            if (response.result.isSuccess) {
                
                // Success
                let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                let result: String? = responseDictionary["result"] as? String
                if (result != nil && result == "success") {
                    
                    // Response
                    localResponse = responseDictionary
                    success = true
                }
                else if (result != nil && result == "error") {
                    
                    // Error Messages
                    localResponse = self.parseErrorsFromResponse(responseDictionary)
                    if (localResponse as? String)?.characters.count == 0 {
                        localResponse = "Error with registration."
                    }
                }
            }
            else {
                
                // Error
                localResponse = "Oops, something went wrong."
                print("Error in loginWithEmailAndPassword: \(response.result.error)")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(success: success, response: localResponse)
            })
        }
    }
    
    internal func resetPasswordForEmail(email: String, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        let urlString = "\(host)user/reset_password"
        let parameters: Dictionary<String, String> = [
            "email": email,
        ]
        
        Alamofire.Manager.sharedInstance.request(.POST, urlString, parameters: parameters, encoding: .JSON).validate().responseJSON { (let response: Response) in
            var success: Bool = false
            var localResponse: AnyObject = ""
            if (response.result.isSuccess) {
                
                // Success
                print(response.result.value)
                let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                let result: String? = responseDictionary["result"] as? String
                if (result != nil && result == "success") {
                    success = true
                }
                else if (result != nil && result == "error") {
                    
                    // Error Messages
                    localResponse = self.parseErrorsFromResponse(responseDictionary)
                    if (localResponse as? String)?.characters.count == 0 {
                        localResponse = "Error with Reseting Password."
                    }
                }
            }
            else {
                
                // Error
                localResponse = "Oops, something went wrong."
                print("Error in resetPasswordForEmail: \(response.result.error)")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(success: success, response: localResponse)
            })
        }
    }
    
    // MARK: - User
    
    internal func getUserDetailsWithResponseBlock(id: Int?, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        var urlString = "\(host)user"
        if (id != nil) {
            urlString = urlString.stringByAppendingString("/" + String(id!))
        }
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.GET, urlString, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success" && (responseDictionary["data"] != nil)) {
                            localResponse = responseDictionary["data"]!
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Getting User Details."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in getUserDetailsWithResponseBlock: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
        }
    }
    
    internal func updateUserWithReponseBlock(profileDictionary: Dictionary<String, AnyObject>, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)user"
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.PUT, urlString, parameters: profileDictionary, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success") {
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Updating User Details."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in updateUserWithReponseBlock: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
        }
    }
    
    internal func uploadUserPictureWithReponseBlock(pictureData: NSData, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)user/profile_picture"
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                let urlRequest = self.imageUploadURLWithComponents(urlString, imageData: pictureData)
                manager!.upload(urlRequest.0, data: urlRequest.1)
                    .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                    }
                    .responseJSON(completionHandler: { (let response) -> Void in
                        var success: Bool = false
                        var localResponse: AnyObject = ""
                        if (response.result.isSuccess) {
                            
                            // Success
                            let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                            let result: String? = responseDictionary["result"] as? String
                            if (result != nil && result == "success") {
                                success = true
                            }
                            else if (result != nil && result == "error") {
                                
                                // Error Messages
                                localResponse = self.parseErrorsFromResponse(responseDictionary)
                                if (localResponse as? String)?.characters.count == 0 {
                                    localResponse = "Error with Updating User Details."
                                }
                            }
                        }
                        else {
                            
                            // Error
                            localResponse = "Oops, something went wrong."
                            print("Error in uploadUserPictureWithReponseBlock: \(response.result.error)")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            block(success: success, response: localResponse)
                        })
                })
            }
        }
    }
    
    // MARK: - Videos
    
    internal enum AllVideosSortType {
        case None
        case MostRecent
        case MostLiked
    }
    
    internal func getPrizePreviewWithResponseBlock(block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)video/prize"
        
        Alamofire.Manager.sharedInstance.request(.GET, urlString, encoding: .JSON).validate().responseJSON { (let response: Response) in
            var success: Bool = false
            var localResponse: AnyObject = ""
            if (response.result.isSuccess) {
                
                // Success
                let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                let result: String? = responseDictionary["result"] as? String
                if (result != nil && result == "success" && (responseDictionary["data"] != nil)) {
                    localResponse = responseDictionary["data"]!
                    success = true
                }
                else if (result != nil && result == "error") {
                    
                    // Error Messages
                    localResponse = self.parseErrorsFromResponse(responseDictionary)
                    if (localResponse as? String)?.characters.count == 0 {
                        localResponse = "Error with Getting Prize Preview."
                    }
                }
            }
            else {
                
                // Error
                localResponse = "Oops, something went wrong."
                print("Error in getPrizePreviewWithResponseBlock: \(response.result.error)")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(success: success, response: localResponse)
            })
        }
    }
    
    internal func getAllVideosWithResponseBlock(sort: AllVideosSortType, limit: Int?, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        var urlString = "\(host)video/all"
        switch sort {
        case .None:
            urlString = urlString + "/list"
            break
        case .MostLiked:
            urlString = urlString + "/favorite"
            break
        case .MostRecent:
            urlString = urlString + "/most_recent"
            break
        }
        if (limit != nil) {
            urlString = urlString + "/" + String(limit!)
        }
        else {
            urlString = urlString + "/0"
        }
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.GET, urlString, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success" && (responseDictionary["data"] != nil)) {
                            localResponse = responseDictionary["data"]!
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Getting All Videos."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in getAllVideosWithResponseBlock: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
        }
    }
    
    internal func getVideoDetailsWithResponseBlock(videoId: Int, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)video/" + String(videoId)
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.GET, urlString, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success" && (responseDictionary["data"] != nil)) {
                            localResponse = responseDictionary["data"]!
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Getting Video Details."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in getVideoDetailsWithResponseBlock: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
        }
    }
    
    internal func getWinnersWithResponseBlock(block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)video/winners"
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.GET, urlString, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success" && (responseDictionary["data"] != nil)) {
                            localResponse = responseDictionary["data"]!
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Getting Winners."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in getWinnersWithResponseBlock: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
        }
    }
    
    internal func uploadVideoFromFileWithResponseBlock(videoData: NSData, progress: progressBlock, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)video"
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                let urlRequest = self.videoUploadURLWithComponents(urlString, videoData: videoData)
                manager!.upload(urlRequest.0, data: urlRequest.1)
                    .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            progress(current: NSNumber(longLong: totalBytesWritten), total: NSNumber(longLong: totalBytesExpectedToWrite))
                        })
                    }
                    .responseJSON(completionHandler: { (let response) -> Void in
                        var success: Bool = false
                        var localResponse: AnyObject = ""
                        if (response.result.isSuccess) {
                            
                            // Success
                            let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                            let result: String? = responseDictionary["result"] as? String
                            if (result != nil && result == "success") {
                                success = true
                            }
                            else if (result != nil && result == "error") {
                                
                                // Error Messages
                                localResponse = self.parseErrorsFromResponse(responseDictionary)
                                if (localResponse as? String)?.characters.count == 0 {
                                    localResponse = "Error with Uploading Video."
                                }
                            }
                        }
                        else {
                            
                            // Error
                            localResponse = "Oops, something went wrong."
                            print("Error in uploadVideoFromFileWithResponseBlock: \(response.result.error)")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            block(success: success, response: localResponse)
                        })
                    })
            }
        }
    }
    
    internal func uploadVideoFromLinkWithResponseBlock(videoLink: String, block: responseBlock) {
        // YouTube or Vimeo link
        
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)video"
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                let urlRequest = self.videoLinkURLWithComponents(urlString, videoLink: videoLink)
                manager!.upload(urlRequest.0, data: urlRequest.1)
                    .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                    }
                    .responseJSON(completionHandler: { (let response) -> Void in
                        var success: Bool = false
                        var localResponse: AnyObject = ""
                        if (response.result.isSuccess) {
                            
                            // Success
                            let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                            let result: String? = responseDictionary["result"] as? String
                            if (result != nil && result == "success") {
                                success = true
                            }
                            else if (result != nil && result == "error") {
                                
                                // Error Messages
                                localResponse = self.parseErrorsFromResponse(responseDictionary)
                                if (localResponse as? String)?.characters.count == 0 {
                                    localResponse = "Error with Uploading Video from Link."
                                }
                            }
                        }
                        else {
                            
                            // Error
                            localResponse = "Oops, something went wrong."
                            print("Error in uploadVideoFromLinkWithResponseBlock: \(response.result.error)")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            block(success: success, response: localResponse)
                        })
                    })
            }
        }
    }
    
    internal func likeVideoWithIdAndResponseBlock(videoId: NSNumber, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)like"
        let parameters = [
            "video_id": videoId
        ]
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.POST, urlString, parameters: parameters, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success") {
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Liking Video."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in likeVideoWithIdAndResponseBlock: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
        }
    }
    
    internal func commentOnAVideoWithIdAndResponseBlock(videoId: NSNumber, comment: String, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)comment"
        let parameters = [
            "video_id": videoId,
            "comment_text": comment
        ]
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.POST, urlString, parameters: parameters, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success" && (responseDictionary["data"] != nil)) {
                            localResponse = responseDictionary["data"]!
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Commenting on a Video."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in commentOnAVideoWithIdAndResponseBlock: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
            else {
                
            }
        }
    }
    
    internal func reportCommentWithId(commentId: String, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)comment/report/\(commentId)"
        print(urlString)
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.POST, urlString, parameters: nil, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success") {
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Reporting Comment."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in reportCommentWithId: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
            else {
                
            }
        }
    }
    
    internal func deleteCommentWithId(commentId: String, block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)comment/"
        let parameters = [
            "comment_id": commentId
        ]
        print(urlString)
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.DELETE, urlString, parameters: parameters, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success") {
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Reporting Comment."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in deleteCommentWithId: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
            else {
                
            }
        }
    }
    
    internal func videoPreviewLinkForVideoId(videoId: String) -> NSURL {
        // http://img.youtube.com/vi/<insert-youtube-video-id-here>/hqdefault.jpg
        // http://img.youtube.com/vi/<insert-youtube-video-id-here>/mqdefault.jpg
        // http://img.youtube.com/vi/<insert-youtube-video-id-here>/sddefault.jpg
        // http://img.youtube.com/vi/<insert-youtube-video-id-here>/maxresdefault.jpg
        let urlString = "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg"
        return NSURL(string: urlString)!
    }
    
    // MARK: - Notifications
    
    internal func getAllNotificationsWithResponseBlock(block: responseBlock) {
        if (self.reachabilityStatus == Reachability.NetworkStatus.NotReachable) {
            self.alertUserThatInternetIsUnreachableWithBlck(block)
            return
        }
        
        // Setup Parameters
        let urlString = "\(host)user/notifications"
        
        // Get Access Token
        self.authenticatedOperationManager { (manager, error) -> Void in
            if !(error != nil) {
                
                manager!.request(.GET, urlString, encoding: .JSON).validate().responseJSON { (let response: Response) in
                    var success: Bool = false
                    var localResponse: AnyObject = ""
                    if (response.result.isSuccess) {
                        
                        // Success
                        let responseDictionary = response.result.value as! Dictionary<String, AnyObject>
                        let result: String? = responseDictionary["result"] as? String
                        if (result != nil && result == "success" && (responseDictionary["data"] != nil)) {
                            localResponse = responseDictionary["data"]!
                            success = true
                        }
                        else if (result != nil && result == "error") {
                            
                            // Error Messages
                            localResponse = self.parseErrorsFromResponse(responseDictionary)
                            if (localResponse as? String)?.characters.count == 0 {
                                localResponse = "Error with Getting Notifications."
                            }
                        }
                    }
                    else {
                        
                        // Error
                        localResponse = "Oops, something went wrong."
                        print("Error in getAllNotificationsWithResponseBlock: \(response.result.error)")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        block(success: success, response: localResponse)
                    })
                }
            }
        }
    }
    
    // MARK: - Private
    
    func parseErrorsFromResponse(response: AnyObject) -> String {
        var errorString: String = ""
        if let data: Dictionary<String, AnyObject> = response["data"] as? Dictionary {
            if let errorArray: Array<String> = data["error_description"] as? Array {
                for error: String in errorArray {
                    errorString = errorString.stringByAppendingString("\(error) ")
                }
            }
        }
        
        return errorString
    }
    
    func imageUploadURLWithComponents(urlString:String, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.PUT.rawValue
        let boundaryConstant = "---b---";
        let contentType = "multipart/form-data"
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // add parameters
        let key1 = "name"
        let value1 = "name.png"
        let key2 = "file"
        uploadData.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"\(key1)\"\r\n\r\n\(value1)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"\(key2)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        uploadData.appendData("--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    func videoUploadURLWithComponents(urlString: String, videoData: NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "---b---";
        let contentType = "multipart/form-data"
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.mp4\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: video/mp4\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // add parameters
        let key1 = "name"
        let value1 = "name.mp4"
        let key2 = "file"
        uploadData.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"\(key1)\"\r\n\r\n\(value1)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"\(key2)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(videoData)
        uploadData.appendData("--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    func videoLinkURLWithComponents(urlString:String, videoLink: String) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "---b---";
        let contentType = "multipart/form-data"
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add parameters
        let key1 = "link"
        uploadData.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"\(key1)\"\r\n\r\n\(videoLink)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)

        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    func base64StringFromString(string: String) -> String {
        let data : NSData = (string as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}
