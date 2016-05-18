//
//  ProfileViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/23/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ProfileTableViewCellDelegate, GoalsTableViewCellDelegate, GoalViewControllerDelegate {

    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl?
    var goals: Array <AnyObject> = Array <AnyObject>()
    var medals: Array <AnyObject> = Array <AnyObject>()
    var prizes: Array <AnyObject> = Array <AnyObject>()
    var isGoals: Bool = true
    var isMedals: Bool = false
    var isPrizes: Bool = false
    
    var globalProfileImageLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.tableView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Private
    
    func initialSetup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        self.getAllUsersContent()
    }
    
    func correctContentOffset() {
        var contentOffset = self.tableView.contentOffset
        if contentOffset == CGPointMake(0, 0) {
            contentOffset = CGPointMake(0, tableView.frame.size.width)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.tableView.contentOffset = contentOffset
            })
        }
        else {
            self.tableView.contentOffset = contentOffset
        }
    }
    
    func getAllUsersContent() {
        NetworkController.sharedInstance.getUserDetailsWithResponseBlock(nil) { (success, response) -> Void in
            self.refreshControl?.endRefreshing()
            if success {
                if let userProfile: Dictionary<String, AnyObject> = response as? Dictionary<String, AnyObject> {
                    if let goals: Array<AnyObject> = userProfile["videos"] as? Array<AnyObject> where goals.count > 0 {
                        self.goals = goals
                    }
                    if let medals: Array<AnyObject> = userProfile["medals"] as? Array<AnyObject> where medals.count > 0 {
                        self.medals = medals
                        
                        // Find Prizes
                        for medal in self.medals {
                            if let medalDictionary: Dictionary<String, AnyObject> = medal as? Dictionary<String, AnyObject> where ((medalDictionary["prize"] as? Dictionary<String, AnyObject>) != nil) {
                                self.prizes.append(medalDictionary)
                            }
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
            else {
                
            }
        }
    }
    
    func setupPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
    }
    
    func refresh() {
        self.getAllUsersContent()
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isGoals {
            return self.goals.count + 1
        }
        else if isMedals {
            return self.medals.count + 1
        }
        else if isPrizes {
            return self.prizes.count + 1
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.frame.size.height
        }
        else {
            return tableView.frame.size.width
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: ProfileTableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.kProfileTableViewCell, forIndexPath: indexPath) as! ProfileTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            let stripeImage: UIImage? = UIImage(named: "ImageStripe")
            cell.imageViewStripe.tintColor = Settings.stripeColor()
            cell.imageViewStripe.image = stripeImage?.tintWithColor(Settings.stripeColor())
            cell.viewBackgroundColor.backgroundColor = Settings.backgroundColor()
            if isGoals {
                cell.buttonGoals.selected = true
                cell.buttonMedals.selected = false
                cell.buttonPrizes.selected = false
            }
            else if isMedals {
                cell.buttonGoals.selected = false
                cell.buttonMedals.selected = true
                cell.buttonPrizes.selected = false
            }
            else if isPrizes {
                cell.buttonGoals.selected = false
                cell.buttonMedals.selected = false
                cell.buttonPrizes.selected = true
            }
            
            
            if let profileDictionary: Dictionary<String, AnyObject> = Settings.userProfile() {
                let firstName: String? = profileDictionary["first_name"] as? String
                let nationality: String? = profileDictionary["nationality"] as? String
                var profileImageLink: String? = profileDictionary["profile_picture"] as? String
                
                // Setup labelName
                if ((firstName != nil) && (firstName!.characters.count > 0)) {
                    cell.labelName.text = firstName!
                }
                
                // Setup labelExtra
                if ((nationality != nil) && (nationality!.characters.count > 0)) {
                    cell.labelExtra.text = nationality!
                }
                
                // Setup imageViewProfilPicture
                if ((profileImageLink != nil) && (profileImageLink!.characters.count > 0)) {
                    profileImageLink! = NetworkController.sharedInstance.getImagesHost() + profileImageLink!
                    cell.imageViewProfilPicture.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
                    self.globalProfileImageLink = profileImageLink!
                }
                
                // Setup Goals Button
                if self.goals.count > 0 {
                    cell.buttonGoals.setTitle("GOALS (\(self.goals.count))", forState: UIControlState.Normal)
                }
                
                // Setup Medals Button
                if self.medals.count > 0 {
                    cell.buttonMedals.setTitle("MEDALS (\(self.medals.count))", forState: UIControlState.Normal)
                }
                
                // Setup Prizes Button
                if self.prizes.count > 0 {
                    cell.buttonPrizes.setTitle("PRIZES (\(self.prizes.count))", forState: UIControlState.Normal)
                }
            }
            
            return cell
        }
        else {
            let cell: GoalsTableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.kGoalsTableViewCell, forIndexPath: indexPath) as! GoalsTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.tag = indexPath.row
            
            if isGoals {
                
                // Setup for Goals
                if let goal: Dictionary<String, AnyObject> = self.goals[indexPath.row - 1] as? Dictionary<String, AnyObject> {
                    
                    cell.resetContent()
                    if (self.globalProfileImageLink != nil) {
                        cell.imageViewProfilePicture.kf_setImageWithResource(Resource(downloadURL: NSURL(string: self.globalProfileImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
                    }
                    if let profileDictionary: Dictionary<String, AnyObject> = Settings.userProfile() {
                        cell.labelName.text = profileDictionary["first_name"] as? String
                    }
                    
                    cell.labelLikes.text = goal["likes_count"] as? String
                    if let weekLikes = goal["week_likes"] as? String {
                        cell.labelWeekLikes.text = " \(weekLikes) "
                    }
                    if let userLiked: NSNumber = goal["user_liked"] as? NSNumber {
                        cell.imageViewLike.highlighted = userLiked.boolValue
                        cell.buttonLike.selected = userLiked.boolValue
                        cell.setLabelsSelected(userLiked.boolValue)
                    }
                    if let userCommented: NSNumber = goal["user_commented"] as? NSNumber {
                        cell.imageViewComment.highlighted = userCommented.boolValue
                        cell.labelComments.textColor = userCommented.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
                    }
                    if let comments: Array<AnyObject> = goal["comments"] as? Array<AnyObject> {
                        cell.labelComments.text = String(comments.count)
                    }
                    if let videoId: String = goal["youtube_id"] as? String {
                        cell.imageViewPreview.kf_setImageWithResource(Resource(downloadURL: NetworkController.sharedInstance.videoPreviewLinkForVideoId(videoId)), placeholderImage: UIImage(named: "ImageProfileAvatar"))
                    }
                }
            }
            else if isMedals {
                // Setup for Medals
                if let medal: Dictionary<String, AnyObject> = self.medals[indexPath.row - 1] as? Dictionary<String, AnyObject> {
                    
                    cell.resetContent()
                    if (self.globalProfileImageLink != nil) {
                        cell.imageViewProfilePicture.kf_setImageWithResource(Resource(downloadURL: NSURL(string: self.globalProfileImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
                    }
                    if let profileDictionary: Dictionary<String, AnyObject> = Settings.userProfile() {
                        cell.labelName.text = profileDictionary["first_name"] as? String
                    }
                    
                    cell.labelLikes.text = medal["likes_count"] as? String
                    cell.labelComments.text = medal["comments_count"] as? String
                    if let weekLikes = medal["week_likes"] as? String {
                        cell.labelWeekLikes.text = " \(weekLikes) "
                    }
                    if let userLiked: NSNumber = medal["user_liked"] as? NSNumber {
                        cell.imageViewLike.highlighted = userLiked.boolValue
                        cell.buttonLike.selected = userLiked.boolValue
                        cell.setLabelsSelected(userLiked.boolValue)
                    }
                    if let userCommented: NSNumber = medal["user_commented"] as? NSNumber {
                        cell.imageViewComment.highlighted = userCommented.boolValue
                        cell.labelComments.textColor = userCommented.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
                    }
                    if let place: String = medal["place"] as? String {
                        cell.showImageViewMedalForPlace(Int(place)!)
                    }
                    if let videoId: String = medal["youtube_id"] as? String {
                        cell.imageViewPreview.kf_setImageWithResource(Resource(downloadURL: NetworkController.sharedInstance.videoPreviewLinkForVideoId(videoId)), placeholderImage: UIImage(named: "ImageProfileAvatar"))
                    }
                }
            }
            else if isPrizes {
                // Setup for Prizes
                
                if let medal: Dictionary<String, AnyObject> = self.prizes[indexPath.row - 1] as? Dictionary<String, AnyObject> {
                    
                    cell.resetContent()
                    cell.labelComments.hidden = true
                    cell.labelLikes.hidden = true
                    cell.labelName.hidden = true
                    cell.buttonLike.hidden = true
                    cell.imageViewComment.hidden = true
                    cell.imageViewLike.hidden = true
                    if let prize: Dictionary<String, AnyObject> = medal["prize"] as? Dictionary<String, AnyObject> where ((prize["prize_picture"] as? String) != nil) {
                        var prizeImageLink: String = prize["prize_picture"] as! String
                        prizeImageLink = NetworkController.sharedInstance.getImagesHost() + prizeImageLink
                        cell.imageViewPreview.kf_setImageWithResource(Resource(downloadURL: NSURL(string: prizeImageLink.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
                    }
                }
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        if indexPath.row == 0 {
            (cell as! ProfileTableViewCell).delegate = self
        }
        else {
            (cell as! GoalsTableViewCell).delegate = self
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return
        }
        
        if isGoals {
            // Goals
            if let goal: Dictionary<String, AnyObject> = self.goals[indexPath.row - 1] as? Dictionary<String, AnyObject> where (goal["video_id"] != nil) {
                let videoIdString: String = goal["video_id"] as! String
                Utilities.showPKHUDProgressView()
                NetworkController.sharedInstance.getVideoDetailsWithResponseBlock(Int(videoIdString)!, block: { (success, response) -> Void in
                    Utilities.hidePKHUDView()
                    if success {
                        if let videoDictionary: Dictionary<String, AnyObject> = response as? Dictionary<String, AnyObject> {
                            self.performSegueWithIdentifier(Constants.kProfileViewControllerToGoalViewControllerSegue, sender: videoDictionary)
                        }
                    }
                })
            }
        }
        else if isMedals {
            // Medals
            if let medal: Dictionary<String, AnyObject> = self.medals[indexPath.row - 1] as? Dictionary<String, AnyObject> where (medal["video_id"] != nil) {
                let videoIdString: String = medal["video_id"] as! String
                Utilities.showPKHUDProgressView()
                NetworkController.sharedInstance.getVideoDetailsWithResponseBlock(Int(videoIdString)!, block: { (success, response) -> Void in
                    Utilities.hidePKHUDView()
                    if success {
                        if let videoDictionary: Dictionary<String, AnyObject> = response as? Dictionary<String, AnyObject> {
                            self.performSegueWithIdentifier(Constants.kProfileViewControllerToGoalViewControllerSegue, sender: videoDictionary)
                        }
                    }
                })
            }
        }
        else if isPrizes{
            // Prizes
            if let prize: Dictionary<String, AnyObject> = self.prizes[indexPath.row - 1] as? Dictionary<String, AnyObject> where (prize["video_id"] != nil) {
                let videoIdString: String = prize["video_id"] as! String
                Utilities.showPKHUDProgressView()
                NetworkController.sharedInstance.getVideoDetailsWithResponseBlock(Int(videoIdString)!, block: { (success, response) -> Void in
                    Utilities.hidePKHUDView()
                    if success {
                        if let videoDictionary: Dictionary<String, AnyObject> = response as? Dictionary<String, AnyObject> {
                            self.performSegueWithIdentifier(Constants.kProfileViewControllerToGoalViewControllerSegue, sender: videoDictionary)
                        }
                    }
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            (cell as! ProfileTableViewCell).delegate = nil
        }
        else {
            (cell as! GoalsTableViewCell).delegate = nil
        }
    }
    
    // MARK: - GoalViewControllerDelegate
    
    func goalViewControllerIsBeingDismissedWithVideo(videoDictionary: Dictionary<String, AnyObject>) {
        if let dismissedVideo_id: String = videoDictionary["video_id"] as? String {
            var i = 0
            for video in self.goals {
                let videoId: String? = video["video_id"] as? String
                if videoId == dismissedVideo_id {
                    self.goals[i] = videoDictionary
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                    break
                }
                i++
            }
        }
    }
    
    // MARK: - ProfileTableViewCellDelegate
    
    func profileTableViewCellButtonGoals(sender: AnyObject) {
        isGoals = true
        isMedals = false
        isPrizes = false
        
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.correctContentOffset()
    }
    
    func profileTableViewCellButtonMedals(sender: AnyObject) {
        isGoals = false
        isMedals = true
        isPrizes = false
        
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.correctContentOffset()
    }
    
    func profileTableViewCellButtonPrizes(sender: AnyObject) {
        isGoals = false
        isMedals = false
        isPrizes = true
        
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.correctContentOffset()
    }
    
    // MARK: - GoalsTableViewCellDelegate
    
    func goalsTableViewCellButtonLike(tag: Int, sender: UIButton) {
        if isGoals {
            var goal: Dictionary<String, AnyObject>? = self.goals[tag-1] as? Dictionary<String, AnyObject>
            if (goal != nil) {
                if let userLiked: NSNumber = goal!["user_liked"] as? NSNumber {
                    if !userLiked.boolValue {
                        if let videoId: String = goal!["video_id"] as? String {
                            Utilities.showPKHUDProgressView()
                            
                            sender.enabled = false
                            NetworkController.sharedInstance.likeVideoWithIdAndResponseBlock(NSNumber(integer: Int(videoId)!), block: { (success, response) -> Void in
                                if success {
                                    
                                    sender.enabled = true
                                    Utilities.hidePKHUDViewWithSuccess("")
                                    var userLiked: NSNumber? = goal!["user_liked"] as? NSNumber
                                    if (userLiked != nil) {
                                        userLiked = NSNumber(bool: !(userLiked!.boolValue))
                                        goal!["user_liked"] = userLiked
                                    }
                                    if let likesCount: String = goal!["likes_count"] as? String {
                                        var id = Int(likesCount)!
                                        id++
                                        goal!["likes_count"] = String(id)
                                    }
                                    
                                    self.goals[tag-1] = goal!
                                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: tag-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                                }
                                else {
                                    Utilities.hidePKHUDViewWithError(nil)
                                }
                            })
                        }
                    }
                    else {
                        print("user already liked")
                    }
                }
            }
        }
        else if isMedals {
            var medal: Dictionary<String, AnyObject>? = self.medals[tag-1] as? Dictionary<String, AnyObject>
            if (medal != nil) {
                if let userLiked: NSNumber = medal!["user_liked"] as? NSNumber {
                    if !userLiked.boolValue {
                        if let videoId: String = medal!["video_id"] as? String {
                            Utilities.showPKHUDProgressView()
                            NetworkController.sharedInstance.likeVideoWithIdAndResponseBlock(NSNumber(integer: Int(videoId)!), block: { (success, response) -> Void in
                                if success {
                                    
                                    Utilities.hidePKHUDViewWithSuccess("")
                                    var userLiked: NSNumber? = medal!["user_liked"] as? NSNumber
                                    if (userLiked != nil) {
                                        userLiked = NSNumber(bool: !(userLiked!.boolValue))
                                        medal!["user_liked"] = userLiked
                                    }
                                    if let likesCount: String = medal!["likes_count"] as? String {
                                        var id = Int(likesCount)!
                                        id++
                                        medal!["likes_count"] = String(id)
                                    }
                                    
                                    self.medals[tag-1] = medal!
                                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: tag-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                                }
                                else {
                                    Utilities.hidePKHUDViewWithError(nil)
                                }
                            })
                        }
                    }
                    else {
                        print("user already liked")
                    }
                }
            }
        }
        else {
            
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.kProfileViewControllerToGoalViewControllerSegue {
            (segue.destinationViewController as! GoalViewController).goal = sender as? Dictionary<String, AnyObject>
            (segue.destinationViewController as! GoalViewController).delegate = self
        }
    }
    
    
    @IBAction func buttonEdit(sender: AnyObject) {
        let alertController = UIAlertController(title: "More", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        let logOutButton = UIAlertAction(title: "Log Out", style: .Default) { (action) in
            Settings.setUserLoggedIn(false)
            Settings.setUserLoggedInWithFacebook(false)
            Settings.removeEmail()
            Settings.removePassword()
            Settings.removeAccessTokenDictionary()
            Settings.deleteUserProfile()
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                (UIApplication.sharedApplication().delegate as! AppDelegate).userLoggedOut()
            })
            self.navigationController?.popToRootViewControllerAnimated(true)
            CATransaction.commit()
        }
        let editProfileButton = UIAlertAction(title: "Edit Profile", style: .Default) { (action) in
            self.performSegueWithIdentifier(Constants.kProfileViewControllerToProfileEditViewControllerSegue, sender: nil)
        }
        alertController.addAction(editProfileButton)
        alertController.addAction(logOutButton)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
