//
//  PrizePreviewViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 11/9/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit
import QuickLook
import Kingfisher

class PrizePreviewViewController: UIViewController, QLPreviewControllerDataSource {

    var urlToDisplay: NSURL!

    @IBOutlet weak var imageViewPrize: UIImageView!
    internal var prizeDictionary: Dictionary<String, AnyObject>?
    
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
        if (self.prizeDictionary != nil) {
            var prizeImageLink: String? = self.prizeDictionary!["prize_picture"] as? String
            if (prizeImageLink != nil) {
                prizeImageLink! = NetworkController.sharedInstance.getImagesHost() + prizeImageLink!
                self.imageViewPrize.kf_setImageWithResource(Resource(downloadURL: NSURL(string: prizeImageLink!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!), placeholderImage: UIImage(named: "ImageProfileAvatar"))
            }
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
    
    // MARK: - IBActions and Actions
    
    @IBAction func buttonContestRules(sender: AnyObject) {
        let previewController = QLPreviewController()
        let filePath = NSBundle.mainBundle().pathForResource("ContestRules", ofType: "docx")
        previewController.dataSource = self
        self.urlToDisplay = NSURL(fileURLWithPath: filePath!)
        self.presentViewController(previewController, animated: true, completion: nil)
    }
    
    @IBAction func buttonClose(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
