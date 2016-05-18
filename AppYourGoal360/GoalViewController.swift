//
//  GoalViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/28/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit
import Kingfisher
import MediaPlayer
import IQKeyboardManagerSwift

protocol GoalViewControllerDelegate: class {
    func goalViewControllerIsBeingDismissedWithVideo(videoDictionary: Dictionary<String, AnyObject>)
}

class GoalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var delegate : GoalViewControllerDelegate?
    
    internal var goal: Dictionary<String, AnyObject>?
    internal var winner: Dictionary<String, AnyObject>?
    var comments: Array<AnyObject> = Array<AnyObject>()
    let cellDateFormatter: NSDateFormatter = NSDateFormatter()
    var youtubeId: String?
    var videoId: String?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeader: UIView!
    
    @IBOutlet weak var imageViewProfilePicture: UIImageView!
    @IBOutlet weak var imageViewPreview: UIImageView!
    @IBOutlet weak var imageViewLike: UIImageView!
    @IBOutlet weak var imageViewComment: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLikes: UILabel!
    @IBOutlet weak var labelWeekLikes: UILabel!
    @IBOutlet weak var labelComments: UILabel!
    @IBOutlet weak var textFieldComment: UITextField!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.delegate != nil) {
            if (self.winner != nil) {
                self.delegate!.goalViewControllerIsBeingDismissedWithVideo(self.winner!)
            }
            else if (self.goal != nil) {
                self.delegate!.goalViewControllerIsBeingDismissedWithVideo(self.goal!)
            }
        }
    }
    
    func initialSetup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.textFieldComment.delegate = self
        
        self.labelWeekLikes.layer.borderColor = self.labelWeekLikes.textColor.CGColor
        self.labelWeekLikes.layer.borderWidth = 1.0
        
        // ---- Resize Header
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let frame = CGRectMake(0, 0, screenSize.width, screenSize.width + 42)
        self.tableViewHeader.frame = frame
        self.tableView.tableHeaderView = self.tableViewHeader
        
        // ---- Setup DateFormatter
        self.cellDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.cellDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: -14400)
        
        // ---- Setup Video
        self.setupVideo()
    }
    
    func setupVideo() {
        if let videoDictionary = self.winner {
            
            var profileImageLink: String? = videoDictionary["user"]?["profile_picture"] as? String
            if (profileImageLink != nil) {
                profileImageLink! = NetworkController.sharedInstance.getImagesHost() + profileImageLink!
                self.imageViewProfilePicture.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
            }
            self.labelName.text = videoDictionary["user"]?["first_name"] as? String
            self.labelLikes.text = videoDictionary["likes_no"] as? String
            if let weekLikes = videoDictionary["week_likes"] as? String {
                self.labelWeekLikes.text = " \(weekLikes) "
            }
            if let userLiked: NSNumber = videoDictionary["user_liked"] as? NSNumber {
                self.imageViewLike.highlighted = userLiked.boolValue
                self.buttonLike.selected = userLiked.boolValue
                self.labelLikes.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
                self.labelWeekLikes.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
                self.labelWeekLikes.layer.borderColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor.CGColor : Constants.kDefaultButtonTextColor.CGColor
            }
            if let userCommented: NSNumber = videoDictionary["user_commented"] as? NSNumber {
                self.imageViewComment.highlighted = userCommented.boolValue
                self.labelComments.textColor = userCommented.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
            }
            if let comments: Array<AnyObject> = videoDictionary["comments"] as? Array<AnyObject> {
                self.comments = comments.sort({ (self.cellDateFormatter.dateFromString(($0["date"] as! String))! as NSDate).timeIntervalSinceNow > (self.cellDateFormatter.dateFromString(($1["date"] as! String))! as NSDate).timeIntervalSinceNow})
                self.labelComments.text = String(comments.count)
            }
            if let youtubeId: String = videoDictionary["youtube_id"] as? String {
                self.youtubeId = youtubeId
                self.buttonPlay.enabled = true
                self.imageViewPreview.kf_setImageWithResource(Resource(downloadURL: NetworkController.sharedInstance.videoPreviewLinkForVideoId(youtubeId)), placeholderImage: UIImage(named: ""))
            }
            if let videoId: String = videoDictionary["video_id"] as? String {
                self.videoId = videoId
            }
        }
        else if let videoDictionary = self.goal {
            
            var profileImageLink: String? = videoDictionary["user"]?["profile_picture"] as? String
            if (profileImageLink != nil) {
                profileImageLink! = NetworkController.sharedInstance.getImagesHost() + profileImageLink!
                self.imageViewProfilePicture.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
            }
            self.labelName.text = videoDictionary["user"]?["first_name"] as? String
            self.labelLikes.text = videoDictionary["likes_count"] as? String
            if let weekLikes = videoDictionary["week_likes"] as? String {
                self.labelWeekLikes.text = " \(weekLikes) "
            }
            if let userLiked: NSNumber = videoDictionary["user_liked"] as? NSNumber {
                self.imageViewLike.highlighted = userLiked.boolValue
                self.buttonLike.selected = userLiked.boolValue
                self.labelLikes.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
                self.labelWeekLikes.textColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
                self.labelWeekLikes.layer.borderColor = userLiked.boolValue ? Constants.kGoldenButtonTextColor.CGColor : Constants.kDefaultButtonTextColor.CGColor
            }
            if let userCommented: NSNumber = videoDictionary["user_commented"] as? NSNumber {
                self.imageViewComment.highlighted = userCommented.boolValue
                self.labelComments.textColor = userCommented.boolValue ? Constants.kGoldenButtonTextColor : Constants.kDefaultButtonTextColor
            }
            if let comments: Array<AnyObject> = videoDictionary["comments"] as? Array<AnyObject> {
                self.comments = comments.sort({ (self.cellDateFormatter.dateFromString(($0["date"] as! String))! as NSDate).timeIntervalSinceNow > (self.cellDateFormatter.dateFromString(($1["date"] as! String))! as NSDate).timeIntervalSinceNow})
                self.labelComments.text = String(comments.count)
            }
            if let youtubeId: String = videoDictionary["youtube_id"] as? String {
                self.youtubeId = youtubeId
                self.buttonPlay.enabled = true
                self.imageViewPreview.kf_setImageWithResource(Resource(downloadURL: NetworkController.sharedInstance.videoPreviewLinkForVideoId(youtubeId)), placeholderImage: UIImage(named: ""))
            }
            if let videoId: String = videoDictionary["video_id"] as? String {
                self.videoId = videoId
            }
        }
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if let comment: Dictionary<String, AnyObject> = self.comments[indexPath.row] as? Dictionary<String, AnyObject> {
            if let user: Dictionary<String, AnyObject> = comment["user"] as? Dictionary <String, AnyObject>, let currentUser = Settings.userProfile() where user["user_id"] as? String == currentUser["user_id"] as? String {
                let deleteAction = UITableViewRowAction(style: .Default, title: "DELETE") { (action, indexPath) -> Void in
                    
                    // Delete Comment
                    if let commentId = comment["comment_id"] as? String {
                        Utilities.showPKHUDProgressView()
                        NetworkController.sharedInstance.deleteCommentWithId(commentId, block: { (success, response) -> Void in
                            Utilities.hidePKHUDView()
                            if success {
                                self.comments.removeAtIndex(indexPath.row)
                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                            }
                            else {
                                Utilities.showUIAlertViewWithMessage("\(response)")
                            }
                        })
                    }
                    else {
                        tableView.setEditing(false, animated: true)
                    }
                }
                deleteAction.backgroundColor = UIColor(colorLiteralRed: 227.0/256.0, green: 110.0/256.0, blue: 83.0/256.0, alpha: 1.0)
                return [deleteAction]
            }
            else {
                let reportAction = UITableViewRowAction(style: .Normal, title: "FLAG") { (action, indexPath) -> Void in
                    
                    // Report Comment
                    if let commentId = comment["comment_id"] as? String {
                        Utilities.showPKHUDProgressView()
                        NetworkController.sharedInstance.reportCommentWithId(commentId, block: { (success, response) -> Void in
                            Utilities.hidePKHUDView()
                            if success {
                                Utilities.showUIAlertViewWithMessage("You have successfully flagged this comment")
                                tableView.setEditing(false, animated: true)
                            }
                            else {
                                Utilities.showUIAlertViewWithMessage("\(response)")
                            }
                        })
                    }
                    else {
                        tableView.setEditing(false, animated: true)
                    }
                }
                
                reportAction.backgroundColor = UIColor(colorLiteralRed: 229.0/256.0, green: 223.0/256.0, blue: 58.0/256.0, alpha: 1.0)
                return [reportAction]
            }
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CommentTableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.kCommentTableViewCell, forIndexPath: indexPath) as! CommentTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.contentView.backgroundColor = UIColor(red: 20.0/256.0, green: 21.0/256.0, blue: 23.0/256.0, alpha: 1.0)
        if (indexPath.row % 2) == 0 {
            cell.contentView.backgroundColor = UIColor(red: 17.0/256.0, green: 18.0/256.0, blue: 19.0/256.0, alpha: 1.0)
        }
        
        
        if let comment: Dictionary<String, AnyObject> = self.comments[indexPath.row] as? Dictionary<String, AnyObject> {
//            print(comment)
            cell.labelComment.text = comment["comment_text"] as? String
            if let dateString: String = comment["date"] as? String {
                let date = self.cellDateFormatter.dateFromString(dateString)
                cell.labelTimeAgo.text = Utilities.timeAgoSinceDate(date!, numericDates: true)
            }
            if let user: Dictionary<String, AnyObject> = comment["user"] as? Dictionary <String, AnyObject> {
                var profileImageLink: String? = user["profile_picture"] as? String
                if (profileImageLink != nil) {
                    profileImageLink = NetworkController.sharedInstance.getImagesHost() + profileImageLink!
                    cell.labelName.text = user["first_name"] as? String
                    cell.imageViewProfilePicture.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - Notifications
    
    func moviePlayerDidFinishPlaying(notification: NSNotification) {
        if (self.presentedViewController != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                self.presentedViewController?.dismissMoviePlayerViewControllerAnimated()
            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func buttonPlay(sender: AnyObject) {
        let testURL = NSURL(string: "https://www.youtube.com/watch?v=\(self.youtubeId!)")!
        Youtube.h264videosWithYoutubeURL(testURL) { (videoInfo, error) -> Void in
            let videoType = videoInfo?["type"] as? String
            let videoURLString = videoInfo?["url"] as? String
            if (videoURLString != nil) && (videoType != "video/webm") {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Preview Video
                    print("playing...");
                    let url = NSURL(string: videoURLString!)
                    let moviePlayerController: MPMoviePlayerViewController = MPMoviePlayerViewController(contentURL: url)
                    moviePlayerController.moviePlayer.play()
                    moviePlayerController.moviePlayer.fullscreen = true
                    moviePlayerController.moviePlayer.controlStyle = MPMovieControlStyle.Fullscreen
                    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceType.Unknown
                    moviePlayerController.moviePlayer.repeatMode = MPMovieRepeatMode.None
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerDidFinishPlaying:" , name: MPMoviePlayerPlaybackDidFinishNotification, object: moviePlayerController.moviePlayer)
                    self.presentViewController(moviePlayerController, animated: true, completion: nil)
                })
            }
            else {
                print("ERROR: \(error)")
                Utilities.showUIAlertViewWithMessage("Pasted link seems to be invalid or the video format is unsupported.. Make sure to copy/paste the correct link.")
            }
        }
    }
    
    @IBAction func buttonLike(sender: UIButton) {
        var theVideoDictionary: Dictionary<String, AnyObject>?
        if let videoDictionary = self.winner {
            theVideoDictionary = videoDictionary
        }
        else if let videoDictionary = self.goal {
            theVideoDictionary = videoDictionary
        }
        
        if (theVideoDictionary != nil) {
            if let userLiked: NSNumber = theVideoDictionary!["user_liked"] as? NSNumber {
                if !userLiked.boolValue {
                    if let videoId: String = theVideoDictionary!["video_id"] as? String {
                        sender.enabled = false
                        Utilities.showPKHUDProgressView()
                        NetworkController.sharedInstance.likeVideoWithIdAndResponseBlock(NSNumber(integer: Int(videoId)!), block: { (success, response) -> Void in
                            sender.enabled = true
                            if success {
                                Utilities.hidePKHUDViewWithSuccess("")
                                var userLiked: NSNumber? = theVideoDictionary!["user_liked"] as? NSNumber
                                if (userLiked != nil) {
                                    userLiked = NSNumber(bool: !(userLiked!.boolValue))
                                    theVideoDictionary!["user_liked"] = userLiked
                                }
                                if let likesCount: String = theVideoDictionary!["likes_count"] as? String {
                                    var id = Int(likesCount)!
                                    id++
                                    theVideoDictionary!["likes_count"] = String(id)
                                }
                                
                                if (self.winner != nil) {
                                    self.winner = theVideoDictionary
                                }
                                else if (self.goal != nil) {
                                    self.goal = theVideoDictionary
                                }
                                self.setupVideo()
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
    
    @IBAction func buttonPost(sender: AnyObject) {
        if let comment: String = self.textFieldComment.text where comment.characters.count > 0 {
            
            NetworkController.sharedInstance.commentOnAVideoWithIdAndResponseBlock(NSNumber(integer: Int(self.videoId!)!), comment: comment, block: { (success, response) -> Void in
                if success {
                    self.textFieldComment.text = ""
                    self.textFieldComment.resignFirstResponder()
                    var comment: Dictionary<String, AnyObject>? = response as? Dictionary<String, AnyObject>
                    if (comment != nil) {
                        comment!["date"] = self.cellDateFormatter.stringFromDate(NSDate())
                        self.comments.insert(comment!, atIndex: 0)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                        
                        // Setup Video
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                            if (self.winner != nil) {
                                self.winner!["comments"] = self.comments
                                self.winner!["user_commented"] = NSNumber(bool: true)
                            }
                            else if (self.goal != nil) {
                                self.goal!["comments"] = self.comments
                                self.goal!["user_commented"] = NSNumber(bool: true)
                            }
                            self.setupVideo()
                        })
                    }
                }
                else {
                    Utilities.showUIAlertViewWithMessage("\(response)")
                }
            })
        }
        else {
            Utilities.showUIAlertViewWithMessage("Please, type your comment first.")
        }
    }
    
    @IBAction func buttonShare(sender: AnyObject) {
        
        let textToShare = "AppYourGoal is awesome! Check out this Video:"
        if let myWebsite = NSURL(string: "https://www.youtube.com/watch?v=\(self.youtubeId!)") {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
}
