//
//  NoThreadsTableViewCell.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 7/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class NoThreadsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    class func nib() -> UINib {
        return UINib(nibName: "NoThreadsTableViewCell", bundle: nil)
    }
}
