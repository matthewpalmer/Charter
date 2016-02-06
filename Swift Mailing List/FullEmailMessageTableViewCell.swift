//
//  FullEmailMessageTableViewCell.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 1/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import CollapsibleTextView

protocol FullEmailMessageTableViewCellDelegate: class {
    func didChangeCellHeight(indexPath: NSIndexPath)
    func presentPopover(view: UIView, sender: UIView)
}

class FullEmailMessageTableViewCell: UITableViewCell, CollapsibleTextViewDataSourceDelegate, RegionViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var leadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var regionView: RegionView!
    
    var textViewDataSource: CollapsibleTextViewDataSource? {
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
    
    func collapsibleTextViewDataSource(dataSource: CollapsibleTextViewDataSource, didChangeRegionAtIndex index: Int) {
        let newView = dataSource.regionView(regionView, viewForRegionAtIndex: index)
        regionView.replaceRegionAtIndex(index, withView: newView)
    }
    
    func regionView(regionView: RegionView, didFinishReplacingRegionAtIndex: Int) {
        delegate?.didChangeCellHeight(NSIndexPath(forRow: didFinishReplacingRegionAtIndex, inSection: 0))
    }
    
    func collapsibleTextViewDataSourceNeedsPopoverViewControllerPresented(view: UIView, sender: UIView) {
        delegate?.presentPopover(view, sender: sender)
    }
}
