//
//  MessagePreviewTableViewCell.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 5/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class MessagePreviewTableViewCell: UITableViewCell {
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    class func nib() -> UINib {
        return UINib(nibName: "MessagePreviewTableViewCell", bundle: nil)
    }
}
