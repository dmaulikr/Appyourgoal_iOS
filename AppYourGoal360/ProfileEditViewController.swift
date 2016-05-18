//
//  ProfileEditViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/28/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit
import QuickLook
import Kingfisher

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QLPreviewControllerDataSource, SwiftHUEColorPickerDelegate {
    
    var urlToDisplay: NSURL!

    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldExtra: UITextField!
    
    @IBOutlet weak var viewBackgroundColor: UIView!
    @IBOutlet weak var buttonStripeColor: UIButton!
    @IBOutlet weak var imageViewProfilePicture: UIImageView!
    
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var notificationTopContraint: NSLayoutConstraint!
    
    let imagePicker = UIImagePickerController()
    var isBackgroundColor: Bool = true
    var isPictureChanged: Bool = false
    
    @IBOutlet weak var colorPicker: SwiftHUEColorPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(6 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.dismissNotification()
        }
    }

    func initialSetup() {
        self.colorPicker.delegate = self
        self.imagePicker.delegate = self
        
        // Set Current Values
        self.colorPicker.currentColor = Settings.backgroundColor()
        self.viewBackgroundColor.backgroundColor = Settings.backgroundColor()
        let stripeImage: UIImage? = UIImage(named: "ImageStripeEdit")
        self.buttonStripeColor.tintColor = Settings.stripeColor()
        self.buttonStripeColor.setImage(stripeImage?.tintWithColor(Settings.stripeColor()), forState: UIControlState.Normal)
        
        let profileDictionary: Dictionary<String, AnyObject>? = Settings.userProfile()
        if (profileDictionary != nil) {
            let firstName: String? = profileDictionary!["first_name"] as? String
            let nationality: String? = profileDictionary!["nationality"] as? String
            var profileImageLink: String? = profileDictionary!["profile_picture"] as? String
            
            // Setup labelName
            if ((firstName != nil) && (firstName!.characters.count > 0)) {
                self.textFieldName.text = firstName!
            }
            
            // Setup labelExtra
            if ((nationality != nil) && (nationality!.characters.count > 0)) {
                self.textFieldExtra.text = nationality!
            }
            
            // Setup imageViewProfilPicture
            self.imageViewProfilePicture.image = UIImage(named: "ImageProfileAvatar")
            if ((profileImageLink != nil) && (profileImageLink!.characters.count > 0)) {
                profileImageLink! = NetworkController.sharedInstance.getImagesHost() + profileImageLink!
                self.imageViewProfilePicture.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
            }
        }
    }
    
    func dismissNotification() {
        self.view.layoutIfNeeded()
        self.notificationTopContraint.constant = -self.viewNotification.frame.size.height
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.viewNotification.alpha = 0.0
            }, completion: { (finished) -> Void in
                self.viewNotification.hidden = true
        })
    }
    
    // MARK: - SwiftHUEColorPickerDelegate
    
    func valuePicked(color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        if (isBackgroundColor) {
            self.viewBackgroundColor.backgroundColor = color
        }
        else {
            self.buttonStripeColor.tintColor = color
            let stripeImage: UIImage? = UIImage(named: "ImageStripeEdit")
            self.buttonStripeColor.setImage(stripeImage?.tintWithColor(color), forState: UIControlState.Normal)
        }
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return self.urlToDisplay
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UIImagePickerControllerDelegate and 
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if let pickedImage: UIImage = image {
            self.isPictureChanged = true
            self.imageViewProfilePicture.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - IBActions and Actions
    
    func syncEverythingAndGoBack() {
        SyncController.sharedInstance.syncEverythingWithSuccessBlock({ (success) -> Void in
            if success {
                Utilities.hidePKHUDViewWithSuccess("Saved")
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                Utilities.hidePKHUDViewWithError(nil)
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    @IBAction func buttonBackgroundColor(sender: AnyObject) {
        isBackgroundColor = true
        self.dismissNotification()
        self.colorPicker.currentColor = self.viewBackgroundColor.backgroundColor!
    }
    
    @IBAction func buttonStripeColor(sender: AnyObject) {
        isBackgroundColor = false
        self.dismissNotification()
        self.colorPicker.currentColor = self.buttonStripeColor.tintColor!
    }

    @IBAction func buttonCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func buttonSave(sender: AnyObject) {
        Settings.setBacgroundColor(self.viewBackgroundColor.backgroundColor!)
        Settings.setStripeColor(self.buttonStripeColor.tintColor)
        
        var profileChanges: Dictionary<String, AnyObject> = Dictionary()
        let fullName: String? = self.textFieldName.text
        let nationality: String? = self.textFieldExtra.text
        if ((fullName != nil) && (fullName?.characters.count > 0)) {
            profileChanges["first_name"] = fullName
            profileChanges["last_name"] = fullName
        }
        
        if ((nationality != nil) && (nationality?.characters.count > 0)) {
            profileChanges["nationality"] = nationality
        }
        
        Utilities.showPKHUDProgressView()
        NetworkController.sharedInstance.updateUserWithReponseBlock(profileChanges) { (success, response) -> Void in
            if success {
                if self.isPictureChanged {
                    let profilePicture = Utilities.imageResize(self.imageViewProfilePicture.image!, sizeChange: CGSizeMake(self.imageViewProfilePicture.image!.size.width / 4, self.imageViewProfilePicture.image!.size.height / 4))
                    let profilePictureData: NSData = UIImagePNGRepresentation(profilePicture)!
                    NetworkController.sharedInstance.uploadUserPictureWithReponseBlock(profilePictureData, block: { (success, response) -> Void in
                        self.syncEverythingAndGoBack()
                    })
                }
                else {
                    self.syncEverythingAndGoBack()
                }
            }
            else {
                Utilities.hidePKHUDViewWithError(nil)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    @IBAction func buttonEditPhoto(sender: AnyObject) {
        self.imagePicker.allowsEditing = false
        
        let alertController = UIAlertController(title: "Camera or Photo Library?", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (action) in
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (action) in
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func buttonContestRules(sender: AnyObject) {
//        UIApplication.sharedApplication().openURL(NSURL(string:"http://appyourgoal.com/index.php/contest-rules/")!)
        let previewController = QLPreviewController()
        let filePath = NSBundle.mainBundle().pathForResource("ContestRules", ofType: "docx")
        previewController.dataSource = self
        self.urlToDisplay = NSURL(fileURLWithPath: filePath!)
        self.presentViewController(previewController, animated: true, completion: nil)
    }
    
    @IBAction func buttonPrivacyPolicy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://appyourgoal.com/index.php/privacy-policy/appyourgoal-privacy-policy/")!)
    }
    
    @IBAction func buttonTermsOfUse(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://appyourgoal.com/index.php/privacy-policy/terms-of-use/terms-of-use/")!)
    }
}
