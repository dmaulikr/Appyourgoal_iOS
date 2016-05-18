//
//  VideoViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 10/7/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit
import MediaPlayer
import AssetsLibrary
import DKImagePickerController

class VideoViewController: UIViewController, UITextViewDelegate {
    
    var moviePlayer : MPMoviePlayerController!
    internal var assets: [DKAsset]?
    internal var filePath: String?

    @IBOutlet weak var buttonTitle: UIButton!
    @IBOutlet weak var buttonPostYourGoal: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var textViewLink: UITextView!
    @IBOutlet weak var viewMoviePlayer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Resize Player
        if let player = self.moviePlayer {
            player.view.frame = self.viewMoviePlayer.bounds
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func initialSetup() {
        
        // Set Delegate
        self.textViewLink.delegate = self
        
        // Setup Video
        if (self.filePath != nil) {
            
            // Recorded
            let url = NSURL.fileURLWithPath(self.filePath!)
            self.moviePlayer = MPMoviePlayerController(contentURL: url)
            if let player = self.moviePlayer {
                player.view.frame = self.viewMoviePlayer.bounds
                player.scalingMode = MPMovieScalingMode.AspectFill
                player.fullscreen = true
                player.controlStyle = MPMovieControlStyle.Default
                player.movieSourceType = MPMovieSourceType.File
                player.repeatMode = MPMovieRepeatMode.None
                player.play()
                self.viewMoviePlayer.addSubview(player.view)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerDidFinishPlaying:" , name: MPMoviePlayerPlaybackDidFinishNotification, object: self.moviePlayer)
            }
        }
        else if (self.assets != nil) {
            
            // Picked From Library
            let asset: DKAsset = self.assets!.first!
            let url = asset.url
            self.moviePlayer = MPMoviePlayerController(contentURL: url)
            if let player = self.moviePlayer {
                player.view.frame = self.viewMoviePlayer.bounds
                player.scalingMode = MPMovieScalingMode.AspectFill
                player.fullscreen = true
                player.controlStyle = MPMovieControlStyle.Default
                player.movieSourceType = MPMovieSourceType.File
                player.repeatMode = MPMovieRepeatMode.None
                player.play()
                self.viewMoviePlayer.addSubview(player.view)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerDidFinishPlaying:" , name: MPMoviePlayerPlaybackDidFinishNotification, object: self.moviePlayer)
            }
        }
        else {
            
            // URL
            self.moviePlayer = MPMoviePlayerController()
            if let player = self.moviePlayer {
                player.view.frame = self.viewMoviePlayer.bounds
                player.scalingMode = MPMovieScalingMode.AspectFill
                player.fullscreen = true
                player.controlStyle = MPMovieControlStyle.Default
                player.movieSourceType = MPMovieSourceType.Unknown
                player.repeatMode = MPMovieRepeatMode.None
                self.viewMoviePlayer.addSubview(player.view)
                self.viewMoviePlayer.bringSubviewToFront(self.textViewLink)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerDidFinishPlaying:" , name: MPMoviePlayerPlaybackDidFinishNotification, object: self.moviePlayer)
            }
            
            self.textViewLink.hidden = false
            self.buttonPostYourGoal.setTitle("PREVIEW VIDEO", forState: UIControlState.Normal)
        }
    }
    
    // MARK: - Notifications
    
    func moviePlayerDidFinishPlaying(notification: NSNotification) {
        
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false;
        }
        
        return true;
    }
    
    // MARK: - IBActions and Actions
    
