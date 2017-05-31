//
//  QuestionCell.swift
//  stackApp
//
//  Created by Keshav Bansal on 31/05/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var voteLabel: UILabel!
    @IBOutlet var questionNoLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var ownerLabel: UILabel!
    @IBOutlet var answeredLabel: UILabel!
    @IBOutlet var answerCountLabel: UILabel!
    @IBOutlet var containView: UIView!
  
    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containView.layer.borderColor = blueInstagramColor.cgColor
        self.containView.layer.borderWidth = 1
        self.containView.layer.cornerRadius = 12
        self.containView.layer.masksToBounds = true
        
        self.questionNoLabel.layer.cornerRadius = 12
        self.questionNoLabel.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
