//
//  FullEmailMessageTableViewCell.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 1/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol FullEmailMessageTableViewCellDelegate: class {
    func didChangeCellHeight(indexPath: NSIndexPath)
    func presentPopover(view: UIView, sender: UIView)
}

class FullEmailMessageTableViewCell: UITableViewCell, EmailTextRegionViewDataSourceDelegate, RegionViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var leadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var regionView: RegionView!
    
    var textViewDataSource: EmailTextRegionViewDataSource? {
        didSet {
            textViewDataSource?.delegate = self
            regionView.dataSource = textViewDataSource
        }
    }
    
    weak var delegate: FullEmailMessageTableViewCellDelegate?
    
    class func nib() -> UINib {
        return UINib(nibName: "FullEmailMessageTableViewCell", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        textViewDataSource?.delegate = self
        regionView.dataSource = textViewDataSource
        regionView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leadingMarginConstraint.constant = CGFloat(indentationLevel) * indentationWidth
    }
    
    func regionView(regionView: RegionView, didFinishReplacingRegionAtIndex: Int) {
        delegate?.didChangeCellHeight(NSIndexPath(forRow: didFinishReplacingRegionAtIndex, inSection: 0))
    }
    
    func emailTextRegionViewDatatSourceNeedsPopoverViewControllerPresented(view: UIView, sender: UIView) {
        delegate?.presentPopover(view, sender: sender)
    }
    
    func setName(name: String) {
        nameLabel.font = UIFont.smallCapsFontOfSize(14)
        nameLabel.text = name.lowercaseString
    }
    
    func setDate(date: String) {
        dateLabel.font = UIFont.smallCapsFontOfSize(14)
        dateLabel.text = date.lowercaseString
    }
}
