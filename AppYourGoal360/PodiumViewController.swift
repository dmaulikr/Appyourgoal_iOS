//
//  PodiumViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/22/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit
import Kingfisher

class PodiumViewController: UIViewController, GoalViewControllerDelegate {
    
    var winners: Array<AnyObject>?

    @IBOutlet weak var buttonFilter: UIButton!
    @IBOutlet weak var viewOptionsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonOption: UIButton!
    
    @IBOutlet weak var imageViewProfilePicture1st: UIImageView!
    @IBOutlet weak var imageViewPreview1st: UIImageView!
    @IBOutlet weak var imageViewLike1st: UIImageView!
    @IBOutlet weak var imageViewComment1st: UIImageView!
    @IBOutlet weak var labelName1st: UILabel!
    @IBOutlet weak var labelLikes1st: UILabel!
    @IBOutlet weak var labelWeekLikes1st: UILabel!
    @IBOutlet weak var labelComments1st: UILabel!
    
    @IBOutlet weak var imageViewProfilePicture2nd: UIImageView!
    @IBOutlet weak var imageViewPreview2nd: UIImageView!
    @IBOutlet weak var imageViewLike2nd: UIImageView!
    @IBOutlet weak var imageViewComment2nd: UIImageView!
    @IBOutlet weak var labelName2nd: UILabel!
    @IBOutlet weak var labelLikes2nd: UILabel!
    @IBOutlet weak var labelWeekLikes2nd: UILabel!
    @IBOutlet weak var labelComments2nd: UILabel!
    
    @IBOutlet weak var imageViewProfilePicture3rd: UIImageView!
    @IBOutlet weak var imageViewPreview3rd: UIImageView!
    @IBOutlet weak var imageViewLike3rd: UIImageView!
    @IBOutlet weak var imageViewComment3rd: UIImageView!
    @IBOutlet weak var labelName3rd: UILabel!
    @IBOutlet weak var labelLikes3rd: UILabel!
    @IBOutlet weak var labelWeekLikes3rd: UILabel!
    @IBOutlet weak var labelComments3rd: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func initialSetup() {
        
        // Load Winners
        Utilities.showPKHUDProgressView()
        NetworkController.sharedInstance.getWinnersWithResponseBlock { (success, response) -> Void in
            Utilities.hidePKHUDView()
            if success {
                if let winners: Array<AnyObject> = response as? Array<AnyObject> where winners.count == 3 {
                    self.winners = winners
                    self.setupWinners()
                }
                else {
                    Utilities.showUIAlertViewWithMessage("Could not get Winners at this moment, please, try again.")
                }
            }
            else {
                Utilities.showUIAlertViewWithMessage("\(response)")
            }
        }
    }
    
