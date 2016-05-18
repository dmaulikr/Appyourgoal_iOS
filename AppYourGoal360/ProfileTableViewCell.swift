//
//  ProfileTableViewCell.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/23/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit

protocol ProfileTableViewCellDelegate: class {
    func profileTableViewCellButtonGoals(sender: AnyObject)
    func profileTableViewCellButtonMedals(sender: AnyObject)
    func profileTableViewCellButtonPrizes(sender: AnyObject)
}

class ProfileTableViewCell: UITableViewCell {
    
    weak var delegate : ProfileTableViewCellDelegate?

    @IBOutlet weak var buttonGoals: LoginButton!
    @IBOutlet weak var buttonMedals: LoginButton!
    @IBOutlet weak var buttonPrizes: LoginButton!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelExtra: UILabel!
    
    @IBOutlet weak var viewBackgroundColor: UIView!
    @IBOutlet weak var imageViewStripe: UIImageView!
    @IBOutlet weak var imageViewProfilPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.buttonGoals.setBackgroundColor(Constants.kLoginButtonHighlightedColor, forState: UIControlState.Selected)
        self.buttonGoals.setBackgroundColor(Constants.kLoginButtonDefaultColor, forState: UIControlState.Normal)
        self.buttonMedals.setBackgroundColor(Constants.kLoginButtonHighlightedColor, forState: UIControlState.Selected)
        self.buttonMedals.setBackgroundColor(Constants.kLoginButtonDefaultColor, forState: UIControlState.Normal)
        self.buttonPrizes.setBackgroundColor(Constants.kLoginButtonHighlightedColor, forState: UIControlState.Selected)
        self.buttonPrizes.setBackgroundColor(Constants.kLoginButtonDefaultColor, forState: UIControlState.Normal)
        self.buttonGoals.selected = true
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - IBActions and Actions
    
    @IBAction func buttonGoals(sender: AnyObject) {
        self.delegate?.profileTableViewCellButtonGoals(sender)
    }
    
    @IBAction func buttonMedals(sender: AnyObject) {
        self.delegate?.profileTableViewCellButtonMedals(sender)
    }
    
    @IBAction func buttonPrizes(sender: AnyObject) {
        self.delegate?.profileTableViewCellButtonPrizes(sender)
    }
    
}
