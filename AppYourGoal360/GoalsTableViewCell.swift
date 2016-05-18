//
//  GoalsTableViewCell.swift
//  AppYourGoal360
//
//  Created by Jovan Jovanovic on 9/22/15.
//  Copyright © 2015 Borne. All rights reserved.
//

import UIKit

protocol GoalsTableViewCellDelegate: class {
    func goalsTableViewCellButtonLike(tag: Int, sender: UIButton)
}

class GoalsTableViewCell: UITableViewCell {

    weak var delegate : GoalsTableViewCellDelegate?
    
    @IBOutlet weak var imageViewPreview: UIImageView!
    @IBOutlet weak var imageViewProfilePicture: UIImageView!
    @IBOutlet weak var imageViewLike: UIImageView!
    @IBOutlet weak var imageViewComment: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLikes: UILabel!
    @IBOutlet weak var labelWeekLikes: UILabel!
    @IBOutlet weak var labelComments: UILabel!
    @IBOutlet weak var buttonLike: UIButton!
    
    @IBOutlet weak var imageViewMedal: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelWeekLikes.layer.borderColor = self.labelWeekLikes.textColor.CGColor
        self.labelWeekLikes.layer.borderWidth = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func resetContent() {
        self.imageViewPreview.image = nil
        self.imageViewProfilePicture.image = nil
        self.imageViewLike.highlighted = false
        self.imageViewComment.highlighted = false
        self.labelName.text = ""
        self.labelLikes.text = ""
        self.labelLikes.textColor = Constants.kDefaultButtonTextColor
        self.labelWeekLikes.text = ""
        self.labelWeekLikes.textColor = Constants.kDefaultButtonTextColor
        self.labelComments.text = ""
        self.buttonLike.selected = false
        self.imageViewMedal.hidden = true
        self.labelComments.hidden = false
        self.labelLikes.hidden = false
        self.labelName.hidden = false
        self.buttonLike.hidden = false
        self.imageViewComment.hidden = false
        self.imageViewLike.hidden = false
    }
    
    func setLabelsSelected(selected: Bool) {
        if selected {
            self.labelLikes.textColor = Constants.kGoldenButtonTextColor
            self.labelWeekLikes.textColor = Constants.kGoldenButtonTextColor
            self.labelWeekLikes.layer.borderColor = self.labelWeekLikes.textColor.CGColor
        }
        else {
            self.labelLikes.textColor = Constants.kDefaultButtonTextColor
            self.labelWeekLikes.textColor = Constants.kDefaultButtonTextColor
            self.labelWeekLikes.layer.borderColor = self.labelWeekLikes.textColor.CGColor
        }
    }
    
    func showImageViewMedalForPlace(place: Int) {
        switch place {
        case 1:
            self.imageViewMedal.hidden = false
            self.imageViewMedal.image = UIImage(named: "ImageMedal1st")
            break
        case 2:
            self.imageViewMedal.hidden = false
            self.imageViewMedal.image = UIImage(named: "ImageMedal2nd")
            break
        case 3:
            self.imageViewMedal.hidden = false
            self.imageViewMedal.image = UIImage(named: "ImageMedal3rd")
            break
        default:
            break
        }
    }

    @IBAction func buttonLike(sender: AnyObject) {
        self.delegate?.goalsTableViewCellButtonLike(self.tag, sender: sender as! UIButton)
    }
}
