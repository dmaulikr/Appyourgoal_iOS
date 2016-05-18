//
//  SignupViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/14/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit
import Parse
import QuickLook

class SignupViewController: UIViewController, QLPreviewControllerDataSource {

    var urlToDisplay: NSURL!
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.textFieldName.becomeFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return self.urlToDisplay
    }
    
    // MARK: IBActions and Actions
    
    @IBAction func buttonEula(sender: AnyObject) {
        let previewController = QLPreviewController()
        let filePath = NSBundle.mainBundle().pathForResource("EULA", ofType: "docx")
        previewController.dataSource = self
        self.urlToDisplay = NSURL(fileURLWithPath: filePath!)
        self.presentViewController(previewController, animated: true, completion: nil)
    }
    
    @IBAction func buttonBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func buttonSignUp(sender: AnyObject) {
        let email: String? = self.textFieldEmail.text
        let password: String? = self.textFieldPassword.text
        let name: String? = self.textFieldName.text
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
        if (name == nil || name?.characters.count == 0) {
            Utilities.showUIAlertViewWithMessage("Please enter your password.")
            return
        }
        
        Utilities.showPKHUDProgressView()
        NetworkController.sharedInstance.signUpWithParameters(email!, password: password!, firstName: name!, lastName: name!, nationality: nil, clubName: nil) { (success, response) -> Void in
            if success {
                
                // Successful SignUp, LogIn
                NetworkController.sharedInstance.loginWithEmailAndPassword(email!, password: password!, facebook: false) { (success, response) -> Void in
                    if (success) {
                        
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
                                Settings.setEmail(email!)
                                Settings.setPassword(password!)
                                Settings.setUserLoggedIn(true)
                                Settings.setUserLoggedInWithFacebook(false)
                                (UIApplication.sharedApplication().delegate as! AppDelegate).userLoggedIn()
                            }
                            else {
                                Utilities.hidePKHUDViewWithError("Could not get User Profile. Please, try again")
                            }
                        })
                    }
                    else {
                        Utilities.hidePKHUDViewWithError(response as? String)
                    }
                }
            }
            else {
                Utilities.hidePKHUDViewWithError(response as? String)
            }
        }
    }
}
