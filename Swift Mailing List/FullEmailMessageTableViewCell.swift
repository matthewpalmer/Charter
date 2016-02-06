//
//  FullEmailMessageTableViewCell.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 1/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import CollapsibleTextView

private class CollapsedRegionView: UIView {
    lazy var expandIndicator: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = .yellowColor()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(expandIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func intrinsicContentSize() -> CGSize {
        return expandIndicator.frame.size
    }
}

private class ExpandedRegionView: UIView {
    lazy var collapseIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .orangeColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.userInteractionEnabled = false
        textView.scrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .whiteColor()
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textView)
        self.addSubview(collapseIndicator)
        
        setupTextViewConstraints()
        setupCollapseIndicatorConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func updateConstraints() {
        super.updateConstraints()
    }
    
    private override func intrinsicContentSize() -> CGSize {
        let width = textView.intrinsicContentSize().width + collapseIndicator.frame.width
        let height = textView.intrinsicContentSize().height + collapseIndicator.frame.height
        return CGSize(width: width, height: height)
    }
    
    private func setupTextViewConstraints() {
        let top = NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: textView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: textView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: textView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 10)
        
        addConstraints([top, left, right, height])
    }
    
    private func setupCollapseIndicatorConstraints() {
        let top = NSLayoutConstraint(item: collapseIndicator, attribute: .Top, relatedBy: .Equal, toItem: textView, attribute: .Bottom, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: collapseIndicator, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: collapseIndicator, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
        let width = NSLayoutConstraint(item: collapseIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 50)
        let height = NSLayoutConstraint(item: collapseIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 44)
        
        addConstraints([top, bottom, left, width, height])
    }
}

class DataSource: CollapsibleTextViewDataSource {
    override func staticRegionForIndex(index: Int, text: String) -> UIView {
        let view = UITextView()
        view.userInteractionEnabled = false
        view.scrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = text
        return view
    }
    
    override func expandedRegionForIndex(index: Int, text: String) -> UIView {
        let view = ExpandedRegionView()
        
        view.textView.text = text
        
        view.collapseIndicator.tag = index
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapRegion:")
        view.collapseIndicator.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    override func collapsedRegionForIndex(index: Int) -> UIView {
        let view = CollapsedRegionView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.expandIndicator.tag = index
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapRegion:")
        view.expandIndicator.addGestureRecognizer(tapGesture)
        return view
    }
}

let longString = "this is a\nreally long text string\nwith\nmany\new\nlines" +
    "so tat\nwecan\ntest\nwhat\nscrolling\nmight be like" +
    "for users\n of this\nlibrary\nina table view\n"

let regions = [NSMakeRange(10, 40)]

protocol FullEmailMessageTableViewCellDelegate: class {
    func didChangeCellHeight()
}

class FullEmailMessageTableViewCell: UITableViewCell, CollapsibleTextViewDataSourceDelegate, RegionViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var leadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var regionView: RegionView!
    
    var dataSource = DataSource(text: longString, initiallyCollapsedRegions: regions)
    weak var delegate: FullEmailMessageTableViewCellDelegate?
    
    class func nib() -> UINib {
        return UINib(nibName: "FullEmailMessageTableViewCell", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        dataSource.delegate = self
        regionView.dataSource = dataSource
        regionView.delegate = self
        
        regionView.backgroundColor = .greenColor()
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
        print("Finished the replacement... \(delegate)")
        delegate?.didChangeCellHeight()
    }
}
