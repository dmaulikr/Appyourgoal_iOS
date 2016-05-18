//
//  LoginViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/14/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit
import Parse
import QuickLook
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, QLPreviewControllerDataSource {

    var urlToDisplay: NSURL!
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldEmail.delegate = self
        self.textFieldPassword.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return self.urlToDisplay
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - IBActions and Actions
    
    func syncEverythingAndLogin(email: String, password: String, facebook: Bool) {
        
        // Sync Parse
        let installation = PFInstallation.currentInstallation()
        if (installation.objectId != nil) {
            installation["userEmail"] = email
            installation.saveInBackground()
        }
        
        // Sync Everything
        SyncController.sharedInstance.syncEverythingWithSuccessBlock({ (success) -> Void in
            if success {
                
                // Synced
                Utilities.hidePKHUDViewWithSuccess("Success")
                Settings.setEmail(email)
                Settings.setPassword(password)
                Settings.setUserLoggedIn(true)
                Settings.setUserLoggedInWithFacebook(facebook)
                (UIApplication.sharedApplication().delegate as! AppDelegate).userLoggedIn()
            }
            else {
                Utilities.hidePKHUDViewWithError("Could not get User Profile. Please, try again")
            }
        })
    }
    
    @IBAction func buttonEula(sender: AnyObject) {
        let previewController = QLPreviewController()
        let filePath = NSBundle.mainBundle().pathForResource("EULA", ofType: "docx")
        previewController.dataSource = self
        self.urlToDisplay = NSURL(fileURLWithPath: filePath!)
        self.presentViewController(previewController, animated: true, completion: nil)
    }
    
    @IBAction func buttonLogIn(sender: AnyObject) {
        let email: String? = self.textFieldEmail.text
        let password: String? = self.textFieldPassword.text
        if (email == nil || email?.characters.count == 0) {
            Utilities.showUIAlertViewWithMessage("Please enter your email address.")
            return
        }
        if (!Utilities.isStringValidEmailAddress(email!)) {
            Utilities.showUIAlertViewWithMessage("Email address you entered seems to be invalid. Please, enter valid email address.")
            return
        }
        if (password == nil || password?.characters.count == 0) {
            Utilities.showUIAlertViewWithMessage("Please enter your password.")
            return
        }
        
        Utilities.showPKHUDProgressView()
        NetworkController.sharedInstance.loginWithEmailAndPassword(email!, password: password!, facebook: false) { (success, response) -> Void in
            if (success) {
                self.syncEverythingAndLogin(email!, password: password!, facebook: false)
            }
            else {
                Utilities.hidePKHUDViewWithError(response as? String)
            }
        }
    }
    
    @IBAction func buttonTroubleLoggingIn(sender: AnyObject) {
        let alertController = UIAlertController(title: "AppYourGoal", message: "Please, enter your email address", preferredStyle: .Alert)
        let actionReset = UIAlertAction(title: "Reset", style: .Default) { (_) -> Void in
            let emailTextField = alertController.textFields![0] as UITextField
            guard let emailAddress = emailTextField.text where emailAddress.characters.count > 0 else {
                Utilities.showUIAlertViewWithMessage("Please, enter your email address")
                return
            }
            
            NetworkController.sharedInstance.resetPasswordForEmail(emailAddress, block: { (success, response) -> Void in
                if success {
                    Utilities.showUIAlertViewWithMessage("We'v sent password reset instructions to your email address")
                }
                else {
                    Utilities.showUIAlertViewWithMessage("\(response)")
                }
            })
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel) { (_) -> Void in
            
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Email Address"
            textField.keyboardType = UIKeyboardType.EmailAddress
        }
        
        alertController.addAction(actionReset)
        alertController.addAction(actionCancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func buttonSignInWithFacebook(sender: AnyObject) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result, error) -> Void in
            if (error != nil) {
                // Error
                print("\(error)")
            }
            else if (result.isCancelled) {
                // User Canceled
                print("User canceled")
            }
            else {
                // Logged in
                let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, first_name, last_name"])
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (error != nil) {
                        // Error
                        print("\(error)")
                    }
                    else if let details: Dictionary<String, AnyObject> = result as? Dictionary<String, AnyObject>{
                        let email: String = details["email"] as! String
                        let firstName: String = details["first_name"] as! String
                        NetworkController.sharedInstance.loginWithEmailAndPassword(email, password: firstName, facebook: true, block: { (success, response) -> Void in
                            if success {
                                self.syncEverythingAndLogin(email, password: firstName, facebook: true)
                            }
                            else {
                                Utilities.hidePKHUDViewWithError(response as? String)
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func buttonSignUp(sender: AnyObject) {
        self.performSegueWithIdentifier(Constants.kLoginViewControllerToSignupViewControllerSegue, sender: nil)
    }
}
