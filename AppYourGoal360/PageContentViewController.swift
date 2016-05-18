//
//  PageContentViewController.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/17/15.
//  Copyright (c) 2015 Borne. All rights reserved.
//

import UIKit

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

class PageContentViewController: UIViewController {

    var pageIndex: Int!
    var stringMessage: String!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelMessageLeftConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }

    func initialSetup() {
        
        // Setup Constraint
        if DeviceType.IS_IPHONE_6 {
            self.labelMessageLeftConstraint.constant = 90
        }
        else if DeviceType.IS_IPHONE_6P {
            self.labelMessageLeftConstraint.constant = 110
        }
        
        // Setup Attributed String
        let paraghaph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paraghaph.alignment = NSTextAlignment.Left
        paraghaph.paragraphSpacing = -16.0;
        
        var font = self.labelMessage.font
        if self.stringMessage.characters.count > 50 {
            font = UIFont(name: "DINBold", size: 20.0)!
            paraghaph.alignment = NSTextAlignment.Center
            self.labelMessageLeftConstraint.constant = 16
        }
        let attributes = [NSFontAttributeName: font,
                          NSForegroundColorAttributeName: UIColor.whiteColor(),
                          NSParagraphStyleAttributeName: paraghaph]
        
        let attributedString: NSAttributedString = NSAttributedString(string: self.stringMessage, attributes: attributes)
        
        self.labelMessage.attributedText = attributedString
        self.labelMessage.sizeToFit()
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
