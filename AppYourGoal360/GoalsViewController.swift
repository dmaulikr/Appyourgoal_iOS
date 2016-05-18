//
//  GoalsViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/22/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit
import Kingfisher

class GoalsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GoalsTableViewCellDelegate, GoalViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonFilter: UIButton!
    
    @IBOutlet weak var viewOptionsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonOption: UIButton!
    
    var refreshControl: UIRefreshControl?
    var goals: Array <AnyObject> = Array <AnyObject>()
    let goalsDateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        self.setupPullToRefresh()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Private

    func initialSetup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        self.goalsDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.goalsDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: -14400)
        
        // Load Videos
        Utilities.showPKHUDProgressView()
        NetworkController.sharedInstance.getAllVideosWithResponseBlock(NetworkController.AllVideosSortType.None, limit: nil) { (success, response) -> Void in
            Utilities.hidePKHUDView()
            if success {
                if let goals: Array<AnyObject> = response as? Array<AnyObject> where goals.count > 0 {
                    self.goals = goals.sort({ (self.goalsDateFormatter.dateFromString(($0["date"] as! String))! as NSDate).timeIntervalSinceNow > (self.goalsDateFormatter.dateFromString(($1["date"] as! String))! as NSDate).timeIntervalSinceNow})
                    self.tableView.reloadData()
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
    
    func setupPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
    }
    
    func refresh() {
        NetworkController.sharedInstance.getAllVideosWithResponseBlock(NetworkController.AllVideosSortType.None, limit: nil) { (success, response) -> Void in
            self.refreshControl?.endRefreshing()
            if success {
                if let goals: Array<AnyObject> = response as? Array<AnyObject> where goals.count > 0 {
                    self.goals = goals
                    self.tableView.reloadData()
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
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.goals.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.size.width
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: GoalsTableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.kGoalsTableViewCell, forIndexPath: indexPath) as! GoalsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.tag = indexPath.row
        
        if let goal: Dictionary<String, AnyObject> = self.goals[indexPath.row] as? Dictionary<String, AnyObject> {
//            print(goal)
            var profileImageLink: String? = goal["user"]?["profile_picture"] as? String
            if (profileImageLink != nil) {
                profileImageLink! = NetworkController.sharedInstance.getImagesHost() + profileImageLink!
                cell.imageViewProfilePicture.kf_setImageWithResource(Resource(downloadURL: NSURL(string: profileImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
            }
            cell.labelName.text = goal["user"]?["first_name"] as? String
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        (cell as! GoalsTableViewCell).delegate = self
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let goal: Dictionary<String, AnyObject> = self.goals[indexPath.row] as? Dictionary<String, AnyObject> {
            self.performSegueWithIdentifier(Constants.kGoalsViewControllerToGoalViewControllerSegue, sender: goal)
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! GoalsTableViewCell).delegate = nil
    }
    
    // MARK: - GoalsTableViewCellDelegate
    
    func goalsTableViewCellButtonLike(tag: Int, sender: UIButton) {
        var goal: Dictionary<String, AnyObject>? = self.goals[tag] as? Dictionary<String, AnyObject>
        if (goal != nil) {
            if let userLiked: NSNumber = goal!["user_liked"] as? NSNumber {
                if !userLiked.boolValue {
                    if let videoId: String = goal!["video_id"] as? String {
                        
                        sender.enabled = false
                        Utilities.showPKHUDProgressView()
                        NetworkController.sharedInstance.likeVideoWithIdAndResponseBlock(NSNumber(integer: Int(videoId)!), block: { (success, response) -> Void in
                            sender.enabled = true
                            if success {
                                
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
                                
                                self.goals[tag] = goal!
                                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: tag, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
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
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == Constants.kGoalsViewControllerToProfileViewControllerSegue) {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
        }
        else if (segue.identifier == Constants.kGoalsViewControllerToGoalViewControllerSegue) {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
            (segue.destinationViewController as! GoalViewController).goal = sender as? Dictionary<String, AnyObject>
            (segue.destinationViewController as! GoalViewController).delegate = self
        }
        else {
            segue.destinationViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    // MARK: - IBActions and Actions
    
    @IBAction func buttonProfile(sender: AnyObject) {
        self.performSegueWithIdentifier(Constants.kGoalsViewControllerToProfileViewControllerSegue, sender: nil)
    }
    
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
        if self.buttonFilter.titleLabel?.text == "Most Recent" {
            // Show Most Liked
            self.goals = self.goals.sort({ Int($0["likes_count"] as! String) > Int($1["likes_count"] as! String)})
            self.tableView.reloadData()
            filterTitleToSet = "Most Liked"
            optionTitleToSet = "Most Recent"
        }
        else {
            // Show Most Recent
            self.goals = self.goals.sort({ (self.goalsDateFormatter.dateFromString(($0["date"] as! String))! as NSDate).timeIntervalSinceNow > (self.goalsDateFormatter.dateFromString(($1["date"] as! String))! as NSDate).timeIntervalSinceNow})
            self.tableView.reloadData()
            filterTitleToSet = "Most Recent"
            optionTitleToSet = "Most Liked"
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
    
    @IBAction func buttonNotifications(sender: AnyObject) {
        self.performSegueWithIdentifier(Constants.kGoalsViewControllerToNotificationsViewControllerSegue, sender: nil)
    }
    
}
