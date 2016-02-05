//
//  FullEmailMessageTableViewCell.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 1/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class FullEmailMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var leadingMarginConstraint: NSLayoutConstraint!
    class func nib() -> UINib {
        return UINib(nibName: "FullEmailMessageTableViewCell", bundle: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentTextView.textContainer.lineFragmentPadding = 0;
        contentTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        leadingMarginConstraint.constant = CGFloat(indentationLevel) * indentationWidth
    }
}