    func setupWinners() {
        let firstVideo: Dictionary<String, AnyObject> = self.winners![2] as! Dictionary<String, AnyObject>
        let secondVideo: Dictionary<String, AnyObject> = self.winners![1] as! Dictionary<String, AnyObject>
        let thirdVideo: Dictionary<String, AnyObject> = self.winners![0] as! Dictionary<String, AnyObject>
        
        self.labelWeekLikes1st.layer.borderColor = self.labelWeekLikes1st.textColor.CGColor
        self.labelWeekLikes1st.layer.borderWidth = 1.0
        self.labelWeekLikes2nd.layer.borderColor = self.labelWeekLikes2nd.textColor.CGColor
        self.labelWeekLikes2nd.layer.borderWidth = 1.0
        self.labelWeekLikes3rd.layer.borderColor = self.labelWeekLikes3rd.textColor.CGColor
        self.labelWeekLikes3rd.layer.borderWidth = 1.0
        
        // ---- Setup 1st Video
        var profileImageLink1st: String? = firstVideo["user"]?["profile_picture"] as? String
        if (profileImageLink1st != nil) {
            profileImageLink1st! = NetworkController.sharedInstance.getImagesHost() + profileImageLink1st!
            self.imageViewProfilePicture1st.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink1st!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
        }
        self.labelName1st.text = firstVideo["user"]?["first_name"] as? String
        self.labelLikes1st.text = firstVideo["likes_no"] as? String
        if let weekLikes = firstVideo["week_likes"] as? String {
            self.labelWeekLikes1st.text = " \(weekLikes) "
        }
        if let comments: Array<AnyObject> = firstVideo["comments"] as? Array<AnyObject> {
            self.labelComments1st.text = String(comments.count)
        }
        if let userLiked: NSNumber = firstVideo["user_liked"] as? NSNumber {
            self.imageViewLike1st.highlighted = userLiked.boolValue
            self.labelLikes1st.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
            self.labelWeekLikes1st.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
            self.labelWeekLikes1st.layer.borderColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor.CGColor : Constants.kDefaultButtonTextColor.CGColor
        }
        if let userCommented: NSNumber = firstVideo["user_commented"] as? NSNumber {
            self.imageViewComment1st.highlighted = userCommented.boolValue
            self.labelComments1st.textColor = userCommented.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
        }
        if let videoId: String = firstVideo["youtube_id"] as? String {
            self.imageViewPreview1st.kf_setImageWithResource(Resource(downloadURL: NetworkController.sharedInstance.videoPreviewLinkForVideoId(videoId)), placeholderImage: UIImage(named: ""))
        }
        
        // ---- Setup 2nd Video
        var profileImageLink2nd: String? = secondVideo["user"]?["profile_picture"] as? String
        if (profileImageLink2nd != nil) {
            profileImageLink2nd! = NetworkController.sharedInstance.getImagesHost() + profileImageLink2nd!
            self.imageViewProfilePicture2nd.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink2nd!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
        }
        self.labelName2nd.text = secondVideo["user"]?["first_name"] as? String
        self.labelLikes2nd.text = secondVideo["likes_no"] as? String
        if let weekLikes = secondVideo["week_likes"] as? String {
            self.labelWeekLikes2nd.text = " \(weekLikes) "
        }
        if let comments: Array<AnyObject> = secondVideo["comments"] as? Array<AnyObject> {
            self.labelComments2nd.text = String(comments.count)
        }
        if let userLiked: NSNumber = secondVideo["user_liked"] as? NSNumber {
            self.imageViewLike2nd.highlighted = userLiked.boolValue
            self.labelLikes2nd.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
            self.labelWeekLikes2nd.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
            self.labelWeekLikes2nd.layer.borderColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor.CGColor : Constants.kDefaultButtonTextColor.CGColor
        }
        if let userCommented: NSNumber = secondVideo["user_commented"] as? NSNumber {
            self.imageViewComment2nd.highlighted = userCommented.boolValue
            self.labelComments2nd.textColor = userCommented.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
        }
        if let videoId: String = secondVideo["youtube_id"] as? String {
            self.imageViewPreview2nd.kf_setImageWithResource(Resource(downloadURL: NetworkController.sharedInstance.videoPreviewLinkForVideoId(videoId)), placeholderImage: UIImage(named: ""))
        }
        
        // ---- Setup 3rd Video
        var profileImageLink3rd: String? = thirdVideo["user"]?["profile_picture"] as? String
        if (profileImageLink3rd != nil) {
            profileImageLink3rd! = NetworkController.sharedInstance.getImagesHost() + profileImageLink3rd!
            self.imageViewProfilePicture3rd.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink3rd!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
        }
        self.labelName3rd.text = thirdVideo["user"]?["first_name"] as? String
        self.labelLikes3rd.text = thirdVideo["likes_no"] as? String
        if let weekLikes = thirdVideo["week_likes"] as? String {
            self.labelWeekLikes3rd.text = " \(weekLikes) "
        }
        if let comments: Array<AnyObject> = thirdVideo["comments"] as? Array<AnyObject> {
            self.labelComments3rd.text = String(comments.count)
        }
        if let userLiked: NSNumber = thirdVideo["user_liked"] as? NSNumber {
            self.imageViewLike3rd.highlighted = userLiked.boolValue
            self.labelLikes3rd.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
            self.labelWeekLikes3rd.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
            self.labelWeekLikes3rd.layer.borderColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor.CGColor : Constants.kDefaultButtonTextColor.CGColor
        }
        if let userCommented: NSNumber = thirdVideo["user_commented"] as? NSNumber {
            self.imageViewComment3rd.highlighted = userCommented.boolValue
            self.labelComments3rd.textColor = userCommented.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
        }
        if let videoId: String = thirdVideo["youtube_id"] as? String {
            self.imageViewPreview3rd.kf_setImageWithResource(Resource(downloadURL: NetworkController.sharedInstance.videoPreviewLinkForVideoId(videoId)), placeholderImage: UIImage(named: ""))
        }
    }
    
