//
//  UploadViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/22/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import DKImagePickerController

class UploadViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    let captureSession: AVCaptureSession = AVCaptureSession()
    var captureDeviceVideo: AVCaptureDevice?
    var captureDeviceAudio: AVCaptureDevice?
    var captureFileOutput: AVCaptureMovieFileOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var timer = NSTimer()
    var timerTime = 0
    var assets: [DKAsset]?
    var filePath: String?
    
    @IBOutlet weak var buttonCancel: UIBarButtonItem!
    @IBOutlet weak var buttonFlash: UIBarButtonItem!
    @IBOutlet weak var buttonTime: UIButton!
    @IBOutlet weak var buttonPhotoLibrary: UIButton!
    @IBOutlet weak var buttonRecord: UIButton!
    @IBOutlet weak var buttonPasteLink: UIButton!
    
    @IBOutlet weak var viewCameraPreviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewCameraPreview: UIView!
    @IBOutlet weak var viewControls: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        self.avCaptureSessionSetup()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.addObserver(self, forKeyPath: "self.captureSession.running", options: NSKeyValueObservingOptions.New, context: nil)
        self.viewCameraPreviewBottomConstraint.constant = -self.viewCameraPreview.frame.height
        self.previewLayer!.opacity = 0.0
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.beginSession()
        self.buttonCancel.enabled = true
        self.assets = nil
        self.filePath = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver(self, forKeyPath: "self.captureSession.running")
        self.stopSession()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Private
    
    func initialSetup() {
        let textAttributes: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "DINBold", size: 15.0)!, NSForegroundColorAttributeName: Constants.kActionBlueColor]
        self.navigationItem.leftBarButtonItem!.setTitleTextAttributes(textAttributes, forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes(textAttributes, forState: UIControlState.Normal)
        
        // Set Images
        self.getLatestPhotos { (let images: [UIImage]) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.buttonPhotoLibrary.setImage(images.first, forState: UIControlState.Normal)
            })
        }
    }
    
    func getLatestPhotos(completion completionBlock : ([UIImage] -> ()))   {
        let library = ALAssetsLibrary()
        var count = 0
        var images : [UIImage] = []
        var stopped = false
        
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: { (group, let stop) -> Void in
            
            group?.setAssetsFilter(ALAssetsFilter.allVideos())
            
            group?.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: {
                (asset : ALAsset!, index, let stopEnumeration) -> Void in
                
                if (!stopped) {
                    if count >= 1 {
                        
                        stopEnumeration.memory = ObjCBool(true)
                        stop.memory = ObjCBool(true)
                        completionBlock(images)
                        stopped = true
                    }
                    else {
                        // For just the thumbnails use the following line.
                        let cgImage = asset.thumbnail().takeUnretainedValue()
                        let image: UIImage? = UIImage(CGImage: cgImage)

                        
                        if (image != nil) {
                            images.append(image!)
                            count += 1
                        }
                    }
                }
                
            })
            
            },failureBlock : { error in
                print(error)
        })
    }
    
    func avCaptureSessionSetup() {
        
        // Setup AVCapture Session and find Input Device
        
        self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.Back) {
                    self.captureDeviceVideo = device as? AVCaptureDevice
                }
            }
            if (device.hasMediaType(AVMediaTypeAudio)) {
                self.captureDeviceAudio = device as? AVCaptureDevice
            }
        }
        
        // Add Capture Devices
        if (self.captureDeviceVideo != nil && self.captureDeviceAudio != nil) {
            do {
                
                // Add Output File
                self.captureFileOutput = AVCaptureMovieFileOutput()
                self.captureSession.addOutput(self.captureFileOutput)
                
                // Add Video Capture Device
                try captureSession.addInput(AVCaptureDeviceInput(device: self.captureDeviceVideo))
                
                self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.previewLayer!.opacity = 0.0
                
                self.viewCameraPreview.layer.addSublayer(previewLayer!)
                self.viewCameraPreview.bringSubviewToFront(self.viewControls)
                previewLayer?.frame = self.view.layer.frame
            
                // Add Audio Capture Device
                try captureSession.addInput(AVCaptureDeviceInput(device: self.captureDeviceAudio))
            }
            catch _ {
                print("Could not add input")
            }
        }
    }
    
    func beginSession() {
        if !captureSession.running {
            captureSession.startRunning()
        }
    }
    
    func stopSession() {
        
        // Stop AVCApture Session
        if captureSession.running {
            captureSession.stopRunning()
            self.previewLayer!.opacity = 0.0
        }
    }
    
    func startRecording() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        
        self.filePath = "\(documentsDirectory)/tempVideo.mp4"
        
        self.captureFileOutput!.startRecordingToOutputFileURL(NSURL(fileURLWithPath: filePath!), recordingDelegate: self)
    }
    
    func stopRecording() {
        self.captureFileOutput!.stopRecording()
    }
    
    func timerTick() {
        timerTime++
        self.buttonTime.setTitle(String(format: "%02d:%02d", timerTime/60, timerTime%60), forState: UIControlState.Normal)
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "self.captureSession.running") {
            
            let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = NSNumber(float: 0.0)
            animation.toValue = NSNumber(float: 1.0)
            animation.duration = 0.5
            animation.fillMode = kCAFillModeForwards
            animation.removedOnCompletion = false
            self.previewLayer?.addAnimation(animation, forKey: "opacityAnimation")
            
            self.view.layoutIfNeeded()
            self.viewCameraPreviewBottomConstraint.constant = 0.0
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.bringSubviewToFront(self.viewCameraPreview)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        timerTime = 0
        self.buttonTime.setTitle(String(format: "%02d:%02d", timerTime/60, timerTime%60), forState: UIControlState.Normal)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerTick", userInfo: nil, repeats: true)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        self.timer.invalidate()
        
        // Move to VideoViewController
        self.performSegueWithIdentifier(Constants.kUploadViewControllerToVideoViewControllerSegue, sender: nil)
        
        // Animate Controlls
        self.view.layoutIfNeeded()
        self.viewCameraPreviewBottomConstraint.constant = -self.viewCameraPreview.frame.height
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.kUploadViewControllerToVideoViewControllerSegue {
            if (self.filePath != nil) {
                // Recorded
                (segue.destinationViewController as? VideoViewController)?.filePath = self.filePath!
            }
            else if (self.assets != nil) {
                // Picked From Library
                (segue.destinationViewController as? VideoViewController)?.assets = self.assets!
            }
            else {
                // URL
                print("URL")
            }
        }
    }
    
    // MARK: - IBActions and Actions

    @IBAction func buttonCancel(sender: AnyObject) {
        self.stopSession()
        self.buttonCancel.enabled = false
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        // Animate Controlls
        self.view.layoutIfNeeded()
        self.viewCameraPreviewBottomConstraint.constant = -self.viewCameraPreview.frame.height
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func buttonFlash(sender: AnyObject) {
        if (self.buttonFlash.title == "Flash On") {
            do {
                try self.captureDeviceVideo!.lockForConfiguration()
                self.captureDeviceVideo!.torchMode = AVCaptureTorchMode.Off
                self.captureDeviceVideo!.unlockForConfiguration()
            }
            catch let error {
                print("Error changing Torch settings. \(error)")
            }
            
            self.buttonFlash.title = "Flash Off"
        }
        else if ((self.captureDeviceVideo!.hasTorch)){
            do {
                try self.captureDeviceVideo!.lockForConfiguration()
                self.captureDeviceVideo!.torchMode = AVCaptureTorchMode.On
                self.captureDeviceVideo!.unlockForConfiguration()
            }
            catch let error {
                print("Error changing Torch settings. \(error)")
            }
            
            self.buttonFlash.title = "Flash On"
        }
    }
    
    @IBAction func buttonPhotoLibrary(sender: AnyObject) {
        let pickerController = DKImagePickerController()
        pickerController.assetType = DKImagePickerControllerAssetType.allVideos
        pickerController.maxSelectableCount = 1
        pickerController.sourceType = DKImagePickerControllerSourceType.Photo
        pickerController.navigationBar.translucent = false
        pickerController.navigationBar.barStyle = UIBarStyle.Default
        pickerController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        
        pickerController.didCancelled = { () in
            print("didCancelled")
        }
        
        pickerController.didSelectedAssets = { [unowned self](assets: [DKAsset]) in
            self.assets = assets
            
            // Move to VideoViewController
            self.performSegueWithIdentifier(Constants.kUploadViewControllerToVideoViewControllerSegue, sender: nil)
            
            // Animate Controlls
            self.view.layoutIfNeeded()
            self.viewCameraPreviewBottomConstraint.constant = -self.viewCameraPreview.frame.height
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        
        self.stopSession()
        self.presentViewController(pickerController, animated: true) {}
    }
    
    @IBAction func buttonRecord(sender: AnyObject) {
        if !self.buttonRecord.selected {
            self.startRecording()
        }
        else {
            self.stopRecording()
        }
        
        self.buttonRecord.selected = !self.buttonRecord.selected
    }
    
    @IBAction func buttonPasteLink(sender: AnyObject) {
        self.performSegueWithIdentifier(Constants.kUploadViewControllerToVideoViewControllerSegue, sender: nil)
        
        // Animate Controlls
        self.view.layoutIfNeeded()
        self.viewCameraPreviewBottomConstraint.constant = -self.viewCameraPreview.frame.height
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
