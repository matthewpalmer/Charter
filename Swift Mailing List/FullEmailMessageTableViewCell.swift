//
//  FullEmailMessageTableViewCell.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 1/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class FullEmailMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var leadingMarginConstraint: NSLayoutConstraint!
    
    class func nib() -> UINib {
        return UINib(nibName: "FullEmailMessageTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
