//
//  NotificationsViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 11/10/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var notifications: Array<AnyObject> = Array<AnyObject>()
    let cellDateFormatter: NSDateFormatter = NSDateFormatter()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }

    func initialSetup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // ---- Setup DateFormatter
        self.cellDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.cellDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: -14400)
        
        // ---- Load Notifications
        NetworkController.sharedInstance.getAllNotificationsWithResponseBlock { (success, response) -> Void in
            if success {
                if let notifications: Array<AnyObject> = response as? Array<AnyObject> where notifications.count > 0 {
                    self.notifications = notifications
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.kNotificationTableViewCell, forIndexPath: indexPath) 
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.contentView.backgroundColor = UIColor(red: 20.0/256.0, green: 21.0/256.0, blue: 23.0/256.0, alpha: 1.0)
        if (indexPath.row % 2) == 0 {
            cell.contentView.backgroundColor = UIColor(red: 17.0/256.0, green: 18.0/256.0, blue: 19.0/256.0, alpha: 1.0)
        }
        
        if let notification: Dictionary<String, AnyObject> = self.notifications[indexPath.row] as? Dictionary<String, AnyObject> {
            let labelTitle: UILabel = cell.viewWithTag(1) as! UILabel
            let labelTime: UILabel = cell.viewWithTag(2) as! UILabel
            
            labelTitle.text = notification["notification_text"] as? String
            if let dateString: String = notification["date"] as? String {
                let date = self.cellDateFormatter.dateFromString(dateString)
                labelTime.text = Utilities.timeAgoSinceDate(date!, numericDates: true)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