    // MARK: - GoalViewControllerDelegate
    
    func goalViewControllerIsBeingDismissedWithVideo(videoDictionary: Dictionary<String, AnyObject>) {
        if let dismissedVideo_id: String = videoDictionary["video_id"] as? String {
            var i = 0
            for video in self.winners! {
                let videoId: String? = video["video_id"] as? String
                if videoId == dismissedVideo_id {
                    self.winners![i] = videoDictionary
                    self.setupWinners()
                    break
                }
                i++
            }
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == Constants.kPodiumViewControllerToProfileViewControllerSegue) {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
        }
        else if segue.identifier == Constants.kPodiumViewControllerToGoalViewControllerSegue {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
            (segue.destinationViewController as! GoalViewController).winner = sender as? Dictionary<String, AnyObject>
            (segue.destinationViewController as! GoalViewController).delegate = self
        }
        else {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
        }
    }

    // MARK: - IBActions and Actions
    
    @IBAction func buttonFilter(sender: AnyObject) {
        self.buttonFilter.selected = !self.buttonFilter.selected
        self.view.layoutIfNeeded()
        if self.buttonFilter.selected {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.viewOptionsTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.viewOptionsTopConstraint.constant = -44
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    @IBAction func buttonOption(sender: AnyObject) {
        var filterTitleToSet = ""
        var optionTitleToSet = ""
        if self.buttonFilter.titleLabel?.text == "Best Goals" {
            // Show Hall Of Fame
            
            filterTitleToSet = "Hall Of Fame"
            optionTitleToSet = "Best Goals"
        }
        else {
            // Show Best Goals
            
            filterTitleToSet = "Best Goals"
            optionTitleToSet = "Hall Of Fame"
        }
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewOptionsTopConstraint.constant = -44
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.buttonFilter.selected = !self.buttonFilter.selected
                self.buttonFilter.setTitle(filterTitleToSet, forState: UIControlState.Normal)
                self.buttonFilter.setTitle(filterTitleToSet, forState: UIControlState.Selected)
                self.buttonOption.setTitle(optionTitleToSet, forState: UIControlState.Normal)
                self.buttonOption.setTitle(optionTitleToSet, forState: UIControlState.Selected)
        }
    }
    
    @IBAction func buttonProfile(sender: AnyObject) {
        self.performSegueWithIdentifier(Constants.kPodiumViewControllerToProfileViewControllerSegue, sender: nil)
    }
    
    @IBAction func buttonNotifications(sender: AnyObject) {
        self.performSegueWithIdentifier(Constants.kPodiumViewControllerToNotificationsViewControllerSegue, sender: nil)
    }
    
    @IBAction func buttonPlay1st(sender: AnyObject) {
        if (self.winners != nil) {
            let firstVideo: Dictionary<String, AnyObject> = self.winners![2] as! Dictionary<String, AnyObject>
            self.performSegueWithIdentifier(Constants.kPodiumViewControllerToGoalViewControllerSegue, sender: firstVideo)
        }
    }

    @IBAction func buttonPlay2nd(sender: AnyObject) {
        if (self.winners != nil) {
            let secondVideo: Dictionary<String, AnyObject> = self.winners![1] as! Dictionary<String, AnyObject>
            self.performSegueWithIdentifier(Constants.kPodiumViewControllerToGoalViewControllerSegue, sender: secondVideo)
        }
    }
    
    @IBAction func buttonPlay3rd(sender: AnyObject) {
        if (self.winners != nil) {
            let thirdVideo: Dictionary<String, AnyObject> = self.winners![0] as! Dictionary<String, AnyObject>
            self.performSegueWithIdentifier(Constants.kPodiumViewControllerToGoalViewControllerSegue, sender: thirdVideo)
        }
    }
}