    @IBAction func buttonCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func buttonPostYourGoal(sender: AnyObject) {
        if ((sender as! UIButton).titleLabel?.text == "PREVIEW VIDEO") {

            // Preview Video
            let urlString: String = self.textViewLink.text
            if urlString.characters.count > 0 {

                // Get Video Url
                let testURL = NSURL(string: urlString)!
                Youtube.h264videosWithYoutubeURL(testURL) { (videoInfo, error) -> Void in
                    let videoType = videoInfo?["type"] as? String
                    let videoURLString = videoInfo?["url"] as? String
                    if (videoURLString != nil) {
                        
                        if (videoType != nil) && videoType!.containsString("video/webm") {
                            Utilities.showUIAlertViewWithMessage("Video format seems to be unsupported by iOS. You can still post this video.")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // Adjust UI
                            self.buttonPostYourGoal.setTitle("POST YOUR GOAL", forState: UIControlState.Normal)
                            
                            // Preview Video
                            self.textViewLink.hidden = true
                            let url = NSURL(string: videoURLString!)
                            if let player = self.moviePlayer {
                                player.contentURL = url
                                player.prepareToPlay()
                                player.play()
                            }
                        })
                    }
                    else {
                        print(error)
                        Utilities.showUIAlertViewWithMessage("Pasted link seems to be invalid or the video format is unsupported... Make sure to copy/paste the correct link.")
                    }
                }
            }
            else {
                Utilities.showUIAlertViewWithMessage("Video link is required")
            }
        }
        else {
            
            // Post Your Goal
            if (self.filePath != nil) {
                
                // Recorded
                let url = NSURL.fileURLWithPath(self.filePath!)
                if let videoData: NSData = NSData(contentsOfURL: url) {
                    self.progressBar.hidden = false
                    self.progressBar.setProgress(0.0, animated: false)
                    self.viewMoviePlayer.bringSubviewToFront(self.progressBar)
                    Utilities.showPKHUDProgressView()
                    self.buttonPostYourGoal.enabled = false
                    NetworkController.sharedInstance.uploadVideoFromFileWithResponseBlock(videoData, progress: { (current, total) -> Void in
                        let progress: Float = Float(current.longLongValue) / Float(total.longLongValue)
                        self.progressBar.setProgress(progress, animated: true)
                    }, block: { (success, response) -> Void in
                        self.buttonPostYourGoal.enabled = true
                        self.progressBar.hidden = true
                        if success {
                            Utilities.hidePKHUDViewWithSuccess("Goal Posted")
                            self.buttonPostYourGoal.enabled = false
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                        }
                        else {
                            Utilities.hidePKHUDView()
                            Utilities.showUIAlertViewWithMessage("\(response)")
                        }
                    })
                }
            }
            else if (self.assets != nil) {
                
                // Picked From Library
                let asset: DKAsset = self.assets!.first!
                let url = asset.url
                let assetsLibrary: ALAssetsLibrary = ALAssetsLibrary()
                assetsLibrary.assetForURL(url, resultBlock: { asset -> Void in
                    let rep = asset.defaultRepresentation()
                    var error: NSError?
                    let length = Int(rep.size())
                    let from = Int64(0)
                    let videoData = NSMutableData(length: length)!
                    rep.getBytes(UnsafeMutablePointer(videoData.mutableBytes), fromOffset: from, length: length, error: &error)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.progressBar.hidden = false
                        self.progressBar.setProgress(0.0, animated: false)
                        self.viewMoviePlayer.bringSubviewToFront(self.progressBar)
                        Utilities.showPKHUDProgressView()
                        self.buttonPostYourGoal.enabled = false
                        NetworkController.sharedInstance.uploadVideoFromFileWithResponseBlock(videoData, progress: { (current, total) -> Void in
                            let progress: Float = Float(current.longLongValue) / Float(total.longLongValue)
                            self.progressBar.setProgress(progress, animated: true)
                            }, block: { (success, response) -> Void in
                                self.buttonPostYourGoal.enabled = true
                                self.progressBar.hidden = true
                                if success {
                                    Utilities.hidePKHUDViewWithSuccess("Goal Posted")
                                    self.buttonPostYourGoal.enabled = false
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                                        self.navigationController?.popViewControllerAnimated(true)
                                    })
                                }
                                else {
                                    Utilities.hidePKHUDView()
                                    Utilities.showUIAlertViewWithMessage("\(response)")
                                }
                        })
                    })
                    
                }, failureBlock: { error -> Void in
                    Utilities.showUIAlertViewWithMessage("Could not use selected video.")
                })
            }
            else {
                
                // URL
                if let urlString: String = self.textViewLink.text {
                    Utilities.showPKHUDProgressView()
                    self.buttonPostYourGoal.enabled = false
                    NetworkController.sharedInstance.uploadVideoFromLinkWithResponseBlock(urlString, block: { (success, response) -> Void in
                        self.buttonPostYourGoal.enabled = true
                        if success {
                            Utilities.hidePKHUDViewWithSuccess("Goal Posted")
                            self.buttonPostYourGoal.enabled = false
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                        }
                        else {
                            Utilities.hidePKHUDView()
                            Utilities.showUIAlertViewWithMessage("\(response)")
                        }
                    })
                }
            }
        }
    }
}
