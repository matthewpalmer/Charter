//
//  SearchInProgressTableViewCell.swift
//  Charter
//
//  Created by Matthew Palmer on 17/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class SearchInProgressTableViewCell: UITableViewCell {
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    class func nib() -> UINib {
        return UINib(nibName: "SearchInProgressTableViewCell", bundle: nil)
    }
}
